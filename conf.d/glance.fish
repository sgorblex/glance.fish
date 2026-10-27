status is-interactive || exit

bind --mode default enter _glance_enter
bind --mode insert enter _glance_enter

function _glance_uninstall --on-event glance_uninstall
    bind --erase --mode default enter
    bind --erase --mode insert enter
    functions --erase _glance_uninstall
end
