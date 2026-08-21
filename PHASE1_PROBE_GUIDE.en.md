[한국어](PHASE1_PROBE_GUIDE.md) | English

# PHASE1_PROBE_GUIDE.md -- probe selection and K grading

This file is **policy**. It subdivides Phase 1 of `CLAUDE.en.md` and is shared by
every project. Progress is never recorded here -- state lives in each project's
`background.md`.

**Within the scope `CLAUDE.en.md` delegates to this file** (node selection, probe
grading, grade propagation, the column layout of the diagnosis table) **this
file is authoritative.** Outside it, `CLAUDE.en.md` wins in a conflict.

What is **not** fixed here (all of it is in `CLAUDE.en.md` Phase 1 and is not
repeated): the definitions of the knowledge scale K0-K3, the question budget
(items per turn, total turns), the language and typesetting constraints on
probes, the procedure for fixing the baseline, the depth table (usage x K
grade -> L).

What **is** fixed here: which node to ask about, how to turn an answer into a
grade, how to fill in the grade of a node never asked about.

---

## 1. Two principles

**Ask only when it changes the curriculum.** Diagnosis is not an exam. A node
whose final depth is the same whatever the answer is not asked about. The value
of one question is measured by whether its answer moves an L.

> Better to spend a question resolving one uncertainty the curriculum hangs on
> than to measure an irrelevant node precisely.

A high grade needs evidence. But **grading low is not free either.** The idea
that lowering a grade errs on the safe side is wrong. Lowering a K means (a)
material the reader already knows gets written out again (in direct conflict
with the objective in `CLAUDE.en.md` §1 and with the prohibitions), and (b) that
much space comes out of the L4 items that actually needed it.

---

## 2. There are three K's. Do not mix them

| Name | Meaning | Source |
|---|---|---|
| **Direct evidence** | A probe response, or the user naming a grade themselves | Asking |
| **Graph inference** | The cap the edges permit (§3) | Propagation |
| **Final K** | The value Phase 2's depth decision and Phase 4's do-not-re-explain judgement actually use | Below |

The rule for fixing it:

1. **If there is direct evidence, that is the final value.** It is not cut down
   by graph inference.
2. If there is no direct evidence and the graph gives a cap, use that value.
   Write `inherited` in the grounds column.
3. If there is neither, grade conservatively from the neighbouring nodes. Write
   `estimated` in the grounds column. Phase 2 may adjust it.
4. If direct evidence and the cap disagree, see §4.

**A measured value and an inferred value are never mashed into one cell.** The
K column of `background.md` is also used by Phase 4's "do not re-explain
anything at K2 or above". Recording a node whose evidence says K2 as K1 for
graph reasons turns that file into a document saying it is fine to explain
again what the user already knows. The reason 2 and 3 are distinguished in the
grounds column is the same -- a value that came from a cap changes when the cap
changes, while a conservative default inherited no grounds at all.

---

## 3. What propagates along an edge

**The vocabulary of direction is fixed here, once.** On the edge "to understand
A you need B", B is called A's **prerequisite** and A is B's **dependent**.
This file, `CLAUDE.en.md` and `background.md` use only those two words --
"higher/lower" is not used, because it reads in exactly opposite ways depending
on which side one takes to be fundamental and which advanced.

That one sentence mixes two things of different character, and different
amounts propagate along them. **The kind is written on each edge in Phase 0**
(`CLAUDE.en.md` §0-3).

| Edge | Meaning | Example |
|---|---|---|
| **Definition edge** | The prerequisite appears *inside the dependent's statement*. Without it the statement cannot be written precisely | intersection form -> Zariski decomposition |
| **Proof edge** | The prerequisite is used *only in the dependent's proof*. The statement reads without it | Serre duality -> Kodaira vanishing |

Propagation comes in two kinds running in opposite directions. **Do not mix
them.**

### 3-1. Propagation of the cap (prerequisite low, toward the dependents)

- **Definition edge:** if the prerequisite is K1 or below, do not grade its
  dependent K2 or above (unless the dependent has direct evidence).
- **Proof edge:** it constrains K3 only. For a dependent to be K3 the
  prerequisite must be K2 or above. There is no constraint at K2 or below --
  stating and applying a theorem precisely without knowing its proof is normal,
  not a defect, and the depth table already handles it (B x K2 -> L1).
- **It travels exactly one step.** As far as the immediate dependent. It is not
  pushed transitively to the end -- push it and one failed probe at the root
  lifts everything below it to L3-L4, and `TOTAL_PAGE_BUDGET` collapses on the
  spot. If something two steps down matters to the curriculum, ask about that
  node directly; otherwise leave it as `estimated`.
- If there are several prerequisites, use the lowest cap among them (definition
  edges only).
- Nodes that merely share a prerequisite do not propagate to each other. One
  branch's failure does not travel to a branch it shares no edge with.

### 3-2. Positive inheritance (prerequisite K2 or above, toward the dependents)

Follow "Search strategy" in `CLAUDE.en.md` -- if a prerequisite is K2 or above,
assume the nodes depending on it are K2 and spot-check exactly one of them.
**There is no one-step limit here.** This is not a cap the graph enforces but a
way of saving the question budget, and the spot-check is the safety device. If
the spot-check fails, drop the assumption and go down toward the prerequisites
of that branch to find where it breaks.

---

## 4. When they disagree -- the dependent grades higher than its prerequisite

Common, and usually a sign not of a defect in the user but that **our graph is
wrong.** The cause is one of three.

1. Black-box fluency -- they write the statement precisely but do not know the
   grounds. The depth table already handles it.
2. What we took for a definition edge was in fact a proof edge. Fix the edge
   kind (§3).
3. The probe measured something else. Check "Answers not used as grounds for a
   grade" in §6.

In every case, **do not cut the direct evidence down.** If writing that node
thin still feels unsafe, **raise the depth by one step, not the K.** There is
already a procedure for writing the reason and getting approval (the exception
to the depth table in `CLAUDE.en.md`). Unlike manipulating a K, this leaves a
trace and does not break Phase 4's do-not-re-explain judgement.

---

## 5. What to ask about

**Ask first** (the more of these it satisfies, the earlier):

1. C/D nodes used directly in the paper's central argument.
2. Nodes whose final depth changes a lot with the K grade -- especially **the
   K1/K2 boundary.** That is where one cell of the table separates two grades.
   The K2/K3 boundary also moves things by one step under any tag, but the tag
   where that one step changes the length a lot is D.
3. A node that is the prerequisite of several important dependents (one
   question fills several cells).
4. The node whose current grade is most uncertain.
5. A node on the prerequisite side, where one answer can fix the cap over a
   wide range.

**Do not ask about:**

- **A-tagged nodes (background mention).** In the table, A is L1 at K1 and L0 at
  K2 -- the answer changes one paragraph, and the question budget is not spent
  on one paragraph.
- Baseline items. Those are already fixed as "assumed and not taught".
- Nodes whose final depth is the same whatever the answer.
- Nodes that already have direct evidence. Do not repeat follow-up questions to
  measure more precisely.
- Nodes whose cap is already fixed because a definition edge's prerequisite was
  graded low. **Do not ask to reconfirm a cap already fixed.**

---

## 6. Probe design and grading

A good probe measures exactly one ability the paper actually demands, requires
performance rather than self-report, and decides the boundary it aims at.

| Boundary | What it looks at |
|---|---|
| K0/K1 | Whether the key definitions, theorems and notation are recognised. Recognition is enough |
| K1/K2 | **The most important boundary.** Not whether the theorem is remembered, but whether it is actually applied in the typical situation the paper uses |
| K2/K3 | Whether the core structure of the proof or argument, not the result, can be reconstructed. Asked mainly at D nodes |

- **One probe requires exactly one prerequisite.** If two or more are engaged
  at once there is no telling which failed, and that answer is grounds for no
  node at all.
- **The boundary names in the table above are ours. They do not go in the
  item.** "This tests the K1/K2 boundary" or "this node is D" means nothing to
  the user. If something is to be disclosed, write in plain language what the
  answer changes in the textbook -- "your answer decides whether this theorem is
  quoted as a statement or explained with an example" (use the correspondence
  table in `CLAUDE.en.md`, "How to talk to the user").
- Do not round a partial answer up. "I remember being able to do it" is K1, not
  K2.
- **No answer is not K0; it is no evidence.** If the curriculum hangs on it,
  reissue it in a different form next turn (a partial answer followed by a
  reissue has in fact settled a K0). If it does not, leave it as `estimated`.
- **Self-assignment.** If the user names a grade themselves, use it as direct
  evidence and write `self-assigned` in the grounds column. But saying "I know
  it" is not self-assignment (`CLAUDE.en.md`).

**Answers not used as grounds for a grade:**

- A misunderstanding caused by a difference of notation or terminology.
- A pure arithmetic slip where the core concept was right.
- An item that required several prerequisites at once.
- A probe that demanded knowledge outside the budget.
- A case where the mathematics cannot be judged because of English expression --
  it is fine to ask for the explanation again in Korean. An English grammar
  error is not itself a gap in knowledge.

---

## 7. Recording -- `background.md`

**The column layout is authoritative here.** At minimum, record the following
per node.

| ID | Node | Usage | Probe | Direct | Inferred | Final K | Depth | Grounds | Why selected |
|---|---|---|---|---|---|---|---|---|---|
| N01 | | C | Q1 | K1 | — | K1 | L3 | probe | K1/K2 boundary |
| N02 | | D | Q4 | K2 | K2 | K2 | L3 | probe | key prerequisite |
| N03 | | B | — | — | K1 | K1 | L2 | inherited (N01, definition) | — |

- **Grounds = where the final K came from.** Vocabulary: `probe` /
  `self-assigned` / `inherited` / `estimated` / `baseline` / `paper-specific`
  (not a prerequisite but a definition or term of the paper itself). For
  `inherited`, also record from which node and along which edge.
- **Why selected = why that node was asked about.** Vocabulary:
  `key prerequisite` / `C-D application` / `K1/K2 boundary` / `K2/K3 boundary` /
  `large curriculum impact` / `uncertain` / `spot-check`. A short phrase is
  enough. Leave it blank for nodes not asked about.
- Do not merge direct, inferred and final into one cell (§2). **Leave the
  direct column empty for nodes not asked about** -- recording a cap as though
  it were direct evidence means the disagreement of §4 is never seen.
- The nodes asked about and those not asked about may be split into two tables
  (the template does that). The columns mean the same thing either way.

---

## 8. Ending

Phase 1 ends when the following hold. **Grading every node is not the goal.**

- The baseline is fixed.
- The K boundaries the curriculum hangs on have been checked.
- The key C/D nodes have direct evidence.
- The rest are filled by graph inference or a conservative default, and that
  fact is recorded in the grounds column.

Once the budget is reached, stop asking. Handle the remaining uncertainty in
the order of §2, and design Phase 2 so that the prerequisite in question is
explained sufficiently.

---

## Prohibitions (Phase 1 only)

- **Cutting direct evidence down by graph inference.** Disagreement is handled
  by §4.
- **Propagating a cap transitively.** One step toward the dependents (§3-1).
  Positive inheritance is not subject to this limit (§3-2).
- Self-report questions of the "do you know X?" form (`CLAUDE.en.md`).
- **Exposing grade, boundary or tag codes as they are in an item or in the
  grading explanation** (§6, `CLAUDE.en.md`, "How to talk to the user"). Even when
  reporting a grade, not "I'll put you at K1" but "I'll take it as recognising
  the statement without being able to use it precisely (K1)".
- Exceeding the budget on the grounds that "one more item would make it
  precise".
- **Self-reflection turns.** Do not spend a turn deciding "have I missed a
  prerequisite?" or "does this answer mean I should ask about something else?".
  Each turn's candidate questions come only from the fixed criteria of §5.
- Recording measured and inferred values without distinguishing them.
