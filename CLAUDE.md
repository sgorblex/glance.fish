# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# glance.fish

Fish plugin (Fisher layout): pressing Enter on an empty prompt prints and runs a few "where am I" commands (git log/status inside a work tree, then `ls`). A non-empty command line executes normally.

## Layout

- `conf.d/glance.fish`: binds `enter` in `default` and `insert` modes (interactive shells only); `glance_uninstall` event handler erases the bindings.
- `functions/_glance_enter.fish`: the Enter handler. Decides between running glance and `commandline -f execute`.
- `functions/_glance_run.fish`: builds the command list from the config variables, prints and `eval`s each one. Returns 1 when there is nothing to run, so the handler falls back to a normal Enter.
- `tests/glance.fish`: self-contained tests for `_glance_run` (no test framework).
- `.github/workflows/ci.yml`: `fish_indent --check` + tests on fish 4 (Ubuntu, `ppa:fish-shell/release-4`). Not run yet.

## Conventions

- Target fish ≥ 4.0. Use modern syntax: `$(...)`, `path`, fish 4 key names (`enter`, not `\r`).
- Code must pass `fish_indent --check` (4 spaces).
- Internal functions are `_glance_*`. Do not add a bare `glance` command: it would hide other tools named `glance` (glanceapp/glance, OpenStack Glance).
- User config is plain variables, read at run time, never set by the plugin: `glance_git_commands`, `glance_commands`, `glance_prefix`, `glance_color_prefix`, `glance_color_command`. Keep the README table in sync.
- Commands run inside the key binding (like fzf.fish), not by replacing the command line, so they stay out of history and `$status` is preserved.

## Behaviour that must not regress

- "Empty" means the whole buffer (`commandline`), not the current job (`commandline -j`). Otherwise `sleep 1 &`, `foo; ` or a blank line inside an unfinished `if` block wrongly trigger glance.
- Git detection checks that `git rev-parse --is-inside-work-tree` *prints* `true`; inside `.git` it succeeds but prints `false`.
- With the completion pager open, Enter must accept the selection (`commandline --paging-mode` check).
- In vi normal mode, Enter switches back to insert mode, like fish's preset binding. Vi mode is detected by the presence of a preset `insert`-mode `enter` binding (absent with emacs bindings).
- Commands are printed with `printf '%s\n'`, never as a format string.
- Fish's vi bindings only erase *preset* bindings, so the plugin's bindings survive a later `set fish_key_bindings fish_vi_key_bindings` in the user's config.fish.

## Testing

- Unit: `fish tests/glance.fish`, and `fish_indent --check conf.d/*.fish functions/*.fish tests/*.fish` (`fish_indent -w <files>` fixes formatting).
- The test script has no per-test selection: cases run in order and share global state (later cases set `glance_commands`/`glance_prefix` and never reset them), so add new cases where that state is what you want, or reset the variables. Output is compared with ANSI colour codes stripped (`glance_output`).
- Interactive behaviour (bindings, modes, pager) can't be unit tested. Test it in a throwaway tmux session with an isolated config so the user's real shell and history are untouched:
  - `XDG_CONFIG_HOME=<tmp>/cfg XDG_DATA_HOME=<tmp>/data fish`, with the plugin's `conf.d/` and `functions/` copied into `<tmp>/cfg/fish/`.
  - Drive it with `tmux send-keys -l` (literal; tmux otherwise treats `;` as a separator) and read it with `tmux capture-pane -p`.
  - Cover vi and emacs bindings.
- Fisher: `fisher install <path to repo>` / `fisher remove` with the same isolated XDG dirs (copy `fisher.fish` into the temp functions dir).

## Origin

Extracted from the author's dotfiles (`~/dotfiles/fish/.config/fish/overrides.fish`), which still contain the original version. The author's own settings would be `set -g glance_git_commands "git l -5" "git status"` (`git l` is a personal alias).
