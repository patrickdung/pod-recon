# SPDX-License-Identifier: Apache-2.0
#
# Copyright (c) 2022 Patrick Dung

ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ARG AMICONTAINED_VERSION
ARG AMICONTAINED_BASE_URL

    # This image do not run as root
    # Not installed:
    # util-linux
    # net-tools has many dependencies (systemd)
    # ------
    # both unbound (for unbound-host) and bind-utils rpm dependency (python/pip/wheel)
RUN set -eux && \
    # in FC38, curl-minimal-7.76.1-23.el9.aarch64 conflicts with curl provided by curl-7.76.1-23.el9_2.1.aarch64 ?
    microdnf -y install --nodocs \
      --setopt="install_weak_deps=0" \
      --setopt="keepcache=0" --disablerepo="appstream" \
      shadow-utils tmux less \
      ca-certificates iproute traceroute openssl \
      grep file gawk sed \
      iputils mtr \
    && microdnf -y install --nodocs \
      --setopt="install_weak_deps=0" \
      --setopt="keepcache=0" \
      telnet socat jq wget bind-utils iperf3 nmap-ncat \
      tcpdump \
    && microdnf -y upgrade --nodocs && \
    QUERY_ARCH=$(rpm -qf /lib64/libc.so.6 | awk -F\. '{print $NF}') && \
    if [ "${QUERY_ARCH}" = "x86_64" ]; then \
      curl -L -O "${AMICONTAINED_BASE_URL}"/amicontained-build_"${AMICONTAINED_VERSION}"_linux_amd64.rpm && \
      curl -L -O "${AMICONTAINED_BASE_URL}"/checksums.txt && \
      sha256sum --check --strict --ignore-missing checksums.txt && \
      rpm -ivh amicontained-build_"${AMICONTAINED_VERSION}"_linux_amd64.rpm; fi && \
    if [ "${QUERY_ARCH}" = "aarch64" ]; then \
      curl -L -O "${AMICONTAINED_BASE_URL}"/amicontained-build_"${AMICONTAINED_VERSION}"_linux_arm64.rpm && \
      curl -L -O "${AMICONTAINED_BASE_URL}"/checksums.txt && \
      sha256sum --check --strict --ignore-missing checksums.txt && \
      rpm -ivh amicontained-build_"${AMICONTAINED_VERSION}"_linux_arm64.rpm; fi && \
    rm -vf -- *.rpm checksums.txt && \
    groupadd \
      --gid 20000 \
      debug && \
    useradd --no-log-init \
      --create-home \
      --home-dir /home/debug \
      --shell /bin/bash \
      --uid 20000 \
      --gid 20000 \
      --key MAIL_DIR=/dev/null \
      debug && \
    mkdir -p /home/debug/bin && \
    chown -R debug:debug /home/debug && \
    microdnf -y remove shadow-utils && \
    microdnf -y clean all && \
    rm -rf /var/cache/yum

USER debug
WORKDIR /home/debug

CMD ["/usr/bin/sleep", "infinity"]
