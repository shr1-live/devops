# DevOps Lab in Google Colab

Open the notebook in Colab:

https://colab.research.google.com/github/shr1-live/devops/blob/main/colab/DevOps_Lab.ipynb

Then **File > Save a copy in Drive** to keep your own copy.

- Run the first code cell once. It creates the `%%b` shell (one persistent Linux shell, like a terminal) and the sample files.
- Go to a topic in the left sidebar table of contents and run the cells from top to bottom.
- Topics 1-4, 6 and 7 (Linux, Bash, Networking, NGINX, Git/CI, Terraform) run in Colab. Docker (5) and Cloud (8) are reference only: Colab has no Docker engine and there is no cloud account.
- All commands are also listed in [Interview_Commands.md](../Interview_Commands.md).

## Rebuild after changing the lab

The notebook is generated from `ssh-lab-ui/lab-topics.js` and the sample files in this repo:

```bash
node colab/build-notebook.mjs
```
