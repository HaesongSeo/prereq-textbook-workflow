# Knowledge diagnosis table

> Phase 1 output. Used by Phase 2's depth decision and Phase 4's
> do-not-re-explain judgement. The rules for filling it in are in `CLAUDE.en.md`
> Phase 1 and in `PHASE1_PROBE_GUIDE.en.md`.

## Baseline (assumed and not taught)

The items below are not probed, and the textbook does not explain them -- it
only cites them.

### A. (group name)

- [ ] A1.
- [ ] A2.

### B. (group name)

- [ ] B1.

Date fixed / user's confirmation:

> If a group was removed from the baseline, do not delete it -- leave it with
> the reason.

## The knowledge scale

<!-- SSOT-COPY: k-scale -->

| Grade | Meaning |
|---|---|
| K0 | Never heard of it |
| K1 | Recognises the statement but cannot use it precisely |
| K2 | Can state it precisely and compute or apply with it |
| K3 | Can reconstruct the proof |

## Diagnosis results

> The final depth is the value obtained by applying `CLAUDE.en.md` Phase 2's
> "depth table" (usage x K grade).
>
> **Record the three K's separately.** `PHASE1_PROBE_GUIDE.en.md` §7 is
> authoritative on the column layout. `direct` = the value from a probe
> response or the user's self-assignment / `inferred` = the cap the edges
> permit / `final` = the value Phases 2 and 4 actually use.
> **If there is direct evidence, that is the final value. It is not cut down by
> inference.**
> Leave the `direct` column empty for nodes not asked about.
>
> In the grade columns write only the codes -- `direct`, `inferred` and
> `final K` take `K0`-`K3`, `final depth` takes `L0`-`L4`, `usage` takes
> `A`-`D`. A short qualifier (`K2 or above`, `baseline`) is fine (`CLAUDE.en.md`, "How
> to talk to the user"; `md-check.sh` item 8).

### Turn 1 results

| Node ID | Node | Usage | Probe summary | Response | Direct | Inferred | Final K | Final depth | Grounds | Why selected |
|---|---|---|---|---|---|---|---|---|---|---|
| N01 | | | | | | | | | | |

> Vocabulary for "why selected": `key prerequisite` / `C-D application` /
> `K1/K2 boundary` / `K2/K3 boundary` / `large curriculum impact` /
> `uncertain` / `spot-check`.

### The remaining nodes, filled in without asking

> Do not ask exhaustively. They are filled by two routes
> (`PHASE1_PROBE_GUIDE.en.md` §3). On the edge "to understand A you need B", B is
> A's **prerequisite** and A is B's **dependent**.
>
> **Positive inheritance** -- if a prerequisite is K2 or above, assume the nodes
> depending on it are K2 and spot-check just one (`CLAUDE.en.md`, "Search
> strategy"). **Propagation of the cap** -- if a definition edge's prerequisite
> is K1 or below, do not grade its immediate dependent K2 or above. **It travels
> exactly one step** (it is not pushed two steps down). A proof edge constrains
> K3 only.

| Node | Usage | Inferred K | Final depth | Grounds (from which node, along which edge) |
|---|---|---|---|---|
| | | | | |

> Vocabulary for "grounds": `probe` / `self-assigned` / `inherited` /
> `estimated` / `baseline` / `paper-specific` (not a prerequisite but a
> definition or term of the paper itself).

### Nodes where direct evidence came out above the inferred cap

> Common, and usually a sign not of a defect in the user but **that the graph is
> wrong** (`PHASE1_PROBE_GUIDE.en.md` §4). Do not cut the direct evidence down;
> record the cause as one of three -- black-box fluency / taken for a definition
> edge but actually a proof edge / the probe measured something else.
> If writing it thin feels unsafe, **raise the depth by one step**, not the K,
> and get it approved under "Exceptions to the depth table" in `spec.md`.

| Node | Direct | Inferred | Cause | How it was handled |
|---|---|---|---|---|
| | | | | |

## Turn log

| Turn | Date | Nodes asked about | Result |
|---|---|---|---|
| 1/6 | | | |

## Overall diagnosis

- The heaviest places:
- The light places:
- L4 nodes:

## Open / needs re-checking

> **Only what still has work to do.** Delete it as soon as it is resolved and
> move it to "Update history" below.

-

## Update history

> This file is a **Phase 1 output**. The K grades and final depths are
> diagnosis results, so they do not change during Phase 4. The tables above are
> frozen as the record of that moment.
> **Depth exceptions arising during writing, and the actual page counts, are
> authoritative in `spec.md`'s Amendments and in `progress.md`.**
>
> A node's *description* turning out to be wrong during writing or close
> reading is common (inferring a cited paper's content from its title, then
> finding the real thing differs, and so on). Record it here even when the K
> grade does not change.

| Date | What changed |
|---|---|
| | |
