# Counter-matrix draft review

User supplied `gui_build_proposer_matrix.lua` on 2026-09-12 and explicitly identified it as unfinished. SHA-256: `1723ca15bdaa1065ce4780174848ad32e0b2305df9077b290905d7946cc424a2`.

The inspected file contains data tables, not a complete widget: 160 candidate rows, 25,600 ordered named-unit pairs and 3,040 class fallback entries (19 per row). Values range from 0.05 to 1.95. There are 4,777 values equal to 1.00. Its comments define 1.00 as even; that does **not** identify which entries were reviewed or which are inherited estimates. Do not infer review status from a value being neutral or non-neutral.

155 row names match installed unit source names. Five are commander chassis aliases (`dynstrike`, `dynassault`, `dynknight`, `dynrecon`, `dynsupport`) requiring an explicit verified mapping for actual commander definitions/upgrades. The file says it was flattened from older layered data; its referenced provenance archive and consuming proposer widget were not supplied.

## Decision

Preserve the current role/capability counter logic and the frozen benchmark baseline. Retain this exact draft locally for comparison; do not install it as a widget or silently replace production decisions. Its values are author-supplied matchup preferences, not demonstrated win probabilities, damage ratios or terrain-independent combat guarantees.

## Integration contract for a reviewed revision

- Keep data separate from observation, production and order execution. Data cannot issue commands or grant authority.
- Require a revision/hash plus sparse per-pair review metadata: reviewed status, confidence, source and applicable game/context version. Unlisted pairs remain unreviewed even if a flattened numeric entry exists.
- Prefer an applicable reviewed named pair. For missing rows/targets, unreviewed entries, unsupported commander mappings, incompatible weapon/movement domains or invalid values, return the existing decision contribution unchanged. Preserve uncovered enemy composition rather than normalizing only the matrix-covered subset.
- Existing factory build options, ownership, manual exclusions, resource limits, role diversity and native capabilities remain mandatory. A numerical preference cannot make a constructor a combat unit or let an anti-air weapon shoot ground units.
- Use only visually identified unit names and legitimately remembered sightings, with the existing decay. Radar-only contacts stay unidentified and use current uncertainty handling. Never recover an identity from a matrix key.
- Start with shadow comparisons: record proposed rankings, coverage/confidence and disagreement with the current model without changing orders. Then run a separately frozen training A/B candidate. Do not mix matrix revisions into a running campaign or tune using holdout results.
- Promotion should be bounded and explainable; the prior model remains the fallback. A later data revision can fill reviewed gaps without replacing control architecture.

The supplied draft is retained outside the distributable widget package while its author continues work. This review makes no authorship or license claim over that data.
