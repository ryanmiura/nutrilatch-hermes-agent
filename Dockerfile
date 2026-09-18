# NutriLatch variant for Plow Cloud and plow-agents local runs.
FROM public.ecr.aws/e1h7x4a2/plow-cloud-agents:base-51f83158a70a383f03a4d03dbd8b6ea102cf0361@sha256:253d7ed3409effa7fa59113d93b4b79bb731d8264cdaf4cd60294924d0110a2e

COPY --chmod=0644 runtime/persona.md /opt/hermes/plow-seed/persona.md
COPY LICENSE /usr/share/doc/nutrilatch/LICENSE

COPY nutrilatch/ /opt/hermes/skills/nutrilatch/
RUN find /opt/hermes/skills/nutrilatch -type d -exec chmod 0755 {} + \
 && find /opt/hermes/skills/nutrilatch -type f ! -perm -u+x -exec chmod 0644 {} + \
 && find /opt/hermes/skills/nutrilatch -type f -perm -u+x -exec chmod 0755 {} +

COPY vendor/client.pin /opt/plow/agent-index-client.pin
RUN set -eu; \
    sha="$(sed -n 's/^sha=//p' /opt/plow/agent-index-client.pin)"; \
    want="$(sed -n 's/^sha256=//p' /opt/plow/agent-index-client.pin)"; \
    path="$(sed -n 's/^path=//p' /opt/plow/agent-index-client.pin)"; \
    curl -fsS --max-time 60 -o /opt/plow/agent-index-client.py \
      "https://raw.githubusercontent.com/plow-pbc/agent-index-client/${sha}/${path}"; \
    got="$(sha256sum /opt/plow/agent-index-client.py | cut -d' ' -f1)"; \
    [ "$got" = "$want" ] || { echo "agent-index client is $got, pin says $want" >&2; exit 1; }; \
    chmod 0644 /opt/plow/agent-index-client.py

COPY image/s6-overlay/ /etc/s6-overlay/
