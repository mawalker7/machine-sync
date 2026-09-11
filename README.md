# machine-sync

Keep two Macs in lockstep when you switch between them. Git is the source of truth for code; this kit handles what git does not carry across machines: secrets, dotfiles, tool versions, worktrees, scheduled jobs, and the work you leave stranded on the machine you just walked away from.

```
machine-sync in              Arrival ritual: pull everything, materialize .env files, surface drift and stranded work.
machine-sync out             Departure ritual: push where allowed; package read-only org work as a changeset.
machine-sync status          Read-only health check (no mutations, no prompts).
machine-sync doctor          Verify required tooling and repos are bootstrapped on this machine.
machine-sync package <br>    Emit ONE self-contained <slug>-changeset.md for a repo you cannot push to.
```

## The ideas

- **Secrets never touch git.** Each repo gets a committed `.env.tpl` that mirrors its `.env.example` line for line, with secret values replaced by 1Password `op://` references. `machine-sync in` runs `op inject` to materialize the real `.env`. No git-crypt, no key transfer between machines; 1Password already syncs and encrypts.
- **Push before you leave.** `out` refuses to let unpushed work sit on a machine you are about to abandon. It prompts before touching any remote and never force-pushes.
- **Read-only repos still get a handoff.** For org repos where your account cannot push or open a PR, `package` builds one self-contained markdown changeset from the committed branch: apply instructions, new files in full (five-tilde fences so inner code blocks survive), modified files as additive diff snippets, a commit message and PR title. The maintainer's agent re-applies it. Outbox is gitignored and pruned after 14 days.
- **Drift is surfaced, not fixed silently.** Tool versions are checked against a pinned manifest; worktrees and scheduled jobs are compared across machines; anything off is printed, never auto-changed.
- **Never prints secret values.** Ever.

## Layout

| Path | What |
|---|---|
| `bin/machine-sync` | the tool (bash, no dependencies beyond git, gh, and the 1Password CLI) |
| `env-templates/<repo>.env.tpl` | per-repo templates with `op://` references; see `example-project.env.tpl` |
| `env-manifest/versions.lock` | pinned tool versions checked by `doctor` and `in` |
| `outbox/` | generated changesets (gitignored) |

## Setup

1. Install the 1Password CLI and sign in; `gh auth login`.
2. Clone this repo to `~/.dotfiles` on each machine and symlink `bin/machine-sync` into your `PATH`.
3. For each repo, create `env-templates/<repo>.env.tpl` from its `.env.example`, replacing secret values with `op://<vault>/<item>/<field>`. One gotcha: `op inject` parses `op://` inside comments too, so never spell the scheme in prose within a template.
4. `machine-sync doctor`, then `machine-sync in`.

Override paths with `MACHINE_SYNC_GH_DIR`, `MACHINE_SYNC_DOTFILES_DIR`, `MACHINE_SYNC_TPL_DIR`, `MACHINE_SYNC_VERSION_LOCK`, `MACHINE_SYNC_OUTBOX`, `MACHINE_SYNC_BASE`.

MIT licensed. Built by Matt Walker for a two-Mac workflow; shared as a pattern.
