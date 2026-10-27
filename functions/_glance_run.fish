function _glance_run --description "Print and run the glance commands for the current directory"
    set -l commands
    # An empty glance_git_commands disables the git part, so don't even call git
    if not set -q glance_git_commands; or set -q glance_git_commands[1]
        # Prints "true" in a work tree ("false" inside .git), then HEAD if there is a commit
        set -l git_info $(command -q git; and command git rev-parse --is-inside-work-tree --verify -q HEAD 2>/dev/null)
        if test "$git_info[1]" = true
            if set -q glance_git_commands
                set commands $glance_git_commands
            else
                # git log fails in a repo with no commits yet
                set -q git_info[2]; and set commands "git log --oneline -5"
                set -a commands "git status --short --branch"
            end
        end
    end
    if set -q glance_commands
        set -a commands $glance_commands
    else
        set -a commands ls
    end
    set commands $(string match -rv '^\s*$' -- $commands)
    set -q commands[1]; or return 1

    set -l prefix ' ❯ '
    set -q glance_prefix; and set prefix $glance_prefix
    set -l prefix_color brgreen
    set -q glance_color_prefix; and set prefix_color $glance_color_prefix
    set -l command_color yellow
    set -q glance_color_command; and set command_color $glance_color_command
    # An empty color means no color; a bare set_color is an error
    set -q prefix_color[1]; or set prefix_color normal
    set -q command_color[1]; or set command_color normal

    # The first command lands right after the prompt, as if it had been typed
    set -l first true
    for cmd in $commands
        if test -z "$first"
            printf '\n'
            set_color $prefix_color
            printf '%s' $prefix
        end
        set first
        set_color $command_color
        printf '%s\n' $cmd
        set_color normal
        eval $cmd
    end
    return 0
end
