# syntax=docker/dockerfile:1
FROM alpine:3.24.2@sha256:294b683cb724975bec92580e1e685676bd4b50bda910ddb8c51d4cabeaec77e6
WORKDIR /

# Pull distro security fixes newer than the tagged base.
RUN apk upgrade --no-cache

# iproute2 -> ip, bridge
# bind-tools -> dig
# dnsmasq-dnssec -> DNS & DHCP server with DNSSEC support
# coreutils -> REAL chown and chmod
# bash -> scripting logic
# inotify-tools -> inotifyd for dnsmasq resolv.conf reload circumvention
# iptables, ip6tables -> kill switch / NAT (nft-backed on alpine)
# All from the alpine repos; no curl|sh, no unpinned downloads.
RUN apk add --no-cache coreutils dnsmasq-dnssec iproute2 bind-tools bash inotify-tools iptables ip6tables

COPY config /default_config
COPY config /config
COPY --chmod=0755 bin /bin

# Runs as root by design: the gateway and the injected client containers
# manage routes, VXLAN links, iptables and dnsmasq DHCP (see README.md
# for the exact capabilities each container needs).
# Upstream CMD pointed at a non-existent /bin/entry.sh; the chart always sets
# the command, so default to the gateway sidecar.
CMD ["/bin/gateway_sidecar.sh"]
