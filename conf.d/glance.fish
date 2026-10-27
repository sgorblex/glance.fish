status is-interactive || exit

bind --mode default enter _glance_enter
bind --mode insert enter _glance_enter

function _glance_uninstall --on-event glance_uninstall
    # Leave alone an enter binding the user set after loading glance
    for mode in default insert
        if bind --user --mode $mode enter 2>/dev/null | string match -q '* _glance_enter'
            bind --erase --mode $mode enter
        end
    end
    functions --erase _glance_uninstall
end
