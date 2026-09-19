# NutriLatch variant for Plow Cloud and plow-agents local runs.
FROM public.ecr.aws/e1h7x4a2/plow-cloud-agents:base-ef0019372ff8bca593611b31ebd2e08f9f1458ff@sha256:a8a2f97ad78b8192d80a984dce81d3bf5a9a883d18cb7b677704913a09b56aee

COPY --chmod=0644 runtime/persona.md /opt/hermes/plow-seed/persona.md
COPY LICENSE /usr/share/doc/nutrilatch/LICENSE

COPY nutrilatch/ /opt/hermes/skills/nutrilatch/
RUN find /opt/hermes/skills/nutrilatch -type d -exec chmod 0755 {} + \
 && find /opt/hermes/skills/nutrilatch -type f ! -perm -u+x -exec chmod 0644 {} + \
 && find /opt/hermes/skills/nutrilatch -type f -perm -u+x -exec chmod 0755 {} +

# Usage reporting is the base's own Agent Index reporter (pinned client + s6
# "agent-index" service). It reads AGENT_ID; the Plow cloud passes no
# environment, so the id is baked here. Compose sets the same value.
ENV AGENT_ID=nutrilatch
