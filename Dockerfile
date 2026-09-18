# NutriLatch variant for Plow Cloud and plow-agents local runs.
FROM public.ecr.aws/e1h7x4a2/plow-cloud-agents:base-42cb36ed16f513e9c7461b3f355acec181c8a26d@sha256:7bb771761c075ef3736c4cc7bdc48402ce325ed35b5efb529b1b31ec7956fd40

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
