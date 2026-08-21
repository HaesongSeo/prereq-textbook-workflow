# Project Specification

> Phase 0 output. After approval it changes only through the Amendment
> procedure.
>
> **Notation rule:** formulas in this file use only `\mathrm{}`, `\mathbb{}`,
> `\mathcal{}` and `\mathscr{}` so they read directly on GitHub and in an
> editor. Project macros (`\ddc`, `\Oc` and the like) are used only inside
> `tex/`; when *mentioning* one here, wrap it in backticks.

## Project Config

> `CLAUDE.en.md` sits at the `Study/` root and is shared by several projects.
> **The config goes here, in each project.** If it is empty, do not start
> Phase 0 -- ask first. For what each field means, see `CLAUDE.en.md` §0.

```yaml
TARGET_PAPER:
SOURCE:
OUTPUT_LANGUAGE:   English
TOTAL_PAGE_BUDGET:
PER_CHAPTER_MAX:
BASELINE_HINT:
```

### Companion paper

> If the target paper depends wholesale on a separate work, it goes here.
> Record the scope of inclusion and, if it departs from the depth table, the
> reason.

## The target paper

- Authors / title:
- Publication data:
- Where the source is:
- The paper's main result (1-3 lines):

### Structure of the paper (verified -- against the real numbers in the PDF)

| § | Title | Pages | Main result |
|---|---|---|---|
| | | | |

## Dependency graph

Node ID / name / prerequisites and edge kinds / how the paper uses it (A-D) /
where it appears in the paper

| ID | Node | Prerequisites (edge kind) | Usage | Where it appears |
|---|---|---|---|---|
| N01 | | N04(definition), N07(proof) | | |

> Usage: A background mention / B black-box citation / C hypotheses
> manipulated and applied / D the proof technique imitated
>
> In the "Usage" column write only the letter (`C`, `B/C`). The same goes for
> the "Depth" column of the chapter plan -- write `L0`-`L4` (`CLAUDE.en.md`, "How
> to talk to the user").
>
> **The edge kind is written in Phase 0, without fail.** `definition` = the
> prerequisite appears *inside this node's statement* (without it the statement
> cannot be written precisely) / `proof` = the prerequisite is used *only in
> this node's proof* (the statement reads without it). Phase 1's grade
> propagation works differently in the two cases
> (`PHASE1_PROBE_GUIDE.en.md` §3). Attaching it later means re-reading the whole
> graph.

## Notation glossary

In the paper's notation. Put it in 1:1 correspondence with the `notation.sty`
macros.

| The paper's notation | Meaning | Macro | Difference from standard notation |
|---|---|---|---|

> If several papers are being read side by side, also produce the notation
> correspondence table as an appendix in `tex/`. That table is not our working
> tool but **something the reader needs**. Keep this section as the planning
> record and put the reader-facing authority in the appendix.

## Candidate references

> The authority on bibliographic data is `tex/refs.bib`; **the authority on
> what has been obtained is `refs/NOTES.md`**. Do not record what has been
> obtained in `refs.bib`'s `note` (`CLAUDE.en.md`, verification rules).

| Key | Item | Used for |
|---|---|---|
| | | |

### Results of checking cited numbers

> A record of collating the theorem numbers the paper cites against the real
> documents. **Check the entries where the same author has several papers
> first** (`CLAUDE.en.md`, verification rules).

| Citation | As the paper writes it | The real document | Verdict |
|---|---|---|---|

## Chapter plan

| Ch | Title | Nodes included | Depth | Target length | What it supports (paper §) |
|---|---|---|---|---|---|
| 01 | | | | | |

- Total target length:
- Page budget:

> The actual length is not written here. The authority is "Measured length" in
> `progress.md`.

### Exceptions to the depth table

> Items that depart from the depth table, with their reasons. All of them need
> approval.

### Reuse (import) contract

> If a chapter was taken from another project, it goes here. What / why it is
> not verbatim / what was adapted / which side is authoritative. The details
> are in each file's provenance block and in `tex/IMPORTS`.

| Chapter in this book | Origin | What was adapted | Authority |
|---|---|---|---|
| | | | the origin |

### Phase 5 (close reading): order and length

> **Order.** It need not be the paper's order. A section that is really a
> toolbox reads better placed last -- in its own place it has no motivation,
> and it only becomes recognisable after seeing where it is used.
>
> **Length.** The target is **the section's page count in the source, as it
> is** (`CLAUDE.en.md` Phase 2, "The length of Part II"). This total is **not
> subject to a budget** -- `TOTAL_PAGE_BUDGET` covers only the preparatory
> chapters. The measurement departing from the target is normal (a section the
> preparatory chapters already prepared for gets shorter; a section the paper
> wrote compactly gets longer), and **the authority on the measurement is
> "Close-reading status" in `progress.md`. It is not written here.**

| § | Title | Source pages | Target | Reading order | Notes |
|---|---|---|---|---|---|
| | | | | | |

> "Notes" carries why the order was set that way, and -- if the target departs
> from the source page count -- the reason. Even if a source section exceeds
> `PER_CHAPTER_MAX`, it is not split here in advance; where to split only
> becomes visible on reading it.

## Remaining risks

> **Only what still has work to do.** Anything resolved moves to the history
> below.

### Resolved risks (history)

| Risk | How it was resolved |
|---|---|

## Source errata

> The **complete list** of typos and inaccurate citations found. These are not
> open items but settled records, already reflected in the relevant chapter.
> The textbook corrects them but says so in a footnote. If one of our own
> records turns out to be wrong, that too stays here **as a withdrawal.**
>
> **This section goes out as a reader-facing appendix in Phase 6**
> (`CLAUDE.en.md`, Phase 6 exit conditions). The footnotes stay where they were
> found and the list goes in the appendix separately -- a reader collating
> against the source needs the list in one place.

## Settled conventions

> Editorial decisions that span the whole project. Once fixed, they are not
> asked about again.

- **`refs.bib` keys.** Follow the alpha keys of the rendered source PDF (it
  makes collating with the paper easier for the reader).
- **The number in `paper/secNN` = the paper's section number.** The order is
  fixed by the `\include` order in `main.tex` and by "Phase 5 (close reading):
  order and length" above (`CLAUDE.en.md` Phase 5). If a section runs long, split
  it into `sec05a` / `sec05b`.

## Amendments

> Items that turned out to be needed mid-way. Append only.

| Date | Node | Where it surfaced | Usage | Proposed depth | Reason | Approved |
|---|---|---|---|---|---|---|
| | | | | | | |
