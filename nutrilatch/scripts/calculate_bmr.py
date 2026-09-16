#!/usr/bin/env python3
"""Basal metabolic rate, Mifflin-St Jeor. A formula belongs in code, not in
the model's arithmetic -- this is the one thing standing between "the LLM
did some mental math" and a number the user might actually plan meals
around.

    men:   BMR = 10*weight_kg + 6.25*height_cm - 5*age + 5
    women: BMR = 10*weight_kg + 6.25*height_cm - 5*age - 161

Sex is a two-term switch on the formula's own constant, not a broader claim
about the person -- there is no "other" branch to approximate correctly, so
none is invented here.
"""
import json
import sys

REQUIRED_FIELDS = ("sex", "weight_kg", "height_cm", "age")


def fail(field, reason):
    print(f"{field}: {reason}", file=sys.stderr)
    return 1


def main():
    if len(sys.argv) != 2:
        print("usage: calculate_bmr.py '<json>'", file=sys.stderr)
        return 2

    try:
        profile = json.loads(sys.argv[1])
    except json.JSONDecodeError as exc:
        return fail("json", f"not valid JSON: {exc}")

    if not isinstance(profile, dict):
        return fail("json", "must be a JSON object")

    missing = [f for f in REQUIRED_FIELDS if f not in profile]
    if missing:
        return fail(",".join(missing), "missing")

    sex = profile["sex"]
    if sex not in ("male", "female"):
        return fail("sex", 'must be "male" or "female"')

    def positive_number(field):
        value = profile[field]
        if isinstance(value, bool) or not isinstance(value, (int, float)):
            return None
        return value if value > 0 else None

    weight_kg = positive_number("weight_kg")
    if weight_kg is None:
        return fail("weight_kg", "must be a positive number")

    height_cm = positive_number("height_cm")
    if height_cm is None:
        return fail("height_cm", "must be a positive number")

    age = positive_number("age")
    if age is None:
        return fail("age", "must be a positive number")

    constant = 5 if sex == "male" else -161
    bmr = 10 * weight_kg + 6.25 * height_cm - 5 * age + constant

    print(json.dumps({
        "sex": sex,
        "weight_kg": weight_kg,
        "height_cm": height_cm,
        "age": age,
        "bmr_kcal_per_day": round(bmr, 1),
    }))
    return 0


if __name__ == "__main__":
    sys.exit(main())
