#!/bin/bash

eselect()
{
    local application="${1}"
    local appimage="${2}"

    if [[ -h "${application}" ]]; then
        unlink "${application}"
    fi

    if [[ -f "${application}" ]]; then
        echo "${application} is an executable and not a symbolic link. Refusing to overwrite." >&2
        return 1
    fi

    echo "Selecting ${appimage} for ${application}"

    ln -sT "${appimage}" "${application}"
}

__eselect_apps()
{
    local app="${1:-}"
    for item in $(find .appcache -maxdepth 1 -name "${app}*" -a -type d); do
        echo "${item}" | cut -s -d/ -f2-
    done
}

__eselect_versions()
{
    local app="${1}"
    local arch="$(arch)"
    if [[ ! -d ".appcache/${app}" ]]; then
        echo "No application cache for '${app}' found." >&2
        return 1
    fi

    ls -l .appcache/${app}/*.appimage | awk '{val = $9; sub(".appcache/'${app}'/'${app}'-", "", val); sub(".'${arch}'.appimage", "", val); print val}'
}

__eselect_completions()
{
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local prev="${COMP_WORDS[COMP_CWORD-1]}"
    local cmds="$(find .appcache -maxdepth 1 -a -type d)"
    local likely=""

    if [[ -z "${cur}" ]]; then
        for item in ${cmds}; do
            item="$(echo -n "${item}" | cut -d/ -f1-)"
            echo "Item: ${item}"
            if [[ "${item}" =~ "^${cur}" ]]; then
                likely="${likely} ${item}"
            fi
        done
        return 0
    else
        for app in $(ls .appcache/${prev}/*.appimage); do
            likely="${likely} $(echo -n "${app}" | cut -d/ -f1-)"
        done
    fi

    echo "Likely: ${likely}"
    COMPREPLY=( $(compgen -W "${likely}") )
}

complete -F __eselect_completions eselect
