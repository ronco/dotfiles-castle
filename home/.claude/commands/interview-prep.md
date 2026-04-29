---
description: Generate a per-candidate interview prep file under ~/dev/notes/hiring/<role>/ from a resume in ~/Downloads. Scans recent PDFs, reads the role's baseline template and recent peer files, produces a candidate file with inline questions, candidate-specific probes, and calibration context. Invoke when starting interview prep for a new candidate.
allowed-tools: Bash(ls *), Bash(find *), Bash(cat *), Bash(head *), Bash(wc *), Bash(open *), Read, Write, Edit, mcp__google-docs__readDocument
---

Generate a per-candidate interview prep file for Ron's hiring workflow.

## Inputs

All inputs are discovered from the environment — no CLI arguments.

### 1. Role detection

Read `cwd`. Verify it is a subdirectory of `~/dev/notes/hiring/`. If not, abort:

> "Run /interview-prep from a role directory under ~/dev/notes/hiring/. Current cwd: <cwd>."

The role slug is the cwd directory name (e.g., `business-operations-engineer`).

### 2. Resume discovery

List PDFs in `~/Downloads/` modified within the last 7 days, newest first. Show the top 5 with modified time and size:

```
1. Fabián Orozco - FJL (1).pdf  (2026-04-24 09:05, 141 KB)
2. Jairo-Marroquín-FJL.pdf       (2026-04-22 09:35, 119 KB)
...
```

Ask: "Which resume? (1-5, or path to a different file)". Accept a number or a full path. If no PDFs within 7 days, skip the menu and ask directly for a path.

### 3. Baseline template discovery

Look in cwd for `technical-interview-template.md`, then `technical-interview-template.org`. If neither exists, run the **Bootstrap sub-flow** (see below). If one exists, read it.

### 4. Peer calibration

List existing `*-interview.org` files in cwd, sorted by mtime descending. Read the most recent 1–2 as style and outcome references — these populate the "Calibration vs. Prior Cohort" section of the output.

If none exist, skip and omit the Calibration section from the output rather than faking it.

## Core flow (baseline template exists)

### Step 1 — Parse the resume

Read the PDF with the Read tool. Extract:

- Candidate full name (for filename and overview)
- Work history — company, title, dates, literal bullet text
- Stack, education, languages, portfolio / GitHub links
- **Embedded recruiter notes when present** (often a trailing page — English tier, salary expectation, availability, "other process" status, professionalism / communication / proactivity tags). These are high-value calibration signal; fold into Candidate Overview and use to drive the "Specifically NOT Warning Signs" section later.

### Step 2 — Compose the per-candidate file

Match the Marco/Fabián file structure exactly. Use **org-mode format**.

Sections in order:

1. **Header**

```
#+TITLE: <Full Name> - <Role Short> Technical Interview
#+DATE: <today's date in YYYY-MM-DD>
#+AUTHOR: Ron White
```

2. **Candidate Overview** — bulleted summary. Cover concurrent roles, education status, languages (with English tier when available), and every stack technology named. When recruiter notes are embedded, add a "Recruiter intake claims:" sub-bullet group with the structured fields verbatim.

3. **Key Concerns** — 3–5 numbered items. Target patterns:

   - **CV voice-register mismatch.** CVs often mix abstract accomplishment prose ("improved visibility", "cleaner integrations") with metric-heavy prose ("62.3% improvement", "229 sprint points"). When both coexist, flag it and direct the interviewer to probe for texture.
   - **Recruiter claim missing from CV.** If recruiter notes tag an experience area the CV doesn't show (e.g., "marketing companies experience"), name it.
   - **Experience-calibration concerns.** Tenure math, concurrent roles, internship-heavy backgrounds.
   - **Transferability claims.** "X years with similar CRMs" type assertions.

   End with a paragraph identifying the "upside bet" — the one resume item most likely to be high-signal if probed.

4. **Interview Plan (~25 min usable + 5 for candidate's questions)** — the live artifact. For every baseline question pulled from the role template:

   - Embed the **full question text inline** (Ron's feedback memory — never reference a separate file)
   - Embed the **full listen-for list** inline
   - Embed the **red flag line** inline
   - Hang `/Candidate-specific:/` probes off each in italic/slash blocks, anchored to concrete resume details

   Subsections:

   - **Opening (~2 min)** — baseline opening. Add a `/Candidate-specific:/` note when calibration cues warrant (e.g., "English Tier 3 — speak slower, allow longer silences before reading thin replies as thin thinking").

   - **Section 1: Production & Systems Thinking (~12 min)** — Q1, Q1b (team-size), Q2, Q3. The four **engineering-fundamentals probes** MUST be baked in and anchored to specific resume details:

     * **Q1 fused with anchored ticket-to-prod walkthrough.** Pick the most substantive thing on the CV and force them to walk ticket pickup → branching → testing → review → deploy → post-deploy detection. Example anchor: "Tell me about the Client Portal at ITCO — the one with 28+ Azure Functions. Pick one of those Functions, and walk me from ticket pickup through branching, testing, review, deploy, and how you'd know if it broke in production."
     * **Q1b team-size shortcut (~60s).** "How many engineers on that team? Who reviewed your PRs, and who owned the pipeline?" Cheap diagnostic that reframes everything they just said.
     * **Q2 incident retrospective.** Anchor to a concrete incident-shaped CV bullet when one exists (Dos Pinos / Grant Thornton QuickBooks errors for Fabián, LWSA reliability work for Marco). If none exists, keep the generic incident question.
     * **Q3 concrete testing probe.** Anchor to their most consequential shipped thing. Force context-aware quality thinking (the testing bar for a legal compliance workflow differs from a frontend animation).

     After Q3, include a "Candidate-specific red flag to watch across Q1–Q3" paragraph naming the two voice registers on their CV and saying which pattern the verbal answers should match for a truthful-CV reading.

   - **Section 2: AI Fluency & Enablement (~8 min)** — Q4, Q5, Q6 from the baseline. Plus a **"MUST HIT" candidate-specific deep-dive** when a CV item warrants it (Fabián's Translator API, Marco's churn prediction, someone's Copilot Studio work). Give the interviewer 2–3 framings to pick from.

   - **Section 3: Role-specific scenario** — pull Q7 with its listen-fors, primer, and red flags from the baseline template. Add candidate-specific framing when the CV suggests either:
     * A **transfer opportunity** — "this candidate's prior X is structurally close; push for transfer"
     * A **gap** — "this candidate's CV is light on modeling; a clean rules-first answer is a stronger signal than attempting ML"

   - **Fit / Closing (~3 min + 5 for candidate questions)** — baseline closing, plus **MUST-ASK** probes generated from gaps:
     * Recruiter claims absent from CV → ask directly ("Recruiter mentioned X. The CV doesn't show it. Which role had that work?")
     * Transferability claims → verify with concrete prior integration + pain point
     * Complicated availability → surface directly ("Your ITCO engagement just wrapped up — are you in any other interview processes right now?")

5. **What to Watch For** — Good Signs and Warning Signs, each 6–10 bullets. Add a **"Specifically NOT Warning Signs"** subsection when calibration cues warrant (English tier < native, small-team or solo-operator background, language fatigue expected). This is load-bearing — it prevents misreading language friction as thin thinking.

6. **Notes During Interview** — scaffolded bullet skeleton matching question order. One bullet per question with a colon and empty value for live typing. Example:
   ```
   - Q1 (ticket-to-prod):
   - Q1b (team size / PR culture):
   - Q2 (incident):
   ```

7. **Calibration vs. Prior Cohort** — 2–4 bullets referencing peer candidates from the role dir, noting their outcomes (advanced / not advanced) and what signal differentiated them. Close with: "The bar for advancing <this candidate>: <specific criteria>."

8. **Other Interview Coverage** — copy from the baseline template (e.g., "Micah: live coding (round 1)", "Mariah: round 2 if advances").

### Step 3 — Save

Filename: `<firstname-lastname>-interview.org`. Rules:

- Strip diacritics (Fabián → fabian, Jairo → jairo)
- Lowercase
- Replace non-alphanumerics with hyphens
- Collapse multiple hyphens
- Drop trailing hyphens

On collision, ask: "File `<filename>` exists. (o)verwrite / (v2) save as `<base>-v2.org` / (a)bort?"

Write via the Write tool to `<cwd>/<filename>`.

### Step 4 — Report

One-line summary followed by open offer:

> "Generated `<path>`. <N> candidate-specific probes added. Top concerns: <C1>, <C2>, <C3>. Open it? (y/n)"

If yes: `open <path>`.

## Quality heuristics

The judgment quality of the output depends on applying these consistently. Each item is a check — not a suggestion.

1. **Anchor every candidate-specific probe to a concrete resume detail.** "CV says he shipped 28+ Azure Functions — pick one and walk through ticket-to-prod" is good. "Probe his Azure skills" is not. If a probe doesn't name a specific thing from the resume, rewrite it.

2. **Inline questions, never references.** Full baseline question text, listen-fors, and red flags all live in the candidate file. Ron flips between files during the live interview; external references cost him time.

3. **Voice-register detection.** Scan the CV for both patterns — abstract accomplishment prose AND metric-heavy prose. When both coexist, generate a "Candidate-specific red flag to watch across Q1–Q3" paragraph: if verbal answers match the metric-heavy register, CV is truthful; if they match the abstract register, CV was dressed up.

4. **Recruiter-claim verification.** For every claim in recruiter notes not visible on the CV, generate a MUST-ASK probe in Fit/Closing. Example: recruiter tagged "experience with marketing companies" but CV shows none → "Which of your roles had the most marketing/GTM work, and what did it look like?"

5. **Transferability claims.** When a recruiter note or CV bullet claims skill X transfers from skill Y ("HubSpot is new but I have 4+ years with similar CRMs"), generate a verification probe: "What was the last CRM integration you built, and what's the most painful thing that went wrong with it?" Real integration scars are specific.

6. **Calibration cues → "Specifically NOT Warning Signs" section.** When recruiter notes tag English tier, professionalism, or proactivity at less than top tier, add a "Specifically NOT Warning Signs" subsection calibrating what not to misread as a signal against the candidate (longer silences, grammar errors, lower eloquence, solo-operator background).

7. **Bake in the engineering-fundamentals probes.** Every candidate file MUST include:
   - Q1 fused with an anchored ticket-to-prod walkthrough
   - Q1b team-size shortcut (60 seconds)
   - Q2 incident retrospective (anchored when an incident bullet exists on the CV)
   - Q3 concrete testing probe anchored to a consequential thing they shipped

   Even if the baseline template doesn't explicitly require them, include them — they're the only way to surface SDLC / CI-CD / observability signal.

8. **Scenario weighting for the specific candidate.** In Section 3, note how to weight the scenario for this CV:
   - If the CV shows analytics / ML / scoring work → the ICP question is weighted MORE heavily (strong candidates with that background should reach for it faster).
   - If the CV shows no modeling → a clean rules-first-then-model answer is a stronger signal than attempting ML.
   - Integration-heavy CV → push hard on pipeline specifics (webhook vs. poll, HubSpot rate limits, retry handling, idempotency).

## Bootstrap sub-flow (no baseline template found)

Triggered when cwd has neither `technical-interview-template.md` nor `technical-interview-template.org`.

### Bootstrap Step 1

Ask: "No `technical-interview-template.md` in this role directory. Bootstrap one from a JD?"

Wait for yes/no. If no, abort.

### Bootstrap Step 2

Ask: "JD Google Doc URL?"

### Bootstrap Step 3

Fetch the JD via `mcp__google-docs__readDocument`. If the MCP is unavailable, fall back:

> "Google Docs MCP not available. Paste the JD text here and end with `---END---` on its own line."

### Bootstrap Step 4

Read `~/dev/notes/hiring/business-operations-engineer/technical-interview-template.md` as the structural/style reference (it's the richest — has fundamentals probes and scenario primer baked in). Read `~/dev/notes/hiring/mle-campaign-delivery/technical-interview-template.md` for comparison.

### Bootstrap Step 5

Generate a new `technical-interview-template.md` tailored to the JD, matching BOE's structure:

- Header (role name, 30-min duration, round slot, goal)
- Opening (~2 min)
- **Section 1: Production & Systems (~12 min)** — Q1/Q2/Q3 with the four fundamentals probes worded generically (per-candidate anchoring happens later)
- **Section 2: AI Fluency & Enablement (~8 min)** — Q4/Q5/Q6, role-adjusted for what "coaching non-engineers" means here (SDRs for BOE, partner integration PMs for jr-pub-int, campaign ops for MLE, etc.)
- **Section 3: Role-specific scenario** derived from the JD's core responsibilities, with an **Interviewer primer** block for domain jargon (like the ICP primer in the BOE scenario)
- Closing (~2 min)
- Scoring Rubric table

**Do not include candidate-specific content.** The baseline is shared across all candidates for this role.

### Bootstrap Step 6

Save to `<cwd>/technical-interview-template.md` via the Write tool.

### Bootstrap Step 7

Print: "Baseline generated at `<path>`. Review before generating the candidate file? (recommended for first use)"

Wait for user confirmation. Then continue at **Core flow Step 1**.

## Edge cases

- **Non-PDF resume** — error, ask for a PDF path.
- **Unreadable PDF** — report error and abort; do not write a junk file.
- **Filename collision** — prompt overwrite / `-v2` suffix / abort (see Save step).
- **Cwd not under `~/dev/notes/hiring/`** — abort with clear message and the expected cwd pattern.
- **No recent PDFs in Downloads** — skip the top-5 menu; ask directly for a path.
- **Google Docs MCP unavailable during bootstrap** — fall back to paste-inline flow.
- **No prior peer candidate files** (brand-new role right after bootstrap) — skip peer-calibration step; omit the "Calibration vs. Prior Cohort" section.
- **Peer files use the older "references separate template" format** (some jr-pub-int files) — still read for calibration substance; do not imitate their structure, follow the newer inline-questions format.

## References

- Per-candidate format exemplars:
  - `~/dev/notes/hiring/business-operations-engineer/marco-thulio-interview.org`
  - `~/dev/notes/hiring/business-operations-engineer/fabian-orozco-interview.org`
- Baseline template exemplars:
  - `~/dev/notes/hiring/business-operations-engineer/technical-interview-template.md`
  - `~/dev/notes/hiring/mle-campaign-delivery/technical-interview-template.md`
