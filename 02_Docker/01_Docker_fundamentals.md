# Docker Fundamentals (Week 2, Day 1)

Plan: [[00_Learning_Plan]] (Week 2: containers). Builds on [[05_Filesystem_and_permissions]] (a container is just isolated processes and files) and [[04_Shell]].

**Goal of the day:** know what an image and a container are, run and inspect containers, read logs, get a shell inside one, understand layers, and write and build a first Dockerfile.

Lab: open http://localhost:7000/ssh-lab.html, choose **5 · Docker (Week 2)** and do Level 1, then 2, then 3. It runs in the toolbox terminal (port 7682), which talks to Docker Desktop. Everything it creates is named `lab-*`, and **Reset lab** removes only that. All commands are listed in [[Interview_Commands]].

## 01 The core idea

| Word | Meaning |
| ---- | ------- |
| **Image** | A read-only package: files plus the default command. Built once, run many times. Like a recipe. |
| **Container** | A running (or stopped) copy of an image: normal Linux processes, isolated with namespaces and limited with cgroups. |
| **Registry** | A server that stores images (Docker Hub by default). `docker pull` downloads, `docker push` uploads. |
| **Engine** | The background service (`dockerd`) that does the work. The `docker` command is only a client that talks to it. |

A container is **not a virtual machine**. It has no kernel of its own: it shares the host kernel, and only the files (the OS userland) come from the image. That is why it starts in a second and an image can be 5 MB.

```bash
echo host: $(uname -r); docker run --rm alpine:3.20 uname -r    # same kernel number both times
```

## 02 Everyday commands

```bash
docker pull alpine:3.20                    # download an image (name:tag)
docker images                              # images on this machine
docker run --rm alpine:3.20 echo hi        # run one command, then delete the container
docker run -d --name web -p 8097:80 nginx:1.27-alpine     # background, named, host port 8097 -> container port 80
docker ps                                  # running containers   (-a = also stopped ones)
docker logs web                            # what the container printed (-f follow, --tail 20)
docker exec -it web sh                     # open a shell inside a running container (-i keep input, -t terminal)
docker exec web nginx -v                   # run one command inside
docker inspect web                         # full JSON facts (add --format '{{.State.Status}}')
docker stats --no-stream                   # cpu and memory snapshot
docker stop web && docker rm web           # stop (SIGTERM, then SIGKILL after 10 s), then delete
docker rm -f web                           # stop and delete in one go
docker system df                           # disk used by images, containers, volumes, build cache
docker system prune                        # remove stopped containers, unused networks, dangling images
```

Flag cheat sheet: `-d` detach, `-it` interactive terminal, `--rm` delete when it exits, `--name`, `-p host:container` publish a port, `-e KEY=value` environment variable, `-v` mount a volume (Day 4).

### Gotchas

- `docker run` always makes a **new** container. To start an old one again use `docker start NAME`.
- A container lives only while its main process (PID 1) runs. `docker run alpine` exits at once because the default command ends. A web server stays up because it never ends.
- **Files written inside a container are lost when it is removed.** Data you keep goes in a volume (Day 4). Logs should go to stdout so `docker logs` works.
- Published ports: `-p 8097:80` means *host* 8097 reaches *container* 80. Two containers cannot publish the same host port.
- The default user inside is `root`. Fixing that with a non-root `USER` is Day 3.
- Tags move. `nginx:latest` changes over time, `nginx:1.27-alpine` is stable. Pin versions.

## 03 Layers and the build cache

An image is a stack of read-only **layers**. Each Dockerfile instruction that changes files (`RUN`, `COPY`, `ADD`) makes one layer. A container adds a thin writable layer on top, which is deleted with the container.

```bash
docker image history nginx:1.27-alpine      # the layers, newest on top
```

- Layers are shared: two images based on `alpine` store the alpine layers once.
- The build **cache** reuses a layer if its instruction and everything above it are unchanged. The first changed instruction rebuilds that layer and **all layers after it**. So put steps that rarely change (install dependencies) first and steps that change often (copy your code) last. This is the main trick for fast builds, covered in depth on Day 2.

## 04 Your first Dockerfile

```dockerfile
FROM alpine:3.20                       # base image
RUN apk add --no-cache curl            # runs at BUILD time, result saved as a layer
CMD ["echo", "hello from my image"]    # default command at RUN time
```

```bash
mkdir /tmp/d1 && cd /tmp/d1            # put the Dockerfile in this folder (the "build context")
docker build -t d1-hello:1 .           # -t name:tag, the dot is the context folder
docker run --rm d1-hello:1             # prints: hello from my image
docker build -t d1-hello:1 .           # again: every layer says CACHED
```

- `RUN` = while building. `CMD` = when a container starts. Mixing these up is the most common beginner mistake.
- Use the exec form `CMD ["a","b"]` (JSON list), not `CMD a b`, so signals reach your program.
- Everything in the context folder is sent to the engine. A `.dockerignore` file keeps junk out (Day 2).

## 05 Check yourself

1. Image or container: which one is "running"? Which one can start many copies?
2. Why does `docker run alpine` print nothing and exit?
3. You wrote `/data.txt` inside a container, removed it, started a new one. Is the file there? Why?
4. What is the difference between `RUN` and `CMD`?
5. You change one line near the top of a Dockerfile. Which layers rebuild?
6. `-p 8097:80`: which number is the host port?

Answers: 1) container runs, image makes many. 2) The default command (`/bin/sh`) ends at once when nothing is attached to it. 3) No, the writable layer was deleted with the container. 4) build time vs start time. 5) That layer and every one after it. 6) 8097.

## 06 Interview questions

1. *Container vs virtual machine?* → A container shares the host kernel and isolates processes with namespaces and cgroups. A VM runs a full OS with its own kernel on a hypervisor. Containers are lighter and start faster, VMs isolate more strongly.
2. *What is a Docker image layer?* → A read-only filesystem diff created by a Dockerfile instruction. Layers are cached and shared between images.
3. *How do you see why a container crashed?* → `docker ps -a` for the exit code, `docker logs NAME`, `docker inspect NAME`.
4. *`CMD` vs `ENTRYPOINT`?* → `ENTRYPOINT` is the fixed program, `CMD` is its default arguments, and `docker run IMAGE args` replaces `CMD`.
5. *How do you shrink an image or speed up a build?* → Small base (alpine/slim), fewer layers, dependencies before code for caching, `.dockerignore`, multi-stage builds (Day 3).

Next: [[00_Learning_Plan]] Week 2 Day 2: Dockerfile layer caching, `.dockerignore`, build context size.
