# SPDX-License-Identifier: Apache-2.0
#
# Copyright (c) 2022 Patrick Dung

ARG BASE_IMAGE
FROM ${BASE_IMAGE}

    # This image do not run as root
    # Not installed:
    # util-linux
    # net-tools has many dependencies (systemd)
    # ------
    # both unbound (for unbound-host) and bind-utils rpm dependency (python/pip/wheel)
RUN set -eux && \
    microdnf -y install --nodocs \
      --setopt="install_weak_deps=0" \
      --setopt="keepcache=0" --disablerepo="appstream" \
      shadow-utils tmux less \
      ca-certificates iproute curl traceroute openssl \
      grep file gawk sed \
      iputils mtr \
    && microdnf -y install --nodocs \
      --setopt="install_weak_deps=0" \
      --setopt="keepcache=0" \
      telnet socat jq wget bind-utils iperf3 nmap-ncat \
      tcpdump \
    && microdnf -y upgrade --nodocs && \
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
    microdnf remove shadow-utils && \
    microdnf clean all && \
    rm -rf /var/cache/yum

USER debug
WORKDIR /home/debug

CMD ["/usr/bin/sleep", "infinity"]
