# glance.fish

Press <kbd>Enter</kbd> on an empty [fish](https://fishshell.com) prompt to take a quick look at where you are.

```
~/glance.fish> git log --oneline -5
3f2a1c9 Add configurable prefix
8be04d1 Initial commit
 ❯ git status --short --branch
## main
 M README.md
 ❯ ls
LICENSE  README.md  conf.d  functions  tests
```

Inside a git work tree glance shows recent commits and the status; everywhere else it runs `ls`.
Each command is echoed before it runs, so you always know what you are looking at.
A non-empty command line is executed as usual, and glance never touches your history or `$status`.

## Installation

With [Fisher](https://github.com/jorgebucaran/fisher):

```fish
fisher install sgorblex/glance.fish
```

Requires fish 4.0 or newer.

## Configuration

Set any of these variables in your `config.fish`:

| Variable               | Default                                                 | Meaning                                           |
| ---------------------- | ------------------------------------------------------- | ------------------------------------------------- |
| `glance_git_commands`  | `"git log --oneline -5" "git status --short --branch"`  | Commands run first inside a git work tree         |
| `glance_commands`      | `ls`                                                    | Commands run everywhere                           |
| `glance_prefix`        | `' ❯ '`                                                 | Printed before every command but the first        |
| `glance_color_prefix`  | `brgreen`                                               | `set_color` arguments for the prefix              |
| `glance_color_command` | `yellow`                                                | `set_color` arguments for the echoed commands     |

Each command is a string run with `eval`, so aliases, functions and pipes all work:

```fish
set -g glance_git_commands "git log --oneline --graph -5" "git status"
set -g glance_commands "ls -lh | head"
```

Setting a list to nothing disables it, and blank commands are skipped; if there is nothing to run, <kbd>Enter</kbd> behaves normally.
Setting a color to nothing prints that part without color.
In a repository with no commits yet, the default `git log` is left out.

The first command is printed right after your prompt, as if you had typed it, so the prefix is only used from the second command on.

## Key bindings

glance binds <kbd>Enter</kbd> in the `default` mode and, for vi key bindings, in the `insert` mode.
In vi normal mode, <kbd>Enter</kbd> switches back to insert mode, like fish's own binding does.

If you bind <kbd>Enter</kbd> yourself after glance is loaded, your binding wins.
To call glance from another key, bind it to `_glance_enter`.

## License

[MIT](LICENSE)
