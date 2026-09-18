# NutriLatch

A [Hermes](https://howto.plow.co/hermes) agent for Plow: text what you ate (or
a photo of your plate), and it estimates the calories, logs it to a CSV on
your own Mac, and — once it knows your Basal Metabolic Rate (BMR) — tells
you how many calories you have left for the day.

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
5. On first real use, it actively invites you to set up your BMR (sex,
   weight, height, age) — a nudge that keeps showing up on meal-related
   replies until you either answer it or say not now. It computes BMR with
   a fixed formula (Mifflin-St Jeor — deterministic, not the model doing
   arithmetic) and saves it to `~/Plow/nutrilatch/profile.json` so it
   never has to ask again.
6. Once BMR is known, every meal-log reply also says how many calories are
   left today to stay within it (or how far over, if you've gone past
   it) — a running budget for the day, tracked against BMR specifically.

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

## Install

The simplest path is **Deploy this agent** on the
[NutriLatch Agent Index page](https://aiworthusing.com/agent-index/nutrilatch).
Install Plow Latch on the Mac and sign in to the same Plow account; NutriLatch
creates its files under `~/Plow/nutrilatch/` automatically on first use.

To run the image from source, install Docker, Python 3.11+, and
[`plow-agents`](https://github.com/plow-pbc/plow-agents), then:

```sh
git clone https://github.com/ryanmiura/nutrilatch-hermes-agent.git
cd nutrilatch-hermes-agent
plow-agents login
plow-agents lines
plow-agents deploy --local --line <FREE_LINE_ID>
docker compose logs -f
```

Then text a meal to the agent's Plow Chat line.

## License

MIT — see [LICENSE](LICENSE).
