# srt-agent

`srt-agent` runs AI coding agents — Claude Code, Codex, pi, dsh, or any agent you define — inside Anthropic's [sandbox-runtime](https://github.com/anthropic-experimental/sandbox-runtime) (`srt`) on macOS. Each launch builds one complete sandbox policy from your configuration, asks you to approve anything new or looser, and starts the agent with its own private home, temp folder and environment.

It is a single Python file, run by Apple's `/usr/bin/python3` in isolated mode (`-I`), using only the standard library.

- [Why](#why)
- [Requirements and installation](#requirements-and-installation)
- [Quick start](#quick-start)
- [How a launch is put together](#how-a-launch-is-put-together)
- [Files and folders](#files-and-folders)
- [The global config](#the-global-config)
- [Project files](#project-files)
- [Groups](#groups)
- [Agent groups](#agent-groups)
- [Generating groups for tools](#generating-groups-for-tools)
- [The template home](#the-template-home)
- [Network and filesystem rules](#network-and-filesystem-rules)
- [Switches](#switches)
- [Approvals](#approvals)
- [Importing ~/.srt-settings.json](#importing-srt-settingsjson)
- [Environment variables](#environment-variables)
- [Python](#python)
- [Agents, homes and storage](#agents-homes-and-storage)
- [Commands](#commands)
- [Claude cross-session messaging](#claude-cross-session-messaging)
- [Checking a setup](#checking-a-setup)
- [macOS notes](#macos-notes)
- [Troubleshooting](#troubleshooting)
- [Security model and limits](#security-model-and-limits)

## Why

Coding agents run shell commands. Running them unsandboxed gives every command your full account: your SSH keys, cloud credentials, browser data, every project. `srt` confines a process with macOS Seatbelt and a filtering network proxy. `srt-agent` makes that practical day to day:

- **Deny by default.** Nothing in your home folder is readable unless granted. Network access is limited to listed domains. Host environment variables are not passed unless listed.
- **Per project, per agent.** Each project gets its own storage outside the project folder; each agent gets its own home there, so Codex never sees Claude's credentials and one project's agent never sees another project's.
- **Reviewed changes.** Every change to what an agent may do — a new domain, a new read path, a group file edit — needs your approval before the next launch, and loosening changes get their own explicit questions.
- **Reusable pieces.** Groups (`lang/rust`, `tool/rg`, …) bundle grants per language or tool, generated from Homebrew's own records.

## Requirements and installation

- macOS (Apple Silicon or Intel).
- `srt` on your `PATH` (or `SRT_AGENT_SRT=/path/to/srt`).
- The agents you want to run (`claude`, `codex`, `pi`, `dsh`, …).
- Apple's Command Line Tools (for `/usr/bin/python3` and `otool`).

Install the launcher and give it short aliases:

```sh
install -m 755 srt-agent ~/.local/bin/srt-agent
```

```sh
# ~/.zshrc — use the literal path, not $HOME
alias claude='/Users/you/.local/bin/srt-agent run claude'
alias codex='/Users/you/.local/bin/srt-agent run codex'
alias pi='/Users/you/.local/bin/srt-agent run pi'
alias dsh='/Users/you/.local/bin/srt-agent run dsh'
```

`SRT_AGENT_<AGENT>` (upper case, `-` as `_`) overrides where an agent's executable is found, e.g. `SRT_AGENT_CLAUDE=/path/to/claude`.

## Quick start

1. Create the global config, `~/.config/srt-agent/config.jsonc`. It is the baseline for every agent and project; review it line by line. A minimal start:

   ```jsonc
   {
     "network": {
       "allowedDomains": ["github.com", "*.github.com", "*.githubusercontent.com"],
       "allowUnixSockets": ["/private/var/run/mDNSResponder"],
       "allowMachLookup": ["com.apple.trustd.agent", "com.apple.dnssd.service",
                           "com.apple.SystemConfiguration.DNSConfiguration",
                           "com.apple.SystemConfiguration.configd"],
     },
     "filesystem": {
       "allowRead": ["/bin", "/sbin", "/usr", "/etc", "/private/etc",
                     "/dev/null", "/dev/zero", "/dev/random", "/dev/urandom", "/dev/tty", "/dev/fd",
                     "/System/Library", "/System/Cryptexes/OS",
                     "/Library/Developer", "/Library/Frameworks",
                     "/opt/homebrew/bin", "/opt/homebrew/sbin",
                     "/opt/homebrew/opt", "/opt/homebrew/Frameworks"],
     },
     "setEnv": {"DEVELOPER_DIR": "/Library/Developer/CommandLineTools"},
     "agents": {
       "claude": {"network": {"allowedDomains": ["api.anthropic.com", "claude.ai", "*.claude.ai",
                                                 "claude.com", "*.claude.com"]}},
     },
   }
   ```

2. In a project, create its project file and launch:

   ```sh
   cd ~/Projects/myapp
   srt-agent project init --extends lang/rust     # writes .srt-agent.jsonc
   claude                                         # asks for approval the first time
   ```

3. Preview without launching or approving: `srt-agent run --show claude`.

## How a launch is put together

Each launch merges these layers, in this order (later layers add to lists and win on single values):

| # | Layer | Where | Approval |
|---|---|---|---|
| 1 | Imported srt file (optional) | `~/.srt-settings.json` via `baseSettings` | global |
| 2 | Global config | `~/.config/srt-agent/config.jsonc` | global |
| 3 | Agent entry | `agents.<name>` in the global config | global |
| 4 | Agent group (automatic) | `groups/agent/<agent>.jsonc` and what it extends | global |
| 5 | Template home | `~/.config/srt-agent/home/` | global |
| 6 | Project groups | groups listed in the project's `extends` | per project |
| 7 | Project file | `<project>/.srt-agent.jsonc` | per project |
| 8 | Launcher protections | built in | — |

The launcher then adds its own blocks — reads of `/` and your home, writes to its own state, other agents' storage, `PATH` folders, Git hooks and similar — writes the result to a fresh policy file, and runs `srt --settings <policy> -- <agent>`. `srt` never reads your configuration directly.

## Files and folders

```
~/.config/srt-agent/
  config.jsonc                 global config
  groups/                      group files, one per group
    lang/rust.jsonc            "lang/rust"
    tool/rg.jsonc              "tool/rg"
    lib/node.jsonc             "lib/node"
    agent/pi.jsonc             applied automatically for pi
  home/                        template home

<project>/.srt-agent.jsonc     project file

~/.local/share/srt-agent/projects/<name>-<id>/     project storage
  project.json                 identity record
  agents/<agent>/home/         that agent's HOME
  agents/<agent>/tmp/          that agent's TMPDIR
  shared/home/                 used instead with agentHome "shared"
  srt-tmp/<agent>/             srt's own temp (agents: no access)

~/Library/Caches/srt-agent/<name>-<id>/            project cache ({cache})
~/.local/state/srt-agent/approvals/                approval records
~/.local/state/srt-agent/policies/<project>/       generated policies
```

All config files are JSONC: `//` and `/* */` comments and trailing commas are allowed; duplicate keys, `NaN`/`Infinity` and stray commas are errors. Approvals bind the parsed content, so editing a comment never asks again. Any key the launcher does not know, at any level, is refused rather than ignored.

## The global config

`~/.config/srt-agent/config.jsonc` (or `SRT_AGENT_SETTINGS`, or `--settings`). Every file is *flat*: srt's two lists sit next to the launcher's own keys.

| Key | Meaning |
|---|---|
| `network` | `allowedDomains`, `deniedDomains`, `allowUnixSockets`, `allowMachLookup`, and the switches `allowLocalBinding`, `allowAllUnixSockets` |
| `filesystem` | `allowRead`, `denyRead`, `allowWrite`, `denyWrite` |
| `allowAppleEvents`, `enableWeakerNestedSandbox`, `enableWeakerNetworkIsolation` | [switches](#switches); `allowPty` may appear only as `true` |
| `agents` | per-agent additions, and custom agents ([below](#agents-homes-and-storage)) |
| `groups` | inline groups (group files are usually easier) |
| `passEnv` | host variables to pass into the sandbox (`*` suffix = prefix) |
| `setEnv` | variables to set (`~/` = your real home, `{cache}` = project cache) |
| `path` | extra folders appended to the agent `PATH` (readable, write-protected) |
| `toolsVenv` | a shared read-only Python venv for every project |
| `autoVenv` | use a project's `.venv` automatically |
| `agentHome` | `"isolated"` (default) or `"shared"` |
| `crossSessionMessaging` | Claude only: `"off"` (default), `"project"`, `"global"` |
| `baseSettings` | import `~/.srt-settings.json` ([below](#importing-srt-settingsjson)) |

`~/` in global paths means your **real** home, expanded before the agent's `HOME` is changed. Never write a bare `~` into `denyRead`: inside the sandbox `HOME` is the agent's home.

## Project files

A project is only accessible if it has a `.srt-agent.jsonc` in its root; there is no automatic current-directory access. The root is the nearest ancestor containing `.git` (found without running Git), otherwise the current directory.

```jsonc
{
  "extends": ["lang/rust", "tool/build"],
  "filesystem": {"allowRead": ["."], "allowWrite": ["."]},
  "network": {"allowedDomains": ["api.example.com"]},
  "setEnv": {"CARGO_HOME": "{cache}/cargo"},
  "remove": {"network": {"allowedDomains": ["github.com"]}},
}
```

| Key | Meaning |
|---|---|
| `extends` | groups to merge in, in order |
| `network`, `filesystem`, switches | as in the global config; relative paths are relative to the project root |
| `remove` | drop exact inherited entries (any of the four filesystem lists and four network lists) |
| `path`, `setEnv`, `agentHome` | as in the global config, for this project only |

`srt-agent project init [--extends a,b]` creates the file; existing files are never replaced. Write grants stay confined to the project. Reading your whole home, or starting from your home folder, needs `--allow-home` on every launch plus approval.

Removals match original inherited entries exactly. Removing an allow is not a deny, and removing a deny is not an allow; mandatory protections cannot be removed.

## Groups

Groups are reusable bundles a project pulls in with `extends`. Lists add up; for `setEnv`, later wins; the project's own entries come last.

**Group files** (recommended): `~/.config/srt-agent/groups/<name>.jsonc`, one group per file, the file name is the group name. Names may have one namespace folder: `groups/lang/php.jsonc` is `lang/php`. A suggested layout:

| Folder | For | Examples |
|---|---|---|
| `lang/` | languages and toolchains a project is written in | `lang/rust`, `lang/node`, `lang/php`, `lang/php82`, `lang/c` |
| `tool/` | programs a project calls | `tool/rg`, `tool/composer`, `tool/build` |
| `lib/` | building blocks other groups extend | `lib/node`, `lib/php-common` |
| `agent/` | applied automatically per agent | `agent/pi` |

A group file holds `network`, `filesystem`, `remove`, `path`, `setEnv`, switches and `extends`:

```jsonc
// groups/lang/php.jsonc
{
  "extends": ["lib/php-common", "tool/composer"],
  "filesystem": {"allowRead": ["/opt/homebrew/Cellar/php"]},
}
```

- **Extends:** a group's own `extends` come first, in order; a group reached through several paths is applied once, where it first appears. Cycles and unknown names stop every launch, with the chain shown (`a -> b -> a`).
- **Rules:** hidden files and names not ending in `.jsonc` are skipped (editor backups are safe); an invalid name, a broken link, or a group defined both inline and as a file stops every launch. Links are followed, so groups can live in your dotfiles.
- **Protection:** the `groups/` folder, its namespace folders and every group file's real target are write-protected inside the sandbox.
- **Approval:** a project's approval covers the group files it reaches. Editing `lib/php-common.jsonc` re-asks only projects that use it; adding a new group asks nothing until a project extends it. Inline groups in `config.jsonc` are part of the global config and re-ask every project.

## Agent groups

`groups/agent/<agent>.jsonc` is applied automatically whenever that agent runs, in every project — for agents that need more than their own executable, such as pi, which is a script that starts a node program from Homebrew:

```jsonc
// groups/agent/pi.jsonc
{
  "extends": ["lib/node"],
  "filesystem": {"allowRead": ["/opt/homebrew/Cellar/pi-coding-agent"]},
  "network": {"allowedDomains": ["api.anthropic.com"]},
  "setEnv": {"NODE_USE_ENV_PROXY": "1", "SSL_CERT_FILE": "/etc/ssl/cert.pem"},
}
```

Agent groups may hold `network.allowedDomains`, `filesystem.allowRead`, `path`, `setEnv` and `extends`; the groups they reach are held to the same keys (no writes, no switches). The agent's entry in `config.jsonc` wins on `setEnv`. Like that entry, agent groups count as global settings: changing one asks every project again. `--show` lists the `agent_groups` that applied.

Single-file agents (Claude Code's native build, Codex's Rust binary) need no agent group: the launcher always grants the agent's own executable.

## Generating groups for tools

```sh
srt-agent group create --tool rg                    # -> groups/tool/rg.jsonc
srt-agent group create dev --tool rg --tool fd      # one group, several tools
srt-agent group create agent/pi --tool pi
srt-agent group create lang/php86 --tool /opt/homebrew/opt/php@8.6/bin/php
srt-agent group update tool/rg                      # after brew install/upgrade
```

The generator inspects, and never runs, the program:

- **Homebrew:** its formula and every runtime dependency, read from Homebrew's `INSTALL_RECEIPT.json` records. Whole formula folders (`Cellar/<formula>`) are granted, so upgrades keep working.
- **Linked libraries:** `otool -L`, following `@rpath`, `@loader_path` and `@executable_path`. System libraries are skipped (already readable).
- **Scripts:** the interpreter from the `#!` line, recursively (`composer` → PHP, `http` → Python).
- **Package folders:** a global npm package's folder under `lib/node_modules` (never all of `lib/`); a Composer `vendor` folder (not its parent, which holds `auth.json`); a Python virtualenv (`uv tool`, `pipx`) as a whole; a self-contained Python (uv, python.org) with its standard library.
- **`path`:** a tool found outside the standard `PATH` folders gets a `path` entry so it is found by name — note that everything in that folder becomes readable.

The file's header records the command, each tool's location and anything unresolved. Existing files are never replaced without `update` or `--force`. What static inspection cannot see: files a tool opens only while running (config files, plugins); the sandbox log names them on first use.

## The template home

`~/.config/srt-agent/home/` mirrors an agent home and is applied at every launch, in every project: `common/` for every agent, then `<agent>/` (`claude/`, `codex/`, `pi/`, …), which wins where both have the same file. A file at `home/<scope>/<path>` lands at `<agent home>/<path>`; inside the sandbox `~` is the agent's home.

| In the template | In the agent home |
|---|---|
| regular file | copied at every launch and write-protected, so an agent cannot rewrite its own instructions |
| `<agent>/.seed/<path>` | copied only if missing, then the agent's to change (e.g. `codex/.seed/.codex/config.toml`) |
| link to a file outside the template | recreated as a link; the target is readable, not writable, and edits are live |

A link to a file inside the template is followed and copied, so one file can serve several names.

- **Allowed entries:** regular files, folders and links to files. Links to folders, broken links, links into srt-agent's storage, files over 1 MiB and special files stop the launch. `.local/bin` and `.claude/sessions` belong to the launcher.
- **Existing files:** a file the launcher did not write is kept as `<name>.srt-agent-backup-<time>` before being replaced. Files dropped from the template are removed if unchanged.
- **Shared homes:** with `"agentHome": "shared"`, two agents' folders may not both contain the same path.
- **Safety:** writes into the agent home go through descriptors that never follow links, so a link planted by an agent stops the launch. The template folder is write-protected inside the sandbox.
- **Approval:** the template is part of the global settings; changing it asks every project again. For a link only the link is approved; its target's content is live.
- **Checking:** `srt-agent run --show claude | jq '.template_files'`. An agent's home in a project appears the first time it runs there (`--show` counts).

Example — one real instructions file for all agents, plus notes only sandboxed agents see:

```
home/
  common/.srt-agent/global.md      -> link to ~/.agents/AGENTS.md
  common/.srt-agent/sandbox.md        sandbox notes
  claude/.claude/CLAUDE.md            @~/.srt-agent/global.md
                                      @~/.srt-agent/sandbox.md
  codex/.codex/AGENTS.md              "Before anything else, read ~/.srt-agent/global.md
                                       and ~/.srt-agent/sandbox.md and follow both."
  pi/.pi/agent/AGENTS.md           -> link to ~/.agents/AGENTS.md
  pi/.pi/agent/APPEND_SYSTEM.md    -> ../../../common/.srt-agent/sandbox.md
```

Claude imports both files; Codex has no import syntax, so it is told to read them; pi loads `AGENTS.md` from its agent folder and appends `APPEND_SYSTEM.md` to its system prompt. To confirm: `/memory` in Claude, pi's startup header, or ask any agent a question only those files answer.

## Network and filesystem rules

srt's precedence decides what the lists mean:

- **`allowRead` beats `denyRead`.** A read block inside a read grant does nothing. The launcher refuses such ineffective `denyRead` entries rather than letting them look protective. It checks literal paths and globs against literal grants fully (as written and with links resolved) and glob grants against each block's literal part; two partly overlapping globs cannot be decided, so a block that passes is not proven effective.
- **`denyWrite` beats `allowWrite`.** The launcher uses this for its protections, and refuses to launch if any write block would cover the agent's own home or temp folder.
- **Links in a grant are resolved** when the policy is built (`/var` becomes `/private/var`). Links *inside* a granted folder are not: following one needs the target to be granted too. That is why the Homebrew link folders (`bin`, `opt`, …) grant nothing by themselves.
- **Grants overlapping srt-agent's own storage or cache roots are refused**, except whole-home access with `--allow-home`.
- **Always blocked:** reading `/` and your home (except what is granted), `/root`, the launcher itself; writing the project's `.git/config`, `.git/hooks`, a `.git` gitlink file, `.envrc`, `.env` and `.vscode` (host tools would run what is planted there), every folder on the host or agent `PATH`, srt-agent's config, groups, template, approvals and policies.

Domains: wildcard entries like `*.github.com` cover subdomains. Domains go through srt's proxy; everything else on the network is blocked (`EPERM`). Tools that ignore proxy variables (plain Node) cannot connect; see [Troubleshooting](#troubleshooting).

## Switches

srt's on/off settings may be set in any layer; later layers win (project last). Turning one on is asked about at approval.

| Switch | Where | Effect when on |
|---|---|---|
| `allowLocalBinding` | `network` | agents may run servers listening on this Mac, and reach localhost |
| `allowAllUnixSockets` | `network` | every Unix socket, including Docker's (root) and agents holding your keys |
| `allowAppleEvents` | top level | agents may script other apps outside the sandbox |
| `enableWeakerNestedSandbox` | top level | weaker sandbox, for running inside Docker |
| `enableWeakerNetworkIsolation` | top level | weaker network isolation |

`--allow-local-binding` turns local binding on for one launch (for logins or a web UI). `allowPty` may appear only as `true` — agents run on their own pseudo-terminal. srt's proxy ports are never accepted.

## Approvals

A launch with new or changed global or project settings stops for approval at the terminal. The prompt shows:

1. the diff of the global config, imported file, agent group files and template since the last approval;
2. the diff of the project file and of every group file it reaches;
3. the resolved permissions;
4. **one question per kind of loosening** since the last approval, each listing exactly what changed — new domains, removed domain blocks, new Unix sockets, new Mach services, new read or write access outside the project, removed read or write blocks, and switches turned on. Risky sockets (Docker, ssh-agent and the like) and every switch are explained on their own line. Answering no to any question launches nothing;
5. the final question, `Approve these exact settings for this project?`.

Tightening changes ask nothing extra. The first approval of a project compares against the global baseline, so only what the project and its groups add gets a question. Read and write access inside the project itself is the normal workspace and appears only in the diff.

Approval records live in `~/.local/state/srt-agent/approvals` (write-protected). `srt-agent project approve` reviews without launching; `srt-agent project revoke` forgets the approval. `--show` previews without approving, and unattended launches fail if not approved. Files are re-checked after you answer, so a change during review aborts the launch.

## Importing ~/.srt-settings.json

By default `srt-agent` never reads `~/.srt-settings.json`; it stays srt's own file for running `srt` directly. To use it as inherited defaults for every agent:

```jsonc
"baseSettings": "~/.srt-settings.json",
```

The file must be strict JSON (no comments) with srt's lists and switches only; anything else is refused. Its lists come first and its switches are the first layer. Changes to it need approval and appear in the diff; agents cannot write it. These are defaults, not a floor: a project's approved `remove` can drop any imported entry, deny rules included.

## Environment variables

The environment is deny-by-default. Only terminal and locale variables, each agent's own documented settings (Claude: `ANTHROPIC_*`, `CLAUDE_CODE_*`; Codex: `OPENAI_*`; dsh: `DEEPSEEK_API_KEY`, `DSH_*`; pi: `PI_*`) and names listed in `passEnv` reach the sandbox. Cloud, GitHub and SSH-agent credentials are not inherited unless listed.

`setEnv` sets variables; precedence is global, then project, then the agent's. Launcher-managed names (`PATH`, `HOME`, `XDG_*`, proxies, `DYLD_*`, `LD_*`, …) cannot be set, except `TMPDIR`, which may point into `{cache}`.

`{cache}` at the start of a value names the project's own cache folder, `~/Library/Caches/srt-agent/<project>-<id>`, writable only for this project. It is outside the project, where srt's built-in blocks on `.vscode`, `.idea` and Git hooks do not apply, so crates and packages that ship such files unpack:

```jsonc
"setEnv": {"CARGO_HOME": "{cache}/cargo", "TMPDIR": "{cache}/tmp"}
```

## Python

- **Virtualenvs:** an activated venv (`VIRTUAL_ENV`) is carried into the sandbox: its `bin` comes first on `PATH`, and the venv and its base interpreter become readable. `--auto-venv` (or `"autoVenv": true`) uses the project's `.venv` when none is active; `--no-auto-venv` and `--no-venv` turn that off. Each venv's grants are approved once. A venv's `bin` and `pyvenv.cfg` are write-protected, so install packages that add commands on the host. Conda is not detected.
- **Shared tools venv:** `"toolsVenv": "~/.local/share/srt-agent/tools"` names one host-maintained, read-only venv for every project (spreadsheets, PDFs, …). Its `bin` comes after a project venv but before system Pythons, and a `toolpy` wrapper always runs it. Maintain it with the companion `update-tools` script (uv-managed Python, hash-pinned requirements).

## Agents, homes and storage

**Built-in agents:**

| Agent | Binary | Private config | Extra domains |
|---|---|---|---|
| `claude` | `claude` | `CLAUDE_CONFIG_DIR=<agent home>/.claude` | — |
| `codex` | `codex` | `CODEX_HOME=<agent home>/.codex` | OpenAI domains |
| `pi` | `pi` | `PI_CODING_AGENT_DIR=<agent home>/.pi/agent` | — (provider-specific) |
| `dsh` (alias `deepseek`) | `dsh` | `DSH_HOME=<agent home>/.dsh` | `api.deepseek.com` |

**Extending or adding agents**, in the global config:

```jsonc
"agents": {
  "codex": {"filesystem": {"allowRead": ["/opt/homebrew/Caskroom/codex"]}},
  "my-agent": {"binary": "my-agent", "homeEnv": {"MY_AGENT_HOME": ".my-agent"},
               "network": {"allowedDomains": ["api.example.com"]},
               "passEnv": ["EXAMPLE_API_KEY"], "setEnv": {"MY_AGENT_TELEMETRY": "0"}},
}
```

A custom agent requires `binary`; `homeEnv` paths are relative to its private home.

**Homes.** Each agent runs with `HOME` set to its own folder in the project's storage, so its logins, settings, history and caches stay apart from yours, from other agents and from other projects. Agents therefore sign in once per project. `"agentHome": "shared"` gives a project's agents one shared home — mutual trust: each can read the other's credentials and change its configuration. Temp folders stay per agent either way, and switching modes never merges state.

**Storage** lives under `~/.local/share/srt-agent/projects/<name>-<id>/`, where `<id>` is derived from the project's resolved path: renaming or moving a project starts fresh. An agent may write only its own `home` and `tmp`. Delete a retired project's storage and cache folders yourself.

`srt` itself runs with your real `HOME` and a sanitised `PATH`; the agent's home, `PATH` and variables apply only inside the sandbox, so nothing an agent writes is executed by `srt`. Host-side writes into agent-writable folders go through descriptors that never follow links, so a link planted by an agent stops the launch instead of redirecting a write.

## Commands

```
srt-agent run [options] AGENT [-- agent arguments]
srt-agent exec [options] AGENT [-- COMMAND...]     # a command, or $SHELL, in AGENT's sandbox
srt-agent project init [-e|--extends a,b] | approve | revoke
srt-agent group create [NAME] --tool PROGRAM [--tool ...] [--force]
srt-agent group update NAME
```

| Option | Meaning |
|---|---|
| `--show` | print the effective policy, environment, groups and template files; launch nothing |
| `--check` | test the protections inside srt without starting an agent |
| `-l`, `--allow-local-binding` | allow listeners and localhost for this launch |
| `--allow-home` | permit home launches and approved home-wide reads for this launch |
| `--project PATH` | use this project root |
| `--settings PATH` | use another global config |
| `--auto-venv`, `--no-auto-venv`, `--no-venv` | virtualenv handling for this launch |
| `--no-pty-isolation` | attach the agent directly to this terminal |
| `--resume [ID]` | Claude only, before `--` |
| `--cross-session-messaging off\|project\|global` | Claude only |

Launcher options go before the first `--`; everything after it is passed to the agent unchanged.

Interactive launches run the agent on a fresh pseudo-terminal in a new session, so it cannot type into your shell after it exits (`TIOCSTI`).

## Claude cross-session messaging

`"crossSessionMessaging": "project"` (or `--cross-session-messaging project`) lets Claude sessions of the same project message each other through sockets in Claude's own temp folder; `"global"` lets sessions in different projects do so through `~/.local/state/srt-agent-messaging`, which weakens per-project isolation. Credentials stay in each agent home; other agents never get a channel to Claude sessions. Switching scopes refuses while sessions of the same project are running.

## Checking a setup

```sh
srt-agent run --check claude                    # protections, PATH, srt independence
srt-agent run --show claude | jq '.policy'      # the exact policy srt gets
srt-agent run --show claude | jq '.environment, .agent_groups, .template_files'
srt-agent exec claude -- /bin/sh -c 'ls ~; echo $TMPDIR'
```

`--check` ends with a `SUMMARY` and any `SUMMARY WARNING` lines. Its independence test needs a domain that only `~/.srt-settings.json` allows: PASS means srt used only the generated policy; INCONCLUSIVE means the proxy could not be queried or answered unexpectedly.

To see what the sandbox blocked:

```sh
log stream --style compact --predicate 'sender == "Sandbox"'
```

## macOS notes

- **Homebrew.** `/opt/homebrew/bin`, `sbin`, `opt` and `Frameworks` hold links only; grant them globally so programs and libraries can be reached by their usual paths, and grant the real `Cellar/<formula>` folders per group. Do not grant `/opt/homebrew/lib` (global npm and pip packages live there), `/opt/homebrew/var` (service data: databases, logs), `Caskroom` as a whole, or `Library`.
- **Developer tools.** `/usr/bin/python3`, `cc`, `ar` and friends are xcrun stubs. Set `DEVELOPER_DIR` globally (`/Library/Developer/CommandLineTools`) so they do not need `/var/select`; the launcher then also runs its in-sandbox wrapper with the real Python. The stubs still try to write a cache under `/var/folders` (`couldn't create cache file … xcrun_db`) — harmless noise. `lang/c` sets `CC`, `CXX`, `AR`, `RANLIB`, `NM`, `STRIP` and `SDKROOT` to the real tools and puts the toolchain folder on `PATH` (for `clangd`).
- **Do not grant `/var`.** It is `/private/var`, including every app's per-user temp and cache folders.
- **AddressSanitizer works; lldb does not.** The ASan runtime ships with the Command Line Tools: `"$CC" -print-file-name=libclang_rt.asan_osx_dynamic.dylib`. To load a sanitized extension into an uninstrumented host such as Homebrew's `php`, run it with `DYLD_INSERT_LIBRARIES=<that path>`. lldb cannot attach to processes inside the sandbox; run it on the host. Crash reports in `~/Library/Logs/DiagnosticReports` can be granted read-only per project when needed.
- **Language servers** are programs the agent starts inside the sandbox; generate groups for them (`srt-agent group create lsp/typescript --tool typescript-language-server --tool tsc`) and extend them from the matching `lang/` group.
- **Keychain** is not isolated by `HOME`.

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `Operation not permitted` running a Homebrew tool | the formula's `Cellar` folder is not granted, or the link folders are not | add it to a group, or `srt-agent group create --tool NAME` |
| `dyld: Library not loaded: /opt/homebrew/opt/…` (blocked by sandbox) | `/opt/homebrew/opt` not granted, or the library's formula missing | grant the link folders globally; add the formula |
| `xcode-select: unable to read data link at '/var/select/developer_dir'` | `DEVELOPER_DIR` not set | set it in the global `setEnv` |
| `couldn't create cache file … xcrun_db` | xcrun stub cache under `/var/folders` | harmless; use `$CC` etc. from `lang/c` to avoid it |
| Node agent: `Connection error … EPERM` | Node connecting directly instead of through srt's proxy | `"NODE_USE_ENV_PROXY": "1"` in the agent's `setEnv` (recent Node); allow the provider's domain |
| `/tmp/…: Operation not permitted` | `/tmp` is not writable | use `$TMPDIR` |
| `Unknown group X` | the group file is missing or misnamed | create `groups/X.jsonc`; names may have one namespace folder |
| `denyRead … has no effect: allowRead … covers it` | the block sits inside a grant | remove it, or narrow the grant |
| `denyWrite … covers the agent's own folder` | a write block covers the agent home or temp | narrow the block |
| An agent does not see a file in its home | the template applies only at launch, and only to agents that have run | launch once; `--show` lists `template_files` |

## Security model and limits

What the sandbox gives you: an agent can read only what is granted, write only its project, its own home and temp (and `{cache}` if used), reach only listed domains through srt's proxy, and see only the environment variables listed. It cannot change its own policy, approvals, groups, template or global instructions, nor plant commands on any `PATH` or in Git hooks.

What it does not:

- Agents of one project share the project's files and its `{cache}`: separate homes keep credentials apart, not their work.
- The macOS Keychain is not isolated by `HOME`.
- `--allow-local-binding` and `allowedDomains: ["localhost"]` let an agent reach every service listening on your Mac, including root-owned ones.
- Any Unix socket you grant is a door to a process outside the sandbox (Docker's socket means root). The approval prompt warns about the common ones.
- An agent can run `sudo`; it still needs your password. Never approve a password or Touch ID prompt you did not start yourself.
- The ineffective-`denyRead` check is the launcher's reading of srt's glob syntax, not srt's own matcher.
- Approval is the real control for everything a project file asks for. The prompts are designed to make loosening obvious; read them.
