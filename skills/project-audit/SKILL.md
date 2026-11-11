---
name: project-audit
description: Build our audit protocol and audit log as we work. Use when we check, question, or correct your work.
---

# Project Audit Skill

This skill governs how the agent collaborates with the team to maintain and update the project's quality assurance documentation:
- **Audit Protocol:** `Other/audit_protocol.md`
- **Audit Log:** `Other/audit_log.md`

---

## 📋 Core Operating Rules

1. **Protocol Maintenance:**
   * As we work, document our process for checking work in `Other/audit_protocol.md`.
   * When a check reveals a new habit, standard, or method worth keeping, add it to the protocol.
   * **Always propose and show each addition to the team before saving it.**

2. **Audit Logging:**
   * When the team checks, questions, or corrects work in a way worth logging, flag it.
   * Propose the exact markdown entry for `Other/audit_log.md` and **add it only after the team explicitly approves**.

3. **Substantial Checks Only:**
   * Propose only substantial checks—those that:
     * Caught a mistake or data omission,
     * Required an authoritative external source or ground truth, or
     * Changed our analytical approach, metrics, or conclusions.
   * Skip routine formatting tweaks, syntax clarifications, and everyday approvals to keep the log concise and high-signal.

4. **Consistent Schema:**
   * Use the exact same table columns for every entry across all categories:
     ```markdown
     | # | What I checked | How | What I found | What I did about it |
     ```
   * **Never invent a check we didn't actually perform.** Every row must represent genuine verification work.

5. **Strict 5-Category Taxonomy:**
   * File each logged entry under exactly one of the five required category headings:
     1. `### 1. Caught an error`
     2. `### 2. Verified a claim`
     3. `### 3. Separated fact from opinion`
     4. `### 4. Changed the analysis`
     5. `### 5. Improved the agent's instructions`
   * Maintain a summary table at the very top of `Other/audit_log.md` with each category, its current entry count, and a direct markdown link to its section.
