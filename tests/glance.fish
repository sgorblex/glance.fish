# Run with: fish tests/glance.fish
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
    _glance_run | string replace -ra '\e\[[0-9;]*m|\e\(B' '' | string collect
end

set -l tmp (mktemp -d)
mkdir $tmp/plain $tmp/repo
touch $tmp/plain/afile
git -C $tmp/repo init -q
git -C $tmp/repo -c user.name=t -c user.email=t@t commit -q --allow-empty -m first

cd $tmp/plain
check "plain dir runs ls" "ls
afile" (glance_output)

cd $tmp/repo
check "repo runs git commands first" "git log --oneline -5
$(git log --oneline -5)

 ❯ git status --short --branch
## $(git branch --show-current)

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

set -g glance_commands
_glance_run >/dev/null
check "no commands returns 1" 1 $status

rm -rf $tmp
exit $failed
