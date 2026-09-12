# Calibration candidate 1

Status: 32 Lua regression suites and the native five-minute pilot passed; full candidate training evaluation is running. The pilot maintained one-unit native factory queues, reached five completed military units by 60 seconds, and recorded no controller errors. The baseline remains an immutable source snapshot in the isolated campaign directory. No holdout results have been used to select these changes.

## Findings and changes

1. **Factory quantity bug.** A log entry claimed one constructor, but native matches produced five before the next production decision. The executor used Shift. The [engine factory command implementation](https://raw.githubusercontent.com/beyond-all-reason/spring/master/rts/Sim/Units/CommandAI/FactoryCAI.cpp) multiplies factory quantity by five for Shift; native builds append without that modifier. Send one unmodified build command to an idle factory. The fixture now models native quantity modifiers and asserts a one-unit queue.
2. **Energy accounting.** Raw engine energy income is affected by Zero-K overdrive transfers. Match the installed Chili economy panel formula: native income minus positive OD energy change plus OD energy income. Retain raw income separately. This prevents treating overdrive consumption as absent generation.
3. **Early allocation.** Limit extra expansion-worker demand until five military units exist; prevent the recovery service from taking both initial expansion workers. Prefer the first nearby mexes while energy reserves permit. Explicit worker enrollment transfers service ownership cleanly.
4. **Streaming construction.** Native construction spends resources over time. Use bounded initial funding for expensive production/recovery jobs while income exists, instead of requiring the whole price in storage. Recovery reserves only currently visible, unthreatened jobs that an owned worker can build. Cap initial funding relative to storage/income so a lost factory costing more than storage cannot permanently lock production.
5. **Defense saturation.** Distinguish factories/expensive builders from remote minor assets. Remote responses target at most 35% of combat value, critical responses 70%, with indivisible-unit rounding. Return excess reinforcements when the threat shrinks. Reserves and manual override remain separate from field pushes.
6. **Repeated bad approaches.** A map-wide force avoids visually overwhelming target areas using its current health-weighted value and the existing risk heuristic. After recovery begins, penalize the recent failed area for 120 game seconds. This changes sector preference; it does not claim unknown routes are safe or solve full terrain connectivity.
7. **Unit lifetimes.** Clean dead/released subgroup entries. On a confirmed owned UnitCreated event, advance the recycled ID's lifetime, revoke stale ownership/pending records and clear old exclusions. A manual override still excludes the same living unit; creation never revives an old operation.

The unfinished user-supplied counter matrix is not active in this candidate. See [draft review and fallback contract](MATRIX_DRAFT_REVIEW.md). Existing role/capability decisions remain the fallback.

## Validation limits

Run the full training set against the same pinned stock Brutal build after the native pilot. Keep all wins, losses, time caps and errors. This bundle is not an ablation study: any overall change cannot be attributed to one fix alone, and Circuit's internal randomness can change its factory opening between repeated cases. Consistent performance must be measured, not inferred from regression success.

## Candidate 2 storage correction

Candidate 1 was stopped after the normal-start balances exposed an unreachable 700-metal expansion threshold. All completed preliminary cases and aborted cases are retained separately. Candidate 2 starts extra factory construction when stored metal exceeds the smaller of 400 metal or 60% of storage, with sufficient income/energy; native streaming pays the rest. A regression case uses 350 metal in 500 storage. The complete 32-case training set is restarted from this new source snapshot.
