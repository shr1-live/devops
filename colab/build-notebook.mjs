// Builds DevOps_Lab.ipynb (for Google Colab) from the lab data. Re-run after changing ssh-lab-ui/lab-topics.js:
//   node colab/build-notebook.mjs
// Everything the notebook needs (sample files, a persistent shell helper) is embedded, so it runs on its own in Colab.
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.join(here, "..");
const LAB = new Function(fs.readFileSync(path.join(root, "ssh-lab-ui/lab-topics.js"), "utf8") + ";return LAB;")();

// ---- sample files the steps use (Colab path -> repo file) ----
const FILE_SOURCES = {};
const add = (colabDir, repoDir) => {
  const walk = d => fs.readdirSync(d, { withFileTypes: true }).forEach(e => {
    const p = path.join(d, e.name);
    if (e.isDirectory()) walk(p);
    else FILE_SOURCES[colabDir + "/" + path.relative(repoDir, p).split(path.sep).join("/")] = p;
  });
  walk(repoDir);
};
add("/scripts/lab-files", path.join(root, "01_Working_with_shell/labs/lab-files"));
add("/work/lab-ci", path.join(root, "03_CICD_Terraform/lab-ci"));
add("/work/lab-tf", path.join(root, "03_CICD_Terraform/lab-tf"));
add("/work/lab-docker", path.join(root, "02_Docker/lab-docker"));
const FILES = {};
for (const [dest, src] of Object.entries(FILE_SOURCES)) FILES[dest] = fs.readFileSync(src, "utf8").replace(/\r\n/g, "\n");

// ---- cell helpers ----
const cells = [];
const md = text => cells.push({ cell_type: "markdown", metadata: {}, source: text.split("\n").map((l, i, a) => i < a.length - 1 ? l + "\n" : l) });
const code = text => cells.push({ cell_type: "code", metadata: {}, execution_count: null, outputs: [], source: text.split("\n").map((l, i, a) => i < a.length - 1 ? l + "\n" : l) });
const sh = cmd => code("%%b\n" + cmd);
const fence = cmd => "```bash\n" + cmd + "\n```";

// ---- the helper cell: one persistent bash, like a terminal ----
const HELPER = `# Run this cell first (Runtime > Run all is also fine for this one).
# It gives you the %%b cell magic: every %%b cell runs in ONE persistent Linux shell, just like a terminal.
# So cd, variables, export and background jobs (&) stay alive from one cell to the next.
import os, json, uuid, pathlib, subprocess
from IPython.core.magic import register_cell_magic

FILES = json.loads(r'''${JSON.stringify(FILES)}''')
for dest, text in FILES.items():
    p = pathlib.Path(dest); p.parent.mkdir(parents=True, exist_ok=True); p.write_text(text)
    if dest.endswith(".sh"): p.chmod(0o755)

_env = dict(os.environ, DEBIAN_FRONTEND="noninteractive", PS1="")
_shell = None
def _start():
    global _shell
    _shell = subprocess.Popen(["bash", "--noprofile", "--norc"], stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                              stderr=subprocess.STDOUT, text=True, bufsize=1, cwd=os.path.expanduser("~"), env=_env)

@register_cell_magic
def b(line, cell):
    """Run the cell in the persistent bash session. '%%b reset' starts a fresh shell."""
    global _shell
    if line.strip() == "reset" or _shell is None or _shell.poll() is not None:
        if _shell is not None and _shell.poll() is None: _shell.kill()
        _start()
    tag = "__END_" + uuid.uuid4().hex + "__"
    _shell.stdin.write(cell.rstrip("\\n") + "\\n" + "echo " + tag + "\\n"); _shell.stdin.flush()
    for out in _shell.stdout:
        if tag in out:
            before = out.split(tag)[0]
            if before: print(before, end="", flush=True)
            break
        print(out, end="", flush=True)

_start()
print("Ready. Sample files are in /scripts/lab-files, /work/lab-ci, /work/lab-tf, /work/lab-docker.")`;

// ---- notebook ----
md(`# DevOps Interview Lab (Google Colab)

Easy to medium commands, one short command at a time, in the same order as the lab page. Each topic has **Level 1 Basic**, **Level 2 Next level** and **Level 3 Medium**, then interview questions.

**How to use**
1. Run the first code cell below (it creates the \`%%b\` shell and the sample files).
2. Go to a topic in the table of contents (left sidebar) and run the cells **from top to bottom**. Each step has a short explanation above its command.
3. A level can be repeated: run its reset cell at the end of the topic.

**Keep a copy:** *File > Save a copy in Drive*. The latest version is always at https://github.com/shr1-live/devops (folder \`colab\`).

**Good to know**
- Colab gives you a real Linux machine with root, so \`apt\`, \`nginx\`, \`git\` and \`terraform\` all work here.
- **Docker does not run inside Colab.** Topic 5 is a reference, and you practise it in the lab page on Docker Desktop. Topic 8 (Cloud) needs a cloud account, so it is a reference too.
- The machine is wiped when the Colab session ends. That is fine: re-run the first cell and carry on.`);
code(HELPER);

const COLAB_ONLY = {
  t4: { after: "apt-get install -y -qq nginx", md: "**Colab only:** the install may already have started a default NGINX on port 80. Stop it so ours starts cleanly in a few steps.", cmd: "service nginx stop" },
};
const COLAB_SETUP = {
  t6: { md: "**Colab setup:** installs `yq`, the tool used to read the workflow file later. (The lab page already has it.)", cmd: "wget -q -O /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/v4.44.3/yq_linux_amd64\nchmod +x /usr/local/bin/yq\nyq --version" },
  t7: { md: "**Colab setup:** installs Terraform. (The lab page already has it.)", cmd: "apt-get install -y -qq unzip\ncd /tmp\nwget -q https://releases.hashicorp.com/terraform/1.10.3/terraform_1.10.3_linux_amd64.zip\nunzip -qo terraform_1.10.3_linux_amd64.zip\nmv terraform /usr/local/bin/\nterraform version" },
};
const NOT_IN_COLAB = { t5: "Docker cannot run inside Colab (there is no Docker engine). Practise this topic in the lab page on Docker Desktop (http://localhost:7000/ssh-lab.html, topic 5). The commands and notes are here for reference.", t8: "This topic needs a cloud account (AWS or Azure), so the commands are for reference. Run them in a KodeKloud playground." };

let steps = 0;
for (const T of LAB) {
  md(`# ${T.name}\n\n${T.goal}`);
  const reference = !!NOT_IN_COLAB[T.id];
  if (reference) md(`> ${NOT_IN_COLAB[T.id]}`);
  if (COLAB_SETUP[T.id]) { md(COLAB_SETUP[T.id].md); sh(COLAB_SETUP[T.id].cmd); }
  for (const L of T.levels) {
    md(`## ${L.name}${L.optional ? " (optional)" : ""}${L.copyOnly ? " (reference)" : ""}${L.needs ? "\n\n*Run Level 1 first.*" : ""}`);
    const cwd = L.cwd || T.cwd;
    const first = L.steps[0] ? L.steps[0][1] : "";
    if (!reference && !L.copyOnly && cwd && cwd !== "~" && !/^mkdir /.test(first)) { md("*Go to the practice folder first.*"); sh(`mkdir -p ${cwd}\ncd ${cwd}`); }
    L.steps.forEach((s, i) => {
      md(`**${i + 1}. ${s[0]}**\n\n${s[3]}`);
      if (reference || L.copyOnly) md(fence(s[1]));
      else { sh(s[1]); steps++; }
      if (COLAB_ONLY[T.id] && s[1] === COLAB_ONLY[T.id].after) { md(COLAB_ONLY[T.id].md); sh(COLAB_ONLY[T.id].cmd); }
    });
  }
  if (T.server) {
    md(`## ${T.server.name} (reference)\n\n${T.server.note}`);
    T.server.steps.forEach((s, i) => { md(`**${i + 1}. ${s[0]}**\n\n${s[3]}`); md(fence(s[1])); });
  }
  if (T.qa) {
    md("## Interview Q&A");
    md(T.qa.map(([q, parts], i) => `**${i + 1}. ${q}**\n\n` + parts.map(([p, m]) => `- ${p}: ${m}`).join("\n")).join("\n\n"));
  }
  if (!reference && T.reset && T.reset.length) { md("### Reset this topic (optional)\n\nRemoves what this topic created so you can start over."); sh(T.reset.join("\n")); }
}

const nb = {
  nbformat: 4, nbformat_minor: 4,
  metadata: { colab: { provenance: [], toc_visible: true, name: "DevOps_Lab.ipynb" }, kernelspec: { display_name: "Python 3", name: "python3" }, language_info: { name: "python" } },
  cells,
};
const out = path.join(here, "DevOps_Lab.ipynb");
fs.writeFileSync(out, JSON.stringify(nb, null, 1));
console.log("cells:", cells.length, "| runnable step cells:", steps, "| size:", (fs.statSync(out).size / 1024).toFixed(0) + " KB");
