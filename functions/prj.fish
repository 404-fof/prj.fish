#!/usr/bin/fish

function prj -d 'Manage remote and local repository'
    set GhqRoot (ghq root)
    set -l Project (__project_fzf)
    if test $Project = ''
        return
    end
    set -l PrjType (echo $Project | awk '{print $1}')
    set -l Project (echo $Project | awk '{print $2}')
    switch $PrjType
        case ''
            set Menu \
'  Open
  View on GitHub'
        case ''
            set Menu \
'  Open
  Create repository'
        case ''
            set Menu \
'  Clone
  View on GitHub'
    end
    set -l Action (echo $Menu | \
        fzf | \
        awk '{print $1}' \
        )
    switch $Action
        case ''
            cd "$GhqRoot/github.com/$Project"
        case ''
            gh browse --repo $Project
        case ''
            ghq get $Project
        case ''
            gh repo create --private --source "$GhqRoot/github.com/$Project"
    end
end

function __project_fzf
    set GhqRoot (ghq root)
    set -l FzfOpt 'GH_FORCE_TTY=$FZF_PREVIEW_COLUMNS'
    echo (__project_list | \
        fzf --ansi --preview \
            "test {1} = '' &&
                glow --style=dark $GhqRoot/github.com/{2}/README.md ||
                $FzfOpt gh repo view {2} 2> /dev/null" \
        )
end

function __project_list
    set -l Local (ghq list | awk -F 'github.com/' '{print $2}')
    set -l Remote (gh repo list --json isPrivate,nameWithOwner --template '{{range .}}{{tablerow .nameWithOwner}}{{end}}')
    set -l Prj (echo $Local $Remote | sd ' ' '\n' | awk 'a[$0]++')

    for Project in $Prj
        echo '  '(set_color green)$Project(set_color normal)
    end
    for Project in $Local
        if ! contains $Project $Prj
            echo '  '(set_color yellow)$Project(set_color normal)
        end
    end
    for Project in $Remote
        if ! contains $Project $Prj
            echo '  '(set_color cyan)$Project(set_color normal)
        end
    end
end
