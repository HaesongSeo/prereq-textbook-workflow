---
phase: 0
phase_status: in_progress
last_approved: ""
next_action: "Fill in the Project Config and start Phase 0"
chapters_approved: []
sections_approved: []
---

# Progress

> The first file read at the start of a session. **The state block at the top
> is authoritative for `phase`, `last_approved` and the list of approved
> chapters** (`CLAUDE.md` §2, "The state block"). The prose of "Current state"
> below carries what the block cannot -- it does not write the same fact twice.

## Starting a new session

1. Set the working directory to **`Study/<project name>/`**.
   (`CLAUDE.md` at the `Study/` root is the policy file and is shared by every
   project, so which project this is has to be specified first.)
2. Read `progress.md` -> `spec.md` -> `background.md` in that order, following
   the session protocol in `CLAUDE.md` §2.
   **Check all three at the end of every turn.** If nothing needs changing,
   just confirm that.
   (`background.md` is a Phase 1 output and usually has nothing to change, but
   confirming "nothing" is part of the procedure.)
   If Phase 1 is in progress, also read `PHASE1_PROBE_GUIDE.md` at the `Study/`
   root. That file is authoritative on probe selection and K grading.
3. Run the checks **in this order** (see "Checker scripts" below).
   `sh tex/check.sh` -> `sh md-check.sh` -> `sh tex/notation-check.sh` ->
   `sh tex/import-check.sh` (when a chapter was imported) -> (the project's own
   source-number checker)
   The build comes first because `md-check.sh` reads the `.aux` files. The last
   three are required to pass by the exit conditions of Phases 4, 5 and 6.
4. Continue from the *next action* under "Current state" below.

Example first prompt:
> I'm continuing the project in the `<project name>` folder.
> Read CLAUDE.md and progress.md / spec.md / background.md and tell me where
> things stand.

**What does not survive between sessions:** PDF text extracted into a scratch
directory. Regenerate it with `pdftotext -layout` if needed. The originals in
`refs/` stay.

**Careful with scans.** If the text layer cannot be trusted, render the page as
an image and read it directly before transcribing any statement. How to read it
and the page correspondence are authoritative in `refs/NOTES.md`, "How to read
this PDF".

## Current state

> Record what the state block (top) cannot -- why work stopped there, the
> reading order, the do-not-re-explain list. Do not rewrite `phase` or the list
> of approved chapters here.

- Current phase: **Phase 0** (obtain and analyse the paper)
- Last approval:
- Next action:
- Questions awaiting an answer:
- **K2 and above (do not re-explain):**
- **K0 (write in full):**

> The last two lines are a summary so `background.md` does not have to be dug
> through every time. Fill them once Phase 1 ends, then keep to the
> do-not-re-explain rule by looking only at these each turn.
> **List node names only** -- do not spell out what the grades mean here
> (`CLAUDE.md`, "How to talk to the user").

## Approval log

| Date | Item | Approved | Notes |
|---|---|---|---|
| | | | |

## Checker scripts

The build comes first (`md-check.sh` reads the `.aux` files).

| Script | Target | What it checks |
|---|---|---|
| `sh tex/check.sh` | `tex/` | 1 non-ASCII 2 clean-room build 3 the log (`grep -a`) 4 items missing from a chapter's closing "Summary" table |
| `sh md-check.sh` | the shared policy files at the root + **every `.md` under the project** (including `refs/NOTES.md`) | 1 project macros outside backticks 2 vertical bars inside math in a table row 3 table column counts 4 inline math not closed on its line 5 our item numbers against `tex/**/*.aux` (both the Korean form and the abbreviated English form) 6 leaked `\uXXXX` escapes 7 the approval columns of "Chapter status" and "Close-reading status" against the approval log 8 whether a grade column lost its codes and became prose 9 the state block against the approval log 10 `SSOT-COPY` tables against their authority |
| `sh tex/notation-check.sh` | **every `.tex` under `tex/`** (preface and appendices included) | places where a `notation.sty` macro's expansion was typed by hand |
| `sh tex/import-check.sh` | `tex/IMPORTS` | whether a chapter forked from another project **has moved on either side** |

**Build one more per project: the source theorem-number checker.** Source item
numbers written as plain text in the book (`Thm.~8.1` and the like) do not go
through `\ref`, so **nothing checks them.** Build a script that extracts a
(kind, number) table from the source PDF and collates it against the book
(`tex/<paper>-check.sh`).

## Build verification rules

`tex/` contains **a skeleton that builds on its own** (`main.tex`,
`preamble.sty`, `notation.sty`, `refs.bib`). Right after copying it, run
`sh tex/check.sh` and confirm it passes before starting -- from then on,
whatever breaks was put there by us. The first things to fill are the title
block of `main.tex` (the bibliographic data exactly as in `spec.md`) and
`notation.sty`; chapters are switched on one `\include` line at a time as they
are approved. **Delete `\nocite{*}` from `main.tex` once the first `\cite`
exists.**

For the form of a chapter and a section, start by copying
`tex/chapters/ch00-example.tex` and `tex/paper/sec00-example.tex` -- the header
box (Purpose / Assumed / Supports / How far things are proved) and the closing
"Summary: where this chapter is used" table (Item / Here / Used in) are the
whole of the form. **That table is the tool of the chapter check**: every
numbered item above must appear in it, and each row must point at where the
item is used. An item with nowhere to point is deleted, or declared in the text
as intuition the reader needs. The two example files are not included in
`main.tex`.

Build artefacts (`.aux`, `.log`, `.toc`, `.bbl` and so on) **are not deleted.**
`md-check.sh` reads the `.aux` files, and the length measurement reads
`main.toc` and `main.log`. Keep them out of the repository via `.gitignore`
only.

**Run `sh tex/check.sh` without fail before a chapter is finalised.** Do not
inspect the log with an improvised `grep`. For the reason see `CLAUDE.md`'s
verification rules (a single non-ASCII character makes `main.log` binary and
silences `grep`).

Rule: **everything under `tex/` is ASCII.** Korean notes live only in the
management documents.

## Chapter status

| Ch | Title | Origin | Written | Checks pass | Compiles | Approved |
|---|---|---|---|---|---|---|
| 01 | | new | ☐ | ☐ | ☐ | ☐ |

> **On approval, fill this table's "Approved" column, the "Approval log" above,
> and the state block at the top, all in the same turn.** `md-check.sh` items 7
> and 9 collate the three -- writing the rule down alone turned out not to
> prevent it, which is how they came about.

> "Origin" is **new** or **import: `<project>/<file>`**. An imported chapter is
> also registered in `tex/IMPORTS` and watched for drift with
> `sh tex/import-check.sh` (`CLAUDE.md`, "Cross-project reuse").

> Checks = the five items in `CLAUDE.md` Phase 4

## Close-reading status (Phase 5)

| § | File | Length | Status | Open items |
|---|---|---|---|---|
| | | | ☐ | |

## Measured length -- **this is the authority**

How it is measured: after a clean-room build, read the starting page of each
`\contentsline{chapter}` in `tex/main.toc` and subtract it from the starting
page of the next entry (a chapter or a `\part`). For the last chapter, take the
bibliography's starting page (`(./main.bbl [NNN` in `main.log`) as the end.
**Do not forget the `\part` title pages.**

| Ch | Page range | Length | Notes |
|---|---|---|---|
| | | | |

## Verification marks in the book

The current counts and the full list of `\UNVERIFIED` / `\uncertain` /
`\OWNPROOF` / `\OWNCHECK`. The final policy is decided in Phase 6.

The command that extracts the full list:

```sh
cd tex && python3 - <<'EOF'
import re,glob,os
lab={}
for a in glob.glob('**/*.aux', recursive=True):
    for m in re.finditer(r'\\newlabel\{([^}]*)\}\{\{([^}]*)\}\{([^}]*)\}',open(a,errors='ignore').read()):
        lab[m.group(1)]=(m.group(2),m.group(3))
for f in sorted(glob.glob('**/*.tex', recursive=True)):
    L=open(f,errors='ignore').read().split('\n'); cur=None
    for i,l in enumerate(L):
        m=re.search(r'\\label\{([^}]*)\}',l)
        if m: cur=m.group(1)
        for mac in ('\\OWNPROOF','\\OWNCHECK','\\uncertain{','\\UNVERIFIED'):
            if mac in l:
                n,p=lab.get(cur,('?','?'))
                print(f"{mac:12s} {f:38s} L{i+1:4d} item {n:6s} p{p:4s} [{cur}]")
EOF
```

## Open

> **Only what still has work to do.** Delete it as soon as it is resolved and,
> if the history is worth keeping, move it to the approval log or the session
> history.

-

## Session history

> Chronological (oldest at the top).

| # | Date | What was done | What was left |
|---|---|---|---|
| 1 | | | |
