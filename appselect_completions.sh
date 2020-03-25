#!/bin/bash

__appselect_apps()
{
    local app="${1:-}"
    for item in $(find "${HOME}/bin/.appcache" -maxdepth 1 -name "${app}*" -a -type d); do
        echo "${item}" | sed -e "s#${HOME}/bin/.appcache/\?##"
    done
}

__appselect_versions()
{
    local app="${1}"
    if [[ ! -d "${HOME}/bin/.appcache/${app}" ]]; then
        return 0
    fi

    local arch="$(arch)"
    ls -l ${HOME}/bin/.appcache/${app}/*.appimage | \
        awk '{print $9}' | \
        sed -e "s#${HOME}/bin/.appcache/${app}/${app}-\(.*\).${arch}.appimage#\\1#"
}

__appselect_completions()
{
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local prev="${COMP_WORDS[COMP_CWORD-1]}"
    local cmds="$(find "${HOME}/bin/.appcache" -maxdepth 1 -a -type d)"
    local likely=""

    local likely=""
    if [[ -n "${prev}" && "${prev}" != "appselect" ]]; then
        for version in $(__appselect_versions "${prev}"); do
            if [[ "${version}" =~ ^${cur} ]]; then
                likely="${likely} ${version}"
            fi
        done

    else
        likely="$(__appselect_apps "${cur}")"
    fi

    COMPREPLY=( $(compgen -W "${likely}") )
}

complete -F __appselect_completions appselect
