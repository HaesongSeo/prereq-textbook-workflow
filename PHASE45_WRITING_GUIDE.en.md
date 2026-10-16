[한국어](PHASE45_WRITING_GUIDE.md) | English

# PHASE45_WRITING_GUIDE.md -- writing rules for the textbook and the close reading

This file is **policy**. It is **the authority for the writing rules** that
Phase 4 (writing the textbook) and Phase 5 (reading the paper closely) of
`CLAUDE.en.md` point to, and it is shared by every project. Progress is never
recorded here.

**Read this file when Phase 4 or Phase 5 starts, and run the checklist in §7
before a chapter is final.**

What this file **does decide**: how the text is written -- the register and how
far it goes, where symbols are defined and when they are recalled, contrastive
phrasing, how sources are written, the density of proofs and computations, and
the line between proofs and remarks.

What it **does not decide** (all of it is in `CLAUDE.en.md` and is not repeated
here): what is included and how far (the depth table), how page targets are
set, the approval procedure, and the definitions of the four verification marks
and the three states (`CLAUDE.en.md`, verification rules). In a conflict, the
verification rules of `CLAUDE.en.md` win.

---

## 0. Scope and units

- These rules apply to **all text under `tex/` that the reader reads** --
  preparatory chapters, close-reading chapters, the preface, the appendices. The
  notation rules for the management documents are set by `CLAUDE.en.md`, "How
  to talk to the user".
- A **chapter** is one file in `tex/chapters/` or `tex/paper/`; a **section** is
  one `\section` inside it. Recalling symbols is judged chapter by chapter
  (§2.3).

---

## 1. Register and how far the text goes

- The register of graduate lecture notes.
- Motivation -> intuition -> example -> why it is needed. **But only within
  what the depth grade permits.**
  - L1: one or two sentences of motivation. No example.
  - L2: motivation + the role in the paper. At most one example.
  - L3: examples and computations included.
  - L4: proof included.
- Avoid needless abstraction and textbook-style completeness.
- "Writing in detail" (§5) is a rule about **the density with which the proofs
  and computations that are included get written**. It is never a reason to add
  a proof or an example that the depth grade left out.

---

## 2. Notation

### 2.1 Define, then use

- **Do not use a symbol that has not been defined.** A symbol is defined where
  it is first used, or earlier. Do not use or point at an object that will be
  defined later ("introduced below").
- **Put a definition where its object actually arises.** Do not define symbols
  in a block at the head of a chapter or of the book and then use them in the
  text without definition. The only exceptions are the fixings of §2.2 and
  §2.4, and the introduction chapter (§2.9).

### 2.2 Symbols fixed for the whole book

- **There are two qualifications.** (a) Standard notation of the field;
  (b) notation used throughout this book -- what appears evenly from the
  preparatory chapters to the proof of the main theorem. An object made in one
  chapter and used in a few chapters does not qualify. There is no numerical
  threshold.
- **Where.** Fix them "throughout the book" in the conventions section of the
  first chapter. A symbol whose definition needs a construction (an object made
  in a later chapter) is declared "throughout the book" **at its definition**;
  the conventions section of the first chapter, without using the symbol, only
  says where it is defined and that it is kept to the end of the book.
- A fixed symbol is used in other chapters without recall. Fix only symbols
  that qualify; do not widen the list to save recalls.

### 2.3 When the chapter changes, recall

- A symbol defined in another chapter, unless fixed by §2.2, is **recalled where
  it is first used in this chapter.**
- To recall is **to restate the meaning in a phrase and point at the definition
  with `\ref`.** A bare `\ref`, or "as in Chapter N" alone, is not a recall.

### 2.4 Within a chapter

- A symbol used in a section other than the one that defines it is recalled
  where it is first used in that section.
- **A symbol used across several sections is fixed at the start of the chapter
  with "Throughout this chapter".** That paragraph may contain definitions of
  new symbols and recalls of other chapters' symbols. If the first section of
  the chapter is the one that sets things up, the symbol may instead be fixed at
  its definition there with "for the rest of this chapter".
- The "Throughout this chapter" paragraph contains **only what is used in
  several sections**. A symbol used in one section only, and an object defined
  later, do not go there -- they are defined or recalled where they are used.
- **A chapter-wide convention** (such as viewing all forms on one plane) is
  declared in each chapter. Do not declare a convention spanning several
  chapters once in one chapter and let the following chapters lean on it. If a
  convention changes within a chapter, say so at the head of the section where
  it changes.

### 2.5 One symbol, one meaning

- **The default is the target paper's notation.** Reading the paper outranks
  the textbook's convenience. A project may set another standard (the notation
  of a companion paper, say) in `spec.md`, "Settled conventions", and then it
  follows that.
- **Within the book a symbol has one meaning.** Where keeping the symbol of the
  target paper or of a cited work would give it two meanings, use a new name at
  that place only, and give the correspondence as in §2.6.
- If a letter in the statement of a cited theorem collides with a fixed symbol
  of the book, **restate the theorem with another letter.**
- **A local symbol used only inside a proof is allowed.** If that proof is
  called on elsewhere ("as in Step 3 of ...") or the symbol is used outside the
  proof, choose it so that it does not collide with the book's other symbols.

### 2.6 Correspondences go in a footnote at the first use

- If the book's symbol differs from the symbol of the target paper or of a
  cited work, **give the correspondence in a footnote where it is first used.**
- Frequency: **close-reading chapters, once per chapter** at the first use --
  each such chapter is read side by side with its section of the source.
  **Preparatory chapters, once in the book** at the first use.
- When a statement from another work is moved into the book's notation and the
  letters differ, give the source's letters in the same way.
- Do not collect correspondences in a paragraph at the head of a chapter. A
  correspondence table for the reader in an appendix is a separate matter
  (`CLAUDE.en.md`, Phase 6).

### 2.7 A statement can be read on its own

- In the statement of a definition, theorem, proposition, lemma or corollary,
  every symbol that is not fixed for the whole book or for the whole chapter is
  **defined in the statement or recalled immediately before it.**

### 2.8 A recall is not a re-explanation

- The rule against re-explaining what is already known (`CLAUDE.en.md`,
  prohibitions; the grades in `background.md`) does not forbid recalling a
  symbol. A recall is a phrase and a `\ref`; it does not repeat the account of
  the object.

### 2.9 The exception for the introduction chapter

The first chapter of Part II reads the paper's introduction and, with it,
gives the map of the main theorem and its proof (`CLAUDE.en.md` Phase 5, "The
introduction chapter"). The map uses the notation and the definitions of the
whole paper, so **in this chapter only** symbols and definitions are handled as
below, in place of §2.1, §2.3 and §2.4.

- **The symbols and definitions of Part I are recalled at the start of the
  chapter.** Everything this chapter uses from Part I, however many sections
  use it, is gathered in one paragraph at the head. The form is the recall of
  §2.3 -- a phrase for the meaning and a `\ref` -- and symbols fixed for the
  whole book (§2.2) are left out.
- **Symbols and definitions defined in another close-reading chapter are cited
  instead of defined.** At the first use, give the meaning in one phrase, point
  at the definition in the source with `\cite` and at the place in the book
  that defines it with `\ref`. This chapter is written last among the
  close-reading chapters, so there is always a place to `\ref`. What the paper
  sets up in its introduction and uses in later sections falls here too -- in
  the book, the first close-reading chapter to use it defines it (last item).
- **Statements (§2.7).** The recall at the head counts as fixing for the whole
  chapter. When a symbol or a definition of another close-reading chapter
  appears in a statement, cite it immediately before the statement.
- Symbols and definitions used only in this chapter are defined where they are
  used, as usual.
- Still in force: fixing for the whole book (§2.2), one meaning per symbol
  (§2.5), correspondence footnotes (§2.6).
- **The exception ends with this chapter.** No other chapter leans on it: none
  omits its own recall on the strength of this chapter's opening recall, and
  none points at what this chapter defines. Symbols, definitions and hypotheses
  that the paper sets up in its introduction are defined by the first
  close-reading chapter that uses them (in reading order, from the one after
  this chapter).

---

## 3. Contrastive phrasing

- **Do not use rhetorical contrast** such as "this is X, not Y" or "this is not
  Y". Write the same content affirmatively.
- The target is rhetorical contrast. **A mathematical negative statement**, such
  as the conclusion of a theorem, **is not a target.**
- **When to keep it.** Keep the negative clause if deleting it loses one of:
  1. a mathematical fact used later;
  2. a warning against a misreading the reader is actually likely to make;
  3. information that prevents a circular argument -- when the fact that some
     assumption is not used is itself needed to prove that assumption.

---

## 4. Sources

- A definition, theorem, lemma or computation taken from an outside work is
  cited at its **exact location** (theorem number, or section and page). A
  citation giving only author and year is not used (`CLAUDE.en.md`, verification
  rules).
- For a theorem or lemma with several items, cite **down to the item used**.
- When an item number of another work is written in a sentence, put it **inside
  the citation macro**. A number left in the prose is read by the source
  theorem-number checker as a number of the target paper.
- **A work that could not be consulted.** If the source has been identified but
  the work itself could not be obtained, **consult an equivalent work and cite
  that one**, following the priority of `CLAUDE.en.md`, Phase 3 (published
  textbooks and papers before lecture notes). Record the circumstances in
  `refs/NOTES.md`. If the target paper cites the original work directly, also
  name the original with the unverified mark (the three states are defined in
  `CLAUDE.en.md`, verification rules).
- **Standard facts.** These are the facts stated in the standard references
  (Project Config `STANDARD_REFERENCES`, default Hartshorne). Since the standard
  references are part of the baseline (`CLAUDE.en.md`, Phase 1, "Fixing the
  baseline"), a standard fact is **cited at its exact location in the standard
  references and only stated.**
  - A fact outside the standard references is not treated as standard, even if
    it is standard in another field. State it with an exact source and explain
    it as the depth grade requires, or prove it and attach a verification mark.
  - Do not let "standard", "well known" or "classical" stand in for a citation.
  - The book names its standard references in the conventions section of its
    first chapter.
- **A refuted statement is not placed in a theorem environment** (Theorem,
  Proposition, Lemma). State it in a remark and point at where it is refuted.

---

## 5. Writing in detail

- **Do not write compactly.** The proofs and computations that are included are
  written in as much detail as possible (within the range of §1).
- Criteria:
  1. Do not end a step with "clearly", "obviously", "it is easy to see", "one
     checks", "by a standard argument". Write the step.
  2. Write the intermediate steps of a computation, and say where each number
     entering it comes from.
  3. In a dimension count, say what each term counts.
  4. In a case analysis, write every case -- degenerate and dependent cases
     included.
  5. At the start of a case analysis, state the assumption of the case.
  6. A verification that says "written out" or "all cases" really writes all
     of it.
  7. Counts and numerical claims made in several places (header box, preface,
     text, appendix) are recounted and made to agree.
- **Verification marks.** An argument of the target paper written out at length
  carries no mark. Where we fill in what a source only stated, compressed to a
  phrase, or used without a definition, the mark is `\OWNPROOF`; checks and
  auxiliary facts stated for convenience carry `\OWNCHECK` (defined in
  `CLAUDE.en.md`, verification rules).
- **Length.** `TOTAL_PAGE_BUDGET` and `PER_CHAPTER_MAX` are reference values. If
  writing in detail conflicts with them, the length grows. If they are
  exceeded, only record it in `progress.md`, "Measured length", and do not
  report it. Do not split a chapter because of its length -- a split is decided
  where the discussion really divides.
- **The proof map of the introduction chapter.** The map proves nothing, so
  criteria 2 to 6 above do not apply to it. For each step, write the
  **geometric meaning** before the details -- what is built, what it
  guarantees, and so what the next step becomes able to do. Write so that a
  reader opening the paper for the first time can follow. Criteria 1 and 7
  still apply.

---

## 6. Close reading -- proofs in `proof`, remarks in remarks

The paper's proofs are moved into a `proof` environment. They are not
reconstructed inside a `remark`. An argument we restored because the paper did
not have it also goes in a `proof` environment, with `\OWNPROOF` attached --
what distinguishes the paper's from ours is the mark, not the environment.

The proof map of the introduction chapter is not a proof, so it does not go in
a `proof` environment; it is written as a numbered list of steps. The map
carries no verification mark either (`CLAUDE.en.md` Phase 5, "The introduction
chapter").

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

---

## 7. Checklist before a chapter is final

Run it at `CLAUDE.en.md`, Phase 4, "Checks before a chapter is final", and
before a Phase 5 chapter is final.

- [ ] No symbol is used before its definition, and nothing points ahead at an
      object defined later (§2.1)
- [ ] No symbol is defined in a block at the head of a chapter or of the book
      and then used in the text without definition (§2.1)
- [ ] Only qualifying symbols are fixed for the whole book (§2.2)
- [ ] Another chapter's symbols are recalled where first used in this chapter
      (§2.3)
- [ ] Symbols defined in another section of the same chapter are recalled, or
      fixed at the head of the chapter (§2.4)
- [ ] No symbol has two meanings; the local symbols of proofs that are called on
      again do not collide (§2.5)
- [ ] Symbols that differ from the target paper's or a cited work's carry a
      correspondence footnote (§2.6)
- [ ] Every statement can be read on its own (§2.7)
- [ ] In the introduction chapter: the symbols and definitions of Part I are
      recalled at the head, and every symbol or definition defined in another
      close-reading chapter has a phrase for its meaning, its place in the
      source and its place in the book (§2.9)
- [ ] Each remaining contrast has passed the test of §3
- [ ] Sources follow §4
- [ ] Proofs and computations meet the criteria of §5
- [ ] Proofs are in `proof` environments, and `remark` is used only for the three
      purposes of §6
- [ ] In the introduction chapter: the proof map is a list of steps outside any
      `proof` environment, and each step gives its geometric meaning first
      (§5, §6)
- [ ] **Every warning of `sh tex/style-check.sh` has been read.** The check never
      fails; it only warns. For each warning, fix it or confirm a reason to keep
      it by the tests of §3 and §5

What `style-check.sh` warns about: contrastive phrases, phrases that skip a
step, a notation paragraph at the head of a chapter and forward references, the
list of "throughout the book" declarations (to be compared with the conventions
section of the first chapter), and claims of completeness inside verification
marks ("written out", "all cases").
