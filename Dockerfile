# syntax=docker/dockerfile:1
FROM alpine:3.24.3@sha256:be2656061b536c1883c4034790e21d0a09c5aaaf51968b89368a3c0371ea2c9a
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
