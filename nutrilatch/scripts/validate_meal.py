#!/usr/bin/env python3
"""Deterministic gate between the LLM's calorie estimate and the meal log
write, same role as receiptsnap's validate_extraction.py: the model reads
the input (text or photo); this script decides whether what it estimated
is well-formed enough to become a row.

The plausibility range (0, 5000] catches an extraction gone wrong (a
misplaced decimal, a unit confused for a count) without pretending to
validate nutritional accuracy -- that part is not this script's job, and
the skill itself is expected to say the estimate is approximate.
"""
import json
import sys
from datetime import date

MAX_PLAUSIBLE_KCAL = 5000


def fail(field, reason):
    print(f"{field}: {reason}", file=sys.stderr)
    return 1


def main():
    if len(sys.argv) != 2:
        print("usage: validate_meal.py '<json>'", file=sys.stderr)
        return 2

    try:
        meal = json.loads(sys.argv[1])
    except json.JSONDecodeError as exc:
        return fail("json", f"not valid JSON: {exc}")

    if not isinstance(meal, dict):
        return fail("json", "must be a JSON object")

    missing = [f for f in ("description", "calories", "date") if f not in meal]
    if missing:
        return fail(",".join(missing), "missing")

    description = meal["description"]
    if not isinstance(description, str) or not description.strip():
        return fail("description", "must be a non-empty string")

    calories = meal["calories"]
    if isinstance(calories, bool) or not isinstance(calories, (int, float)):
        return fail("calories", "must be a number")
    if not (0 < calories <= MAX_PLAUSIBLE_KCAL):
        return fail("calories", f"must be > 0 and <= {MAX_PLAUSIBLE_KCAL}")

    try:
        date.fromisoformat(meal["date"])
    except (TypeError, ValueError):
        return fail("date", "must be YYYY-MM-DD and a real calendar date")

    print(json.dumps({
        "description": description.strip(),
        "calories": calories,
        "date": meal["date"],
    }))
    return 0


if __name__ == "__main__":
    sys.exit(main())
