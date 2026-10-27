# Run with: fish --no-config tests/glance.fish
# (--no-config keeps the user's config.fish and universal glance_* variables out)
set -g fish_function_path (path resolve (status dirname)/../functions) $fish_function_path
set -g failed 0

function check -a name expected actual
    if test "$expected" = "$actual"
        echo "ok   $name"
    else
        echo "FAIL $name"
        echo "  expected: $(string escape -- $expected)"
        echo "  actual:   $(string escape -- $actual)"
        set -g failed 1
    end
end

function glance_output
    _glance_run 2>&1 | string replace -ra '\e\[[0-9;]*m|\e\(B' '' | string collect
end

function reset_config
    set -e glance_git_commands glance_commands glance_prefix glance_color_prefix glance_color_command
end

set -l tmp (mktemp -d)
mkdir $tmp/plain $tmp/repo $tmp/empty-repo
touch $tmp/plain/afile
git -C $tmp/repo init -q
git -C $tmp/repo -c user.name=t -c user.email=t@t commit -q --allow-empty -m first
git -C $tmp/empty-repo init -q

cd $tmp/plain
check "plain dir runs ls" "ls
afile" (glance_output)

cd $tmp/repo
check "repo runs git commands first" "git log --oneline -5
$(git log --oneline -5)

 ❯ git status --short --branch
## $(git branch --show-current)

 ❯ ls" (glance_output)

cd $tmp/empty-repo
check "repo without commits skips git log" "git status --short --branch
## No commits yet on $(git branch --show-current)

 ❯ ls" (glance_output)

cd $tmp/repo/.git
check ".git dir is not a work tree" ls (glance_output | head -n1)

cd $tmp/plain
set -g glance_commands "echo 50%" "echo b"
set -g glance_prefix "-> "
check "custom commands and prefix" "echo 50%
50%

-> echo b
b" (glance_output)

set -g glance_commands "echo a" "" "  " "echo b"
check "blank commands are skipped" "echo a
a

-> echo b
b" (glance_output)
reset_config

set -g glance_commands
_glance_run >/dev/null
check "no commands returns 1" 1 $status

set -g glance_commands ""
_glance_run >/dev/null
check "only blank commands returns 1" 1 $status
reset_config

cd $tmp/repo
set -g glance_git_commands "echo git"
set -g glance_commands "echo all"
check "custom git commands" "echo git
git

 ❯ echo all
all" (glance_output)

set -g glance_git_commands
check "empty git commands disables them" "echo all
all" (glance_output)

set -g glance_commands
_glance_run >/dev/null
check "repo with no commands returns 1" 1 $status
reset_config

cd $tmp/plain
set -g glance_color_prefix
set -g glance_color_command
check "empty colors mean no color" "ls
afile" (glance_output)
reset_config

rm -rf $tmp
exit $failed
