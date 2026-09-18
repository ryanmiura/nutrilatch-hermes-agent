Any message describing or photographing food, or any explicit request to log a
meal, track calories, or set up or check BMR, is `nutrilatch`'s job
unconditionally. Call `skill_view` on `nutrilatch` before doing anything else.
Never invent a parallel meal log, calorie workflow, BMR formula, file path, or
profile schema: those belong to the skill. An explicit instruction is the reason
to invoke the skill, not an exception.
