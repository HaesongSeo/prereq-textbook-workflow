[한국어](README.md) | English

# prereq-textbook-workflow

**Policy and templates for building, with Claude Code, a custom textbook that
teaches only the mathematics one paper actually requires.**

When there is a paper you want to read and the prerequisites are missing, the
usual options are two: read a standard textbook from page one, or push on
without understanding. The first has you read half a book the paper never
touches; the second leaves you unable to say where you got stuck.

This repository is for a third route. **Analyse the paper first and build a
dependency graph, measure what the reader already knows with short probe
questions, and write only the gap as a LaTeX textbook.** The curriculum is
decided by the paper, not by the subject. Where completeness and relevance
conflict, relevance wins every time.

It was refined while applying it to three real papers, and most of the rules
written here were put up at the spot where something failed.

## What is in here

| File | Role |
|---|---|
| `CLAUDE.en.md` | Project policy. The Phase 0-6 procedure, the depth-decision rule, the verification rules, the prohibitions |
| `PHASE1_PROBE_GUIDE.en.md` | The detail policy for background diagnosis (Phase 1): which node to ask about, how to turn an answer into a grade, how to fill in the nodes never asked about |
| `Source/` | The template copied wholesale to start a new project |
| `Source-en/` | The same template in English. Copy this one to work in English |

`Source-en/` holds the three management documents (`spec.md`,
`background.md`, `progress.md`) and the checker scripts. Those three are the authority on
state -- the policy files never record progress.

## The procedure

| Phase | Name | Output |
|---|---|---|
| 0 | Obtain and analyse the paper | Dependency graph, notation glossary, chapter outline (`spec.md`) |
| 1 | Background diagnosis | A knowledge grade per node (`background.md`) |
| 2 | Curriculum design | Depth and page budget per chapter |
| 3 | Obtain the references | `refs/`, `refs.bib` |
| 4 | Write the textbook | `tex/chapters/` |
| 5 | Read the paper closely | `tex/paper/` |
| 6 | Finish the book | Preface and appendices, exhaustive checks |

Every phase ends with a summary of the result and a request for approval.
Nothing moves to the next stage without it.

## The two load-bearing ideas

**1. Depth is fixed by two axes.** Every node gets a tag for *how the paper
uses it* (A-D) and a grade for *what the reader knows* (K0-K3); the table
gives the depth to write at (L0-L4).

<!-- SSOT-COPY: depth-matrix -->

|   | K0 never heard of it | K1 recognises the statement | K2 can state and apply it | K3 can reconstruct the proof |
|---|---|---|---|---|
| **A** background mention only | L1 | L1 | L0 | L0 |
| **B** cited as a black box | L2 | L2 | L1 | L0 |
| **C** applied, checking hypotheses | L3 | L3 | L2 | L1 |
| **D** the proof technique is imitated | L4 | L4 | L3 | L1 |

L0 is omission, L1 is the statement and its source, L2 adds the role it plays
in the paper, L3 adds examples and computation, L4 adds a complete proof.
There is no reason to read a proof of a theorem the paper only quotes as a
black box -- and no way to skip one whose technique the paper adapts.

**2. The knowledge grade is measured by probes, not self-report.** "Do you
know X?" is never asked. Instead the reader is given one problem that measures
one ability the paper actually demands. The question budget is fixed (five per
turn, six turns total), so the graph is searched by bisection rather than
surveyed exhaustively. **A measured value and a value inferred from the graph
never share a cell** -- once that distinction collapses, material the reader
already knows gets written out again, and those pages come out of the proofs
that were actually needed. The rules are in `PHASE1_PROBE_GUIDE.en.md`.

## The machinery against invention

In a mathematics textbook a plausible lie is the worst possible output. A
theorem number that does not exist, a paper that was never written, an
argument quietly skipped -- the reader finds out only after believing it for
weeks. A good share of the rules here exist to prevent that, and most were put
up where it actually happened.

**Block it at the input.** Phase 0 **does not begin before the full text of
the paper is in hand.** An abstract, a review, or memory will not substitute
-- if it cannot be obtained, ask the user for the PDF and wait. The same holds
for the references. To cite a theorem number, confirm it against the real
document by searching, not by memory, and **first establish which work a
citation key actually renders to** -- identifying a source by author name
alone once led to recording "the paper's citation is wrong", which had to be
withdrawn.

**Never silence uncertainty.** Instead of hedging prose, leave a mark in the
text.

| Mark | Meaning |
|---|---|
| `\UNVERIFIED{}` | **Not verified** -- either the source could not be identified, or it was identified but the document itself was never consulted. Say which, and name the work not seen |
| `\OWNPROOF{}` | An argument we supplied because the source has a gap (it states only the result, compresses the proof into a clause, or proves a different statement) |
| `\OWNCHECK{}` | A standard auxiliary fact or verification we added for convenience, filling no gap in any source |
| `\uncertain{}` | **The document was seen**, but our own write-up falls short of confidence |

What separates the first two is whether the document was seen. Not having seen
it is not a defect in our write-up but a fact we failed to confirm, so it is
marked `\UNVERIFIED` rather than `\uncertain`, and the work is named so the
reader can check it themselves.

Whether these marks survive into the final book is decided in Phase 6; if they
do, a legend goes into the book. A mark that appears dozens of times with its
meaning written nowhere tells the reader nothing.

**Checking is not left to human eyes.** The template ships with checkers.

| Script | What it catches |
|---|---|
| `tex/check.sh` | Non-ASCII scan, then clean-room build, then log inspection with `grep -a`, then items missing from a chapter's closing summary table |
| `md-check.sh` | Undefined macros in the management documents, vertical bars that break tables, column counts, our own item numbers against the real numbers in `.aux`, disagreement between the approval table, the approval log and the state block, grade columns that lost their codes and became prose, and copied tables that have drifted apart |
| `tex/notation-check.sh` | Places where a notation macro's expansion was typed by hand, so the notation has forked |
| `tex/import-check.sh` | Whether a chapter forked from another project has drifted -- in either direction (it fails rather than merging) |
| `tex/<paper>-check.sh` | Source theorem numbers written as plain text. Something like `Thm.~8.1` never goes through `\ref`, so the build checks nothing about it |
| `translation-check.sh` | English editions whose Korean source has moved since, and scripts in `Source/` and `Source-en/` that were fixed on one side only |

**Prohibitions.** Stating a theorem without a source, inventing a reference or
a theorem number, running Phase 0 without the paper, changing the plan without
approval. These outrank every other rule.

The checkers themselves have gone silent before, and that experience became a
rule in turn. A single non-ASCII character under `tex/` made the log binary,
so an ordinary `grep` quietly found nothing and a failed build was reported as
"0 warnings". Working notes left in a bibtex `note` field were printed across
twelve pages of the final PDF's bibliography. A file added later sat outside a
checker's glob and got a pass while full of `\cite`s -- widening the scope took
the comparison count from 223 to 243.

**None of this makes the model stop being wrong. It only keeps a wrong thing
from staying quiet.**

## Getting started

```sh
git clone https://github.com/HaesongSeo/prereq-textbook-workflow.git Study
cd Study
cp -R Source-en "my paper"
```

Open Claude Code in `Study/`. `CLAUDE.en.md` sits at the root and is shared by
every project; per-project settings go at the top of that project's `spec.md`.
For the first prompt, use the example under "Starting a new session" in
`Source-en/progress.md`.

Requirements: [Claude Code](https://claude.com/claude-code), TeX Live
(`latexmk`, `pdflatex`), `python3` (the markdown checker), and `poppler`
(`pdftotext`, `pdftoppm`) for handling source PDFs.

## What is not in here

Per-project output -- paper PDFs, written textbooks, diagnosis results -- is
not included. What is here is the method and empty templates.

The management documents and the conversation are written in Korean; the
textbook under `tex/` defaults to English. Both are per-project settings.

## License

MIT. See `LICENSE`.
