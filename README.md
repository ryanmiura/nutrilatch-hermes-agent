# NutriLatch

A [Hermes](https://howto.plow.co/hermes) agent, run via
[`agent-mgr`](https://github.com/plow-pbc/agent-mgr): text what you ate (or
a photo of your plate), and it estimates the calories and logs it to a CSV
on your own Mac. Separately, it tracks the profile fields needed to
calculate your Basal Metabolic Rate (BMR) and answers with the formula
result once it knows them.

## What it does

1. Text (or photo) a meal to the agent's own Plow Chat line —
   "comi 200g de arroz com 150g de frango" or a picture of your plate.
2. It estimates the calories with its own vision/reasoning — no external
   nutrition API — and appends one row to
   `~/Plow/nutrilatch/meals.csv` on your Mac, through
   [Plow Latch](https://plow.co/latch)'s file tools.
3. It replies confirming what was logged, always noting the estimate is
   approximate, not a lab measurement.
4. Ask "quantas calorias comi hoje?" any time and it rereads the same file
   to answer.
5. Ask about your BMR/metabolism, and it asks (once) for sex, weight,
   height and age, computes BMR with a fixed formula (Mifflin-St Jeor —
   deterministic, not the model doing arithmetic), and saves it to
   `~/Plow/nutrilatch/profile.json` so it never has to ask again.

See [`nutrilatch/SKILL.md`](nutrilatch/SKILL.md) for the exact flow.

## What it can and cannot reach

- **Reads**: text/photo messages sent to its own Plow Chat line. Nothing
  else on your phone or Mac.
- **Touches exactly two files** on your Mac — the meal ledger and the BMR
  profile, both under `~/Plow/nutrilatch/` — through Plow Latch's
  `plow_read_file`/`plow_write_file`. Nothing else on disk, no browser.
- Paths under `~/Plow` auto-approve on every read/write (Plow Latch's own
  shared-folder convention), so logging a meal never pops an approval
  dialog.

## Bring it up

Prerequisites: `docker`, `python3` (3.11+), an authenticated `gh`, and
[`agent-mgr`](https://github.com/plow-pbc/agent-mgr) installed
(`agent-mgr ls` should run).

```sh
git clone https://github.com/ryanmiura/nutrilatch-hermes-agent.git
agent-mgr register nutrilatch ./nutrilatch-hermes-agent
agent-mgr deploy nutrilatch

# Nothing to configure before the first run -- meals.csv and profile.json
# are created automatically the first time each is needed, as long as
# Plow Latch is installed.

agent-mgr activate nutrilatch         # texts a one-time code to your phone
agent-mgr up nutrilatch
agent-mgr sign-in nutrilatch          # device-code OAuth in your browser

# Pair it to a Mac running Plow Latch: in Latch, Agents pane -> MCP clients
# -> Connect MCP client -> "Can't use OAuth? Create a static credential" ->
# copy the JSON it shows once, then:
agent-mgr set-latch nutrilatch
agent-mgr check-latch nutrilatch      # expect "latch reachable ... (HTTP 200)"
```

Smoke test:

```sh
agent-mgr agent nutrilatch "hello, who are you?"
```

Then text a meal to the agent's Plow Chat line.

## License

MIT — see [LICENSE](LICENSE).
