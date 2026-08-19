[한국어](CLAUDE.md) | English

# CLAUDE.md -- a custom LaTeX textbook for reading one paper

This file is **policy**. Project progress is never recorded here. State lives
in `spec.md`, `background.md` and `progress.md`, and **at the end of every turn
whatever changed that turn is written into those three files before the reply
ends.** It is not deferred to the next turn (if the session drops, that turn's
work is unrecoverable). If there is nothing to record, say so and move on.

---

## 0. Project Config

**This file sits at the `Study/` root and is shared by every project.** The
config therefore goes not here but **at the top of each project's `spec.md`**.
Below are the definitions of the fields; no values are filled in here.

| Field | Meaning |
|---|---|
| `TARGET_PAPER` | Authors, title, publication data |
| `SOURCE` | arXiv ID / DOI / local PDF path |
| `OUTPUT_LANGUAGE` | Default **English**. Output under `tex/` is written in English and typeset with pdflatex. The management documents (spec/background/progress) and the conversation stay in Korean |
| `TOTAL_PAGE_BUDGET` | **The cap on the sum of the preparatory chapters (Part I).** Phase 5's close-reading pages are not counted here (see Phase 2, "The length of Part II"). E.g. 140 pages |
| `PER_CHAPTER_MAX` | The cap on a single chapter. **It applies both to preparatory chapters and to close-reading sections.** E.g. 15 pages |
| `BASELINE_HINT` | The floor of assumed knowledge. Fixed by probes in Phase 1 |

If the config in that project's `spec.md` is empty, **do not start Phase 0 --
ask first.**

---

## 1. Objective

Build a LaTeX textbook that teaches **only the mathematics actually needed** to
understand the target paper.

- The curriculum is decided by the paper, not by the subject.
- Where completeness and relevance conflict, **relevance always wins**.
- What the user already knows is not written. What they do not know is written
  only to the depth the paper requires.
- This is a long-running conversational project. Every session must build on
  the last.

---

## How to talk to the user (applies in every phase)

**The grade codes are our working apparatus, not the user's.** `K0`-`K3`,
`L0`-`L4`, the usage tags `A`-`D`, the edge kinds (definition/proof), node IDs
(`N01`) and baseline item numbers all have meaning only inside this file,
`PHASE1_PROBE_GUIDE.md`, and the management documents. The user does not have
those files open while talking. So holding out a bare code in the chat conveys
nothing.

> **Bad:** "Since this is a D node, the K2/K3 boundary separates L3 from L1."
>
> **Good:** "This theorem is one whose proof technique the paper imitates. If
> you can reconstruct the proof, we quote the statement and move on; if you can
> state and apply it but no more, we include examples and computations. So your
> answer here changes this chapter by a few pages."

There is one rule. **Write the meaning in plain language first, and attach the
code only as a parenthetical** -- "can reconstruct the proof (K3)". This is not
an instruction to abolish the codes. In the management documents the codes are
authoritative, and if the user asks in codes, answering in codes is fine. What
is forbidden is **demanding a judgement from the user with a code as the only
grounds for the sentence.**

The three places where this bites:

- Issuing a probe. Not "this item tests the K1/K2 boundary", but one line on
  what the answer changes in the textbook.
- The end-of-phase summary and the request for approval. Codes inside a table
  are fine. But the sentence asking for approval has to read without the table.
  Never attach a table full of codes and end with "please approve."
- Talking about length. Depth is always better expressed in pages. What the
  user actually judges is not a grade but paper.

### The words to use in conversation

| Code | In conversation |
|---|---|
| K0 | Seeing it for the first time |
| K1 | Recognises the statement but cannot use it precisely |
| K2 | Can state it precisely and apply it |
| K3 | Can reconstruct the proof as well |
| L0 | Not included (notation is aligned if needed) |
| L1 | The statement and its source only |
| L2 | The statement plus how the paper uses it |
| L3 | And examples and computations on top |
| L4 | Everything, proof included |
| A | Mentioned as background, never used in the argument |
| B | Only the statement is borrowed |
| C | Applied while checking the hypotheses |
| D | The proof technique itself is imitated |
| definition edge | A prerequisite without which the statement cannot even be written |
| proof edge | A prerequisite the statement reads without, but the proof needs |

### This rule applies to the chat only

**The mistake in the other direction is worse** -- dragging this rule into the
management documents and spelling the codes out in prose. The rule differs by
place, and the three are never mixed.

| Place | Rule |
|---|---|
| Management documents (`spec.md`, `background.md`, `progress.md`, `refs/NOTES.md`) | **The codes are authoritative.** In the usage / direct / inferred / final K / depth columns write `A`-`D`, `K0`-`K3`, `L0`-`L4` **as they are**. Do not even set a plain-language gloss beside them |
| The chat | Plain language first, codes in parentheses (above) |
| The book (`tex/`) | The codes do not appear at all, not even in parentheses (see Phase 4, "Chapter header") |

The reason is not taste. The depth table is a lookup table and "do not
re-explain anything at K2 or above" is a judgement that reads the K column
mechanically, so neither holds once a grade is written as a sentence.
`md-check.sh` item 8 checks this -- a short qualifier like `K2 이상` passes, a
plain-language gloss set beside the code does not.

Where plain language belongs in the management documents is the prose
sections, not a table's grade column -- "Overall diagnosis", the reason column
of Amendments, notes under a table. Even there, do not delete the code; leave
it next to the prose.

---

## 2. File layout and the session protocol

### At the start of a session (no exceptions)

1. Read `progress.md` -- fix the current phase and the next action from **the
   state block at the top**, then read the prose of "Current state"
2. Read `spec.md` -- the curriculum plan and the amendment log
3. Read `background.md` -- the user's knowledge table
4. Only then start work. No mathematics is written before those three are read.

### The state block (top of `progress.md`)

`progress.md` begins with **YAML front matter**. The point is to make resuming
a session a matter of reading values, not interpreting prose.

```yaml
---
phase: 4                       # 0-6
phase_status: in_progress      # in_progress | awaiting_approval | done
last_approved: "2026-08-15 Ch07"
next_action: "Ch08 (V01-V07) 집필"
chapters_approved: [01, 02, 03, 04, 05, 06, 07]
sections_approved: []          # Phase 5's paper/secNN
---
```

- **This block is authoritative for `phase`, `last_approved` and the list of
  approved chapters.** The prose of "Current state" is a summary for a human
  and carries what the block cannot (reading order, the do-not-re-explain list,
  why work stopped). **It does not write the same fact twice; it writes
  different things.**
- **On approval, update three places in the same turn** -- this block, the
  "Approval log", and the approval column of "Chapter status". `md-check.sh`
  items 7 and 9 check that the three agree.
- If `phase_status` is `awaiting_approval`, **the next session confirms the
  approval first.** No work on the next phase begins without it.

### Directory layout

```
Study/
  CLAUDE.md          # policy (Korean), near-immutable, shared by all projects
  PHASE1_PROBE_GUIDE.md  # Phase 1 detail policy (probe selection / K grading). Shared
  README.md
  CLAUDE.en.md           # this file: the English edition of the three above
  PHASE1_PROBE_GUIDE.en.md
  README.en.md
  TRANSLATIONS           # which revision of the Korean each English file renders
  translation-check.sh   # checks whether the Korean moved and left the English stale
  Source/            # the template copied wholesale to start a new project
  Source-en/         # the same template in English. Copy this one to work in English
  <project>/
    spec.md          # Project Specification (Phase 0 output) + Project Config
    background.md    # knowledge diagnosis table (Phase 1 output)
    progress.md      # current stage / approval log / measured length / session history
    md-check.sh      # checker for the management documents
    refs/
      NOTES.md       # authority on what has been obtained + how to read each PDF
      *.pdf          # the sources obtained
    tex/
      .latexmkrc
      check.sh       # non-ASCII scan + clean-room build + log inspection
      notation-check.sh
      import-check.sh  # drift detection for chapters forked from another project
      IMPORTS          # their origins and the hashes at the point of forking
      IMPORT-HEADER.txt # the form of the provenance block put at the top of a forked file
      <paper>-check.sh # source theorem-number checker (written per project)
      main.tex
      preamble.sty   # packages, theorem environments, verification macros
      notation.sty   # notation macros (following the target paper)
      refs.bib
      chapters/ch01-<slug>.tex
      paper/sec01-<slug>.tex     # Phase 5 output
      front/preface.tex          # preface (Phase 6 output)
      back/appendix-*.tex        # tables the reader needs (notation map, source errata)
```

**A new project starts by copying `Source/`.** Do not reinvent what the
template already contains -- the session-start procedure, the checker scripts,
how length is measured, how scans are handled, the form for recording what has
been obtained.

---

## 3. Overview of the phases

| Phase | Name | Output |
|---|---|---|
| 0 | Obtain and analyse the paper | `spec.md` |
| 1 | Background diagnosis | `background.md` |
| 2 | Curriculum design | The chapter plan in `spec.md`, fixed |
| 3 | Obtain the references | `refs/`, `refs.bib` |
| 4 | Write the textbook | `tex/chapters/` |
| 5 | Read the paper closely | `tex/paper/` |
| 6 | Finish the book | Verification-mark policy, exhaustive checks, preface and appendices |

- Phases are not skipped.
- At the end of each phase section there is an **"Exit conditions" checklist**.
  **Ask for approval only after all of them are satisfied.** If any is empty,
  say so first and ask the user whether to proceed -- never pass over it
  quietly.
- At the end of each phase, present **(a) a summary of the result, (b) the open
  questions, (c) the request for approval**, then stop. **All three must read
  without grade codes** (see "How to talk to the user").
- Approvals are recorded in `progress.md` with the date (see §2, "The state
  block").

---

## Phase 0 -- obtain and analyse the paper

### 0-1. Obtaining the source (a hard prerequisite)

- Obtain the **full text** of the paper. Search arXiv / the journal page and
  fetch it.
- Analysis never starts from an abstract, a review, or memory. If the full text
  cannot be obtained, ask the user for the PDF and **wait**.
- Record what was obtained in `refs/`.

### 0-2. Analysis

Extract the following from the paper.

- The prerequisite topics actually used
- Definitions and notation
- The main theorems
- Among the cited results, **only those the paper's argument actually uses**

### 0-3. The minimal dependency graph

- Node = a prerequisite concept or theorem. Edge = "to understand A you need B".
- Tag every node with **how the paper uses it**, A-D (see the depth rules).
- **Write the kind on every edge** -- `definition` (B appears *inside A's
  statement*) / `proof` (B is used *only in A's proof*). Phase 1's grade
  propagation only holds on top of this distinction (`PHASE1_PROBE_GUIDE.md`
  §3). Attaching it later means re-reading the whole graph.
- Do not survey hidden assumptions and omitted proofs at this stage. They are
  handled on arriving at the section in question.

### 0-4. Output -- `spec.md`

- The dependency graph (text or TikZ)
- The prerequisite checklist (node list + usage tags)
- The notation glossary (in the paper's notation)
- Candidate references
- A proposed chapter outline

After approval, `spec.md` **is not changed except through the amendment
procedure.**

### 0-5. Exit conditions

- [ ] The **full text** was obtained and recorded in `refs/NOTES.md` (for a
      scan, including how to read it)
- [ ] All six Project Config fields are filled in `spec.md`
- [ ] **Every node carries a usage tag** (A-D)
- [ ] **Every edge carries its kind** (definition/proof) -- attaching it later
      means re-reading the whole graph
- [ ] The notation glossary is written **in the paper's notation**
- [ ] A proposed chapter outline exists

---

## Phase 1 -- background diagnosis

Goal: grade every node `K0/K1/K2/K3`.

**Read `PHASE1_PROBE_GUIDE.md` when starting Phase 1.** That file is
authoritative on which node to ask about, how to turn an answer into a grade,
and how to fill in the nodes never asked about. What follows is the skeleton it
presumes.

### The knowledge scale

<!-- SSOT-CANON: k-scale -->

| Grade | Meaning |
|---|---|
| K0 | Never heard of it |
| K1 | Recognises the statement but cannot use it precisely |
| K2 | Can state it precisely and compute or apply with it |
| K3 | Can reconstruct the proof |

### Rules for asking

- **No self-report questions** such as "do you know X?". Issue a **probe**
  instead.
  - Bad: "Do you know sheaf cohomology?"
  - Good: "Which hypothesis is missing from the following theorem: ..." /
    "Compute $H^1$ in this example." / "Why is this statement false?"
- Probes and other mathematical questions are issued in English. The commentary
  and the grading explanation stay in Korean.
- **Formulas in the chat are not typeset.** Raw $\LaTeX$ in a probe does not
  read, so once a formula runs past two lines or the subscripts pile up, write
  it out in plain symbols (`H^1(X, N) -> H^1(X, Omega)`). If that still fails,
  typeset it as `.tex` and hand over a PDF.
- Every probe must be answerable in five lines or fewer.
- **Do not put the grade names in the item.** Write in plain language what the
  answer changes in the textbook (see "How to talk to the user",
  `PHASE1_PROBE_GUIDE.md` §6).
- At most five questions per turn, at most six turns for all of Phase 1.
- If the user only says "I know it", do not raise them to K2 or above. Have
  them answer a probe or name the grade themselves.

### Search strategy (saving the question budget)

The vocabulary of direction. On the edge "to understand A you need B", B is A's
**prerequisite** and A is B's **dependent**. "Higher/lower" is not used: it
reads in exactly opposite ways.

- **Ask about the prerequisite side first.** That is where one answer fills the
  most cells.
- If a node is K2 or above, **assume the nodes depending on it are K2** but
  spot-check exactly one of them. If the spot-check fails, drop the assumption
  and **go down toward the prerequisites** of that branch to find where it
  breaks.
- If a node is K1 or below, **go down to its prerequisites.**
- That is, bisect on the graph. Do not ask exhaustively.
- **`PHASE1_PROBE_GUIDE.md` is authoritative on propagating a low grade toward
  the dependents, on what to do when direct evidence and inference disagree, on
  the priority for choosing nodes, and on grading probes.** None of that is
  repeated here.

### Fixing the baseline

- At the start of Phase 1, propose a list for **the floor of "knowledge assumed
  and not taught"** and get the user's confirmation.
- Items below the baseline are **neither probed nor written about.** They are
  only cited.
- The baseline is recorded at the top of `background.md`.

### Output -- `background.md`

For each node, **record direct evidence / graph inference / the final K
separately.** A measured value and an inferred value never share a cell -- this
file's K column is also what decides "do not re-explain anything at K2 or
above" in Phase 4, so which one it was has to remain recoverable.

**`PHASE1_PROBE_GUIDE.md` §7 is authoritative on the column layout.** It is not
repeated here.

### Exit conditions

**`PHASE1_PROBE_GUIDE.md` §8 is authoritative.** Not repeated here.

---

## Phase 2 -- curriculum design

### Depth grades

| Grade | Level of treatment |
|---|---|
| L0 | Excluded. Notation mapping only (if needed) |
| L1 | Statement + reference |
| L2 | Statement + an account of how the paper uses it |
| L3 | L2 + examples and computations |
| L4 | L3 + a complete proof |

### How the paper uses it

| Tag | Meaning |
|---|---|
| A | Background mention only, not used in the argument |
| B | Cited as a black box (only the statement is borrowed) |
| C | Applied while checking and manipulating the hypotheses |
| D | The proof technique itself is imitated or varied |

### The depth table (usage x knowledge grade -> depth)

<!-- SSOT-CANON: depth-matrix -->

|   | K0 | K1 | K2 | K3 |
|---|---|---|---|---|
| **A** | L1 | L1 | L0 | L0 |
| **B** | L2 | L2 | L1 | L0 |
| **C** | L3 | L3 | L2 | L1 |
| **D** | L4 | L4 | L3 | L1 |

- Departing from this table **requires a written reason and approval.**
- If a further prerequisite turns out to be needed, it goes through this table
  too. Always take the **minimal sufficient set.**
- When presenting the chapter plan to the user, speak not in this table's codes
  but in "what gets written, and how far" and "how many pages" (see "How to
  talk to the user"). Attaching the table is fine, but the sentence asking for
  approval must read without it.

### The page budget

- Record a target page count per chapter in `spec.md`. The sum **for the
  preparatory chapters** does not exceed `TOTAL_PAGE_BUDGET`.
- If the budget looks likely to be exceeded, report it before writing and
  propose which item's depth to lower.
- **`TOTAL_PAGE_BUDGET` covers only the preparatory chapters (Part I).**
  Phase 5's close-reading pages are not subject to a budget (see "The length of
  Part II" below).

#### How to set the page target -- **count items, not K grades**

Setting it as "this node is K0, so it will be thick" misses badly. The K grade
does not fix the length directly -- even at K0, if the usage is B the depth is
L2, and all L2 can hold is the statement and the role.

**What fixes the length is the number of items a node produces.** An item = a
numbered definition, theorem, proposition, lemma, corollary, example or remark
in the text.

**Step 1. Count the items per node.** Count them directly from the Phase 0
graph and the paper.

- The number of statements the paper actually uses at that node (this is the
  floor)
- The number of definitions that must be set up first to state them
- The number of examples and computations the depth grade permits

**Step 2. Adjust the item count by depth grade.** Depth fixes *the number of
items*, not *their length* -- this is the crux, and the easy place to go wrong.

| Depth | Effect on the item count |
|---|---|
| L1 | The number of statements the paper uses, and no more. No examples added |
| L2 | Plus an account of the role (not an item). At most one example added |
| L3 | Up to one example or computation per item. Roughly **1.5-2x L2** |
| L4 | **A proof does not add an item.** It goes inside an item that already exists |

**That L4 is long is an illusion.** What L4 demands is a complete proof, not
length.

**Step 3. Correct by K grade -- on the item count, and slightly.** The K grade
has already been taken into account once through the depth table, so only the
remainder is considered here.

| K grade | Correction |
|---|---|
| K0 | **+2-3 items.** A definition and a first example have to be set up |
| K1 | **+1 item.** The statement is known so the definition is short; one example where "cannot use it precisely" bites |
| K2 or above | **0 items.** Cite it and move on ("do not re-explain") |

**Step 4. Pages = item count / 2.5.**

#### The length of Part II (close reading) -- **use the source section's page count as it is**

The four steps above are for the preparatory chapters. They do not apply to
Phase 5's sections -- what gets written there is not items we chose but **what
the paper has already written.**

**A section's target page count = that section's page count in the source.**

- This value is **a reference, not a budget.** `TOTAL_PAGE_BUDGET` covers only
  the preparatory chapters, so there is no cap judgement on the Part II total.
  The source's page count is the effective cap, so it does not run away even
  without a separate budget.
- The measured value departs from the target, and that is normal. A section the
  preparatory chapters have already prepared for gets shorter; a section the
  paper wrote compactly gets longer.
- Even if a source section exceeds `PER_CHAPTER_MAX`, do not split it in
  advance in Phase 2. Where to split only becomes visible on reading it. Decide
  then and split into `sec05a` / `sec05b` (Phase 5, "The number in the file
  name").
- The target goes in `spec.md` under "Phase 5 (close reading): order and
  length"; the measurement goes in `progress.md` under "Close-reading status".

### Exit conditions

- [ ] **Every node has a final depth** (the table's value, or an approved
      exception)
- [ ] Every departure from the table is in `spec.md` under "Table exceptions"
      **with its reason**
- [ ] The per-chapter page targets were set **by counting items** (not
      estimated from K grades)
- [ ] The sum of the **preparatory chapters'** targets is within
      `TOTAL_PAGE_BUDGET`
- [ ] Each chapter is within `PER_CHAPTER_MAX`
- [ ] If the budget was exceeded, **a proposal for which item's depth to lower**
      was made (before writing)
- [ ] Every section in the close-reading scope has **the source page count as
      its target** (`spec.md`, "Phase 5: order and length")

---

## Phase 3 -- obtain the references

### Priority

1. Material the user supplied
2. The paper itself
3. Standard graduate textbooks
4. Trustworthy lecture notes
5. Other public material

### Rules

- **Search; do not rely on memory.** Explicitly search and fetch from arXiv /
  MathSciNet / the author's home page.
- To cite a theorem number, **confirm the actual source first.** Never write a
  number without confirming it.
- If an important reference cannot be obtained, **do not guess** -- ask the user
  whether they can supply it.
- `refs.bib` holds only entries that are actually cited.

### Exit conditions

- [ ] Every candidate reference in `spec.md` has either **been obtained or been
      recorded as not obtained**
- [ ] Each obtained work has its provenance in `refs/NOTES.md`. **For a scan,
      how to read it and the page correspondence too**
- [ ] Theorem numbers to be cited were **checked against the real document**
      (no number written from memory)
- [ ] For keys where the same author has several papers, **the identification
      was fixed from the rendered output**
- [ ] No working notes in the `note` field of `refs.bib` (it gets printed)
- [ ] Formulas and proper nouns inside titles are protected by braces, and
      `main.bbl` was read by eye
- [ ] Works not obtained are recorded **together with whether they can be
      substituted**, and if a statement cited from such a work appears in the
      text it is marked `\UNVERIFIED{}` **naming which work was not seen** (see
      the three states in the verification rules)

---

## Phase 4 -- writing the textbook

Begins only after Phases 0-3 are approved. Write **one chapter at a time** and
get approval.

### Chapter header (shown at the top of the chapter)

- Purpose
- Assumed prerequisites (written **from** `background.md`, without pointing at
  that file)
- Which part of the paper it supports (section number)
- What is proved, and how far

**The book never points at the management documents.** The depth grades
(L0-L4), node IDs, baseline item numbers, phase numbers, and
`spec.md`/`background.md`/`progress.md` are all our working apparatus, not the
reader's. The header's last item is written in plain language too, not in
codes -- "the statement and its role are given; nothing is proved". Where a
grade served as *the grounds for an omission* ("we stop here because it is
L2"), do not delete it: rewrite the grounds in plain language ("we stop here
because only the statement is quoted").

### Writing principles

- The register of graduate lecture notes.
- Motivation -> intuition -> example -> why it is needed. **But only within
  what the depth grade permits.**
  - L1: one or two sentences of motivation. No example.
  - L2: motivation + the role in the paper. At most one example.
  - L3: examples and computations included.
  - L4: proof included.
- Avoid needless abstraction and textbook-style completeness.
- **The notation follows the target paper.** Reading the paper outranks the
  textbook's convenience. Where it differs from standard notation, give the
  correspondence in a footnote.

### Checks before a chapter is final

1. Is every definition, theorem and example introduced **actually used later**?
   Or explicitly justified as "intuition the reader needs"? If neither, delete
   it.
2. Is anything graded K2 or above in `background.md` being re-explained?
3. Is the length within `PER_CHAPTER_MAX`?
4. Does `latexmk -pdf` pass without warnings?
5. Does every theorem carry a source? (see the verification rules)

### Phase exit conditions

The five above are run **per chapter**. Closing the phase is separate.

- [ ] **Every chapter of the plan in `spec.md` is approved**, and the approval
      log, the status table and the front matter agree
- [ ] The **measured** total length is within budget (`progress.md`,
      "Measured length", is authoritative)
- [ ] `sh tex/check.sh` and `sh tex/notation-check.sh` pass
- [ ] If any chapter was imported, it is registered in `tex/IMPORTS` and
      `sh tex/import-check.sh` passes
- [ ] No chapter outside the plan was written (if one was, it is approved as an
      Amendment)

---

## Phase 5 -- reading the paper closely

Proceeds section by section. For each section:

- What that section is for
- An account of the notation
- An account of the new definitions
- Restoration of omitted arguments (only where needed)
- The connection to the chapters written earlier (a real `\ref{}`, not a
  mention)

Hidden assumptions and omitted proofs are not handled in advance; they are
handled on arriving at the section.

### Writing principle -- proofs in `proof`, remarks in remarks

The paper's proofs are moved into a `proof` environment. They are not
reconstructed inside a `remark`. An argument we restored because the paper did
not have it also goes in a `proof` environment, with `\OWNPROOF` attached --
what distinguishes the paper's from ours is the mark, not the environment.

`remark` is used for three things only.

- Connections and background the source omitted
- Traps in the notation or the hypotheses; distinguishing two statements that
  are easy to confuse
- What is unresolved or uncertain

Wrapping an argument in a `remark` breaks two things.

- **The reader cannot tell the paper's argument from our commentary.** A remark
  reads as an aside, so a proof inside one looks like something the paper did
  not actually do.
- The place for `\OWNPROOF` and `\OWNCHECK` disappears. Both marks attach to a
  proof, and once the proof moves inside a remark there is no point at which to
  mark what is ours.

### The number in the file name is the paper's section number

The `NN` in `paper/secNN-<slug>.tex` is **the paper's section number**. The
reading order is fixed by the `\include` order in `main.tex` and by `spec.md`.

Since the close-reading order differing from the paper's order is normal
(`spec.md`, "Phase 5 (close reading): order and length"), numbering the files
by reading order is a possible convention too. If a section runs long enough to
reach `PER_CHAPTER_MAX`, split it into `secNNa` / `secNNb`. Do not create a
section that is not in the paper (a toolbox we assembled, say).

### Exit conditions

- [ ] Every section approved as in scope is in `tex/paper/` and approved
- [ ] Each section **really links** to the earlier chapters with `\ref` (not
      merely in words)
- [ ] Restored arguments carry `\OWNPROOF`; verifications and auxiliary facts
      carry `\OWNCHECK`
- [ ] The **source theorem-number checker** (`tex/<paper>-check.sh`) exists and
      passes -- the build checks nothing about numbers written as plain text
- [ ] Remaining open items are recorded in `progress.md`, "Close-reading status"

---

## Cross-project reuse (import)

A chapter written in one project can be used by another. **This is a fork, not
a copy.** The origin points at its own book's chapters with `\ref` and cites
its own target paper, so it must be adapted on the way in.

The problem is not the adapting but what comes after. The origin can be
corrected and the imported side will never hear about it. So three things are
put in place.

1. A provenance block at the top of the file (a comment, so it is not printed).
   The origin path, the date of the fork, and `ADAPTED:` -- **the list of what
   had to be changed.** That last item is the crux. It becomes the recipe for
   re-importing.
2. `tex/IMPORTS` -- records the origin path and **two hashes**: the sha256 of
   the origin at the point of forking, and the sha256 of our file after
   adaptation.
3. `sh tex/import-check.sh` -- recomputes both and **fails if either moved.**
   It does not merge. If the origin moved, read the diff; **if our side moved,
   write what was changed into `ADAPTED:` or `FIXED:` and update the hash.**
   The checker cannot tell an adaptation from a mathematical correction, so
   that judgement alone is a human's.

### The direction of authority

**The origin is authoritative for the mathematics.**

By way of exception, an error found in the imported copy is **fixed in the copy
only.** That correction is written under `FIXED:` at the top of the file --
`import-check.sh` only watches whether the origin moved, so without writing it
down, the fact that the two write-ups have diverged is recorded nowhere.
The other exception is **adaptation** -- notation, citation keys, outbound
references and the chapter header are meant to differ between the two books and
are not reverted to the origin. That list is `ADAPTED:`.

### As far as the reader is concerned

**The book does not say "this was taken from another project"** (see Phase 4).
That is our working history. But if the two books may circulate together, state
the sharing in one sentence in the preface -- so the reader does not mistake
them for two independent accounts.

---

## Phase 6 -- finishing the book

The book is still a draft when Phase 5 ends. Three things remain, and all three
require approval.

1. The final policy on verification marks. Decide whether the `\OWNPROOF`,
   `\OWNCHECK` and `\uncertain` left conspicuous in the draft survive into the
   final book. **If they do, put a legend in the book** -- a mark that appears
   dozens of times with its meaning written nowhere tells the reader nothing.
   Before deciding, classify every `\OWNPROOF`: filling a gap in a source and a
   plain verification are different in kind, and that distinction shows exactly
   where this book's value sits.
2. The exhaustive check. `\ref` is caught by the build, but **source theorem
   numbers written as text and notation typed by hand are caught by nothing.**
   Build and run the two checkers (`progress.md`, "Checker scripts"). Which
   work each citation key actually renders to is also checked exhaustively at
   this point.
3. The reader-facing front and back matter. The preface (what this book is /
   how the two Parts relate / the reading order and why / the legend of marks),
   and whatever the reader needs from what lived only in the management
   documents (a notation correspondence table across several papers, say),
   moved into appendices.

**Stripping the working apparatus out of the book also happens here** (see
Phase 4, "Chapter header").

### Exit conditions

- [ ] `\OWNPROOF` was **classified exhaustively**, and the final policy on
      verification marks is approved
- [ ] If the marks stay, **there is a legend in the book**
- [ ] The globs of the two checkers (notation, source numbers) are
      **recursive**, and the preface and appendices written later are **inside**
      their scope. It was confirmed what "0 hits" was looking at
- [ ] The citation-key-to-work correspondence was checked exhaustively
- [ ] There is a preface (what this book is / how the two Parts relate / the
      reading order and why / the legend of marks)
- [ ] Whatever **the reader needs** from what lived only in the management
      documents was moved into an appendix
- [ ] If "Source errata" in `spec.md` is not empty, **it went out as a
      reader-facing appendix.** A reader collating against the source needs the
      list in one place
- [ ] Not a single depth grade, node ID, phase number or management-document
      file name remains in the book

---

## Verification rules (apply in every phase)

This section is about the trustworthiness of the mathematics, and it outranks
every other rule.

- **Attach an exact source to every theorem and proposition.** E.g.
  `[Har77, Thm.~III.5.2]`. A citation giving only author and year will not do.
- Do not generate a paper, a theorem number, or a page that does not exist. If
  unsure, search or mark it.
- **First establish which work a citation key renders to.** Where the same
  author has several papers, do not identify a source by author name alone:
  confirm the alpha-label-to-work correspondence in the bibliography of the
  rendered source PDF, then check the section and theorem numbers.
- An argument we supplied because the source has a gap is marked `\OWNPROOF{}`.
  This covers a source that states only the result, compresses the proof into a
  clause, or proves a different statement. Distinguish it from reconstructing
  the source's proof.
- A standard auxiliary fact we stated or proved for verification, for an
  example, or for convenience of exposition is marked `\OWNCHECK{}`. It fills
  no gap in any source, so it is kept less conspicuous than `\OWNPROOF`.
- Computations in examples and counterexamples must be verifiable. An
  unverified computation is marked.

The four macros live in `preamble.sty` (conspicuous in the draft; the final
policy is Phase 6). The trap where one silently disappears in use is in
"Things that break quietly".

### When you are not sure -- three states, kept apart

| State | Mark | What to write in the text |
|---|---|---|
| The source **could not be identified** -- which work, which number, unknown | `\UNVERIFIED{...}` | What could not be found |
| The source was identified but **the document was not consulted** | `\UNVERIFIED{...}` | Name the work that was not seen |
| The document was seen but **our write-up is uncertain** | `\uncertain{...}` | What is uncertain and why |

- The middle row is the crux. **Not having seen the document is "unverified",
  not "uncertain"** -- it is not a problem with our write-up but a fact we
  failed to confirm, and the reader has to be told which work it is so they can
  check for themselves.
- The middle row is linked in both directions with "Not obtained" in
  `refs/NOTES.md`. If it appears on only one side, one of the two is stale.
  When the work is later obtained, fix both places together.
- None of the three is passed over quietly. **An unmarked guess is the worst of
  all.**

---

## Things that break quietly (typesetting and tooling)

If the previous section is the trustworthiness of the mathematics, this one is
the tooling. What they have in common is that **neither a warning nor an error
is produced**, so there is no way to prevent them other than knowing them.

### Typesetting

- **A marking macro that takes an argument is always used with its argument.**
  Leaving a wrapping macro like `\uncertain{...}` alone on a line, as though it
  were an argumentless mark like `\OWNCHECK`, swallows the next character as
  its argument and the mark silently disappears.
- Inside a theorem environment's optional argument, `\cite[...]{...}` **breaks
  at the first `]`.** When attaching a source to a theorem head, wrap the whole
  pointer in braces -- `\begin{prop}[{\cite[\S2.1]{Key}}]`. The same goes for
  citation shorthand macros.

### bibtex -- no checker catches these

- The `note` field is printed. The `alpha` style outputs `note` into the
  bibliography as it is, so working notes such as whether a work was obtained,
  node IDs, or local paths **end up in the final PDF.** Keep only what helps a
  reader follow the citation in `note` (an arXiv identifier, say). The
  authority on what has been obtained is `refs/NOTES.md`.
- Formulas in titles get lowercased. The `title` of `@article`,
  `@incollection` and `@misc` is lowercased without protecting mathematics, so
  `On $L^2$ extension` is printed as `On $l^2$ extension`. Wrap formulas and
  proper nouns inside titles in braces (`{$L^2$}`,
  `{O}hsawa--{T}akegoshi`), and **read `main.bbl` once every time a chapter is
  finalised.** (`@book`'s `title` is not lowercased.)
- `.bib` has no comment character. Text outside an entry is ignored, but `@` is
  read as the start of an entry wherever it appears, so writing an entry type
  with its `@` inside a comment makes bibtex lose the parse right there. Write
  it without the sigil in comments.

### The conditions under which a checker goes silent

- **A single non-ASCII character under `tex/` silences the log inspection
  entirely.** `main.log` is classified as binary and an ordinary `grep` finds
  nothing. So **everything under `tex/` is ASCII**, the log is read with
  `grep -a`, and `sh tex/check.sh` is run without fail before anything is
  finalised. An improvised `grep` is not a substitute.
- **A checker sees only the files inside its own glob.** For a file outside the
  target list, nobody looks at its citations, notation or source numbers. So
  **globs are kept recursive** (`**/*.md`, `tex/**/*.tex`) -- they follow into a
  new directory when one appears. The only thing needing an explicit list is
  the shared policy files outside the project. **When a checker says "0", check
  what it was looking at.**

---

## Authority and copies

The same table living in two places is normal -- `README.md` has to introduce
the method and `background.md` has to sit open while grading. **The problem is
one side being fixed and nobody noticing.**

So copies are marked. These are HTML comments and do not render on GitHub.

```
<!-- SSOT-CANON: depth-matrix -->     the authoritative side. The table just below is that table
<!-- SSOT-COPY: depth-matrix -->      the copy. It uses the same name
```

**The rule is "a copy may cover the authority, but may not change it."** Every
cell of the copy must **contain** the corresponding cell of the authority, and
the two tables must have the same number of rows and columns. So `README.md`
adding a gloss like `| **A** background mention only |` passes, while changing
an `L1` to `L2` or deleting a row does not. `md-check.sh` item 10 checks it.

- The authority is always `CLAUDE.md` or `PHASE1_PROBE_GUIDE.md`. Authority is
  not placed outside the policy files.
- To change a table, **change the authority and run the checker.** The checker
  points at the copies.
- A newly copied table that is not marked is not checked. Mark it at the moment
  of copying.

This applies **to tables in the management documents only.** A prose summary is
natural language and cannot be collated by machine, so one line pointing at the
authority is enough; and the direction of authority for a chapter imported
between projects is fixed separately by "Cross-project reuse" -- there, the copy
may change the mathematics.

---

## Ask vs. proceed

- **Ask** when the answer changes (a) whether an item is included, (b) the
  depth grade, or (c) the baseline.
- **Proceed** on every other editorial decision. State the assumption in the
  text as `[assumption]` and keep writing. Do not stop at every detail.

---

## Changing the plan (Amendment)

A new prerequisite surfacing mid-reading is **normal**. Instead of re-approving
everything:

1. Append to `## Amendments` in `spec.md`: date / node / where it surfaced /
   usage tag / proposed depth / reason
2. Ask for a one-line approval.
3. Do not restructure existing chapters. Add a separate section if needed.
4. Do not add or remove a chapter without approval.

---

## Prohibitions

> An item is **"do not do X" plus the section it points at**. The "why" lives
> only in that section.

- Running Phase 0 without the full text of the paper
- Re-explaining anything graded K2 or above in `background.md`
- Cutting direct evidence down by graph inference in Phase 1
  (`PHASE1_PROBE_GUIDE.md` §1, §4)
- Writing a chapter that is not in `spec.md`
- **Stating a theorem without a source**
- **Inventing a reference or a theorem number**
- Recording state in this file (`CLAUDE.md`). The Project Config also goes in
  each project's `spec.md` (§0)
- Writing a length in two places. `progress.md`'s "Measured length" is the only
  authority
- Copying a table without attaching the `SSOT-COPY` marker (see "Authority and
  copies")
- Updating only some of the three places when recording an approval (§2, "The
  state block")
- **Changing the plan without approval**
- Asking the user a question, or requesting approval, in grade codes alone (see
  "How to talk to the user")
- Conversely, spelling out a management document's grade column in prose (same
  section, `md-check.sh` item 8)
- Leaving a resolved item in an "Open" list. Delete it from the open list as
  soon as it is resolved. If the history is worth keeping, move it to a
  *history* section -- the approval log, the session history, Amendments -- and
  keep **only items with work still to do** in the open list. (If it later
  turns out to be open again, raise it again then.)
- Using undefined macros in the markdown files (`spec.md`, `background.md`,
  `progress.md` and the rest). These files have to read as they are on GitHub
  and in an editor, so formulas use only standard LaTeX/MathJax (`\mathrm`,
  `\mathbb`, `\mathcal`, `\liminf` and so on). Project macros such as `\D`,
  `\C`, `\P`, `\Oc`, `\hyp` are used only inside `tex/`. When *mentioning* such
  a macro in markdown, wrap it in backticks as code.
