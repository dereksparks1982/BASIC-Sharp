# BASIC# Stable Meaning Specification v4

Identity: `bsharp.meaning.v4`

Profile 4 extends Profile 3 only when a resolved `CONTROLS for PLAYER` declaration contains `platform_move` or `platform_jump`. Ordinary top-down controls, hover information, and context interactions remain Profile 3. Text values remain exact Profile 2-compatible meaning inside every later profile.

The stable creator meanings are:

- `KEY moves PLAYER left at N speed` binds held-key horizontal movement toward negative X at positive whole-number speed `N`.
- `KEY moves PLAYER right at N speed` binds held-key horizontal movement toward positive X at positive whole-number speed `N`.
- `KEY makes PLAYER jump at N speed` binds one newly pressed grounded jump with initial negative-Y velocity `N`.

A complete platform control declaration contains one left binding, one right binding, and one jump binding with three distinct keys. Opposing horizontal requests cancel. Platform and top-down movement models are not combined.

The canonical conformance manifest is `spec/meaning_v4/BASIC_SHARP_MEANING_PROFILE_v4.json`. Its eight cases cover declaration, creator-chosen speeds, invalid speeds, missing jobs, duplicate keys, model mixing, comments, and preservation of Profile 3 interaction declarations.
