function _glance_run --description "Print and run the glance commands for the current directory"
    set -l commands
    if command -q git; and test "$(command git rev-parse --is-inside-work-tree 2>/dev/null)" = true
        if set -q glance_git_commands
            set commands $glance_git_commands
        else
            set commands "git log --oneline -5" "git status --short --branch"
        end
    end
    if set -q glance_commands
        set -a commands $glance_commands
    else
        set -a commands ls
    end
    test (count $commands) -gt 0; or return 1

    set -l prefix ' ❯ '
    set -q glance_prefix; and set prefix $glance_prefix
    set -l prefix_color brgreen
    set -q glance_color_prefix; and set prefix_color $glance_color_prefix
    set -l command_color yellow
    set -q glance_color_command; and set command_color $glance_color_command

    # The first command lands right after the prompt, as if it had been typed
    for i in (seq (count $commands))
        if test $i -gt 1
            printf '\n'
            set_color $prefix_color
            printf '%s' $prefix
        end
        set_color $command_color
        printf '%s\n' $commands[$i]
        set_color normal
        eval $commands[$i]
    end
    return 0
end
