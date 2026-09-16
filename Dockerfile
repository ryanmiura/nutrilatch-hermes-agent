# Derived image for Agent Index usage reporting: adds the reporter as a
# supervised service, on top of agent-mgr's own pinned local base --
# otherwise unmodified. Built and run entirely locally via agent-mgr (see
# compose.override.yml). Same pattern as receiptsnap-hermes-agent's
# Dockerfile, verified against a real running container there.
#
# BASE tracks agent.env's AGENT_IMAGE... in reverse: agent.env names the tag
# THIS Dockerfile produces, so BASE's default here is the one place the
# upstream pin actually lives. Rebump: `agent-mgr resolve nutrilatch` after
# a stack.json bump, then update the default below and rebuild.
ARG BASE=nousresearch/hermes-agent@sha256:8f4e8677281eca188bc9d2fda90806646ba19941fce55fa8fda2d63112ff48a8
FROM ${BASE}

COPY LICENSE /usr/share/doc/nutrilatch/LICENSE

# The usage reporter, fetched at build from the commit vendor/client.pin
# names and checked against the hash beside it.
COPY vendor/client.pin /opt/plow/agent-index-client.pin
RUN set -eu; \
    sha="$(sed -n 's/^sha=//p' /opt/plow/agent-index-client.pin)"; \
    want="$(sed -n 's/^sha256=//p' /opt/plow/agent-index-client.pin)"; \
    path="$(sed -n 's/^path=//p' /opt/plow/agent-index-client.pin)"; \
    curl -fsS --max-time 60 -o /opt/plow/agent-index-client.py \
      "https://raw.githubusercontent.com/plow-pbc/agent-index-client/${sha}/${path}"; \
    got="$(sha256sum /opt/plow/agent-index-client.py | cut -d' ' -f1)"; \
    [ "$got" = "$want" ] || { echo "agent-index client is $got, pin says $want" >&2; exit 1; }; \
    chown root:root /opt/plow/agent-index-client.pin /opt/plow/agent-index-client.py; \
    chmod 0644 /opt/plow/agent-index-client.py

# The reporter's schedule, registered into the base image's own (empty)
# user2 extension bundle rather than its user bundle.
COPY image/s6-overlay/ /etc/s6-overlay/
RUN chmod 0755 /etc/s6-overlay/s6-rc.d/agent-index/run
