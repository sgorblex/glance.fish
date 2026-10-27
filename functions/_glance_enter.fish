function _glance_enter --description "Run glance on an empty command line, otherwise execute it"
    # Like the preset binding, Enter in vi normal mode returns to insert mode
    if test "$fish_bind_mode" = default; and bind --preset --mode insert enter &>/dev/null
        set -g fish_bind_mode insert
        commandline -f repaint-mode
    end

    if test -n "$(commandline)"; or commandline --paging-mode
        commandline -f execute
        return
    end

    if _glance_run
        printf '\n\n'
        commandline -f repaint
    else
        commandline -f execute
    end
end
