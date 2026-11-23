# Ubuntu practice box for DevOps learning.
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Kolkata \
    LANG=C.UTF-8

# Tools that are handy while practising Linux / DevOps basics.
RUN apt-get update && apt-get install -y --no-install-recommends \
        sudo bash-completion ca-certificates locales tzdata \
        vim nano less man-db manpages file tree \
        curl wget git openssh-client \
        zip unzip tar gzip \
        procps htop psmisc lsof \
        iproute2 iputils-ping net-tools dnsutils netcat-openbsd traceroute \
        jq python3 \
    && rm -rf /var/lib/apt/lists/*

# Create a normal user with passwordless sudo. Ubuntu 24.04 ships a
# default "ubuntu" user on UID 1000, so remove it to reuse that UID and
# keep file ownership matching your host user on the mounted repo.
ARG USERNAME=dev
ARG USER_UID=1000
ARG USER_GID=1000
RUN userdel -r ubuntu 2>/dev/null || true \
    && groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd --uid ${USER_UID} --gid ${USER_GID} -m -s /bin/bash ${USERNAME} \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME}

USER ${USERNAME}
WORKDIR /home/${USERNAME}

CMD ["sleep", "infinity"]
