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
- **Drift is surfaced, not fixed silently.** Tool versions are checked against a pinned manifest; each `.env.tpl` is checked key-for-key against its repo's `.env.example`; worktrees are split into still-open vs already-merged (prune candidates); anything off is printed, never auto-changed.
- **A dirty tree does not block a safe pull.** `in` fast-forwards a behind repo even with uncommitted files, unless one of those files was also changed upstream — then it names the blocking files instead.
- **launchd agents travel too.** Plists tracked under `home/Library/LaunchAgents/` carry a `__HOME__` token so one file installs under any login; `in` renders, installs and loads them on ask, and `env-manifest/launchd-hosts.txt` pins hub-only jobs to a single host so they never double-run.
- **Never prints secret values.** Ever.

## Layout

| Path | What |
|---|---|
| `bin/machine-sync` | the tool (bash, no dependencies beyond git, gh, and the 1Password CLI) |
| `env-templates/<repo>.env.tpl` | per-repo templates with `op://` references; see `example-project.env.tpl` |
| `env-manifest/versions.lock` | pinned tool versions checked by `doctor` and `in` |
| `env-manifest/no-env-repos.txt` | repos with a `.env.example` that are intentionally not provisioned on this machine |
| `env-manifest/launchd-hosts.txt` | which host(s) each tracked launchd agent belongs on |
| `home/Library/LaunchAgents/*.plist` | tracked launchd agents (`__HOME__` token); see `com.example.nightly-collector.plist` |
| `outbox/` | generated changesets (gitignored) |

## Setup

1. Install the 1Password CLI and sign in; `gh auth login`.
2. Clone this repo to `~/.dotfiles` on each machine and symlink `bin/machine-sync` into your `PATH`.
3. For each repo, create `env-templates/<repo>.env.tpl` from its `.env.example`, replacing secret values with `op://<vault>/<item>/<field>`. One gotcha: `op inject` parses `op://` inside comments too, so never spell the scheme in prose within a template.
4. `machine-sync doctor`, then `machine-sync in`.

Override paths with `MACHINE_SYNC_GH_DIR`, `MACHINE_SYNC_DOTFILES_DIR`, `MACHINE_SYNC_TPL_DIR`, `MACHINE_SYNC_VERSION_LOCK`, `MACHINE_SYNC_OUTBOX`, `MACHINE_SYNC_BASE`, `MACHINE_SYNC_NO_ENV_LIST`, `MACHINE_SYNC_LAUNCHD_DIR`, `MACHINE_SYNC_LAUNCHD_HOSTS`, and `MACHINE_SYNC_LAUNCHD_PREFIXES` (label prefixes that count as "yours" when spotting untracked live agents; default `com.example.`).

MIT licensed. Built by Matt Walker for a two-Mac workflow; shared as a pattern.
