#!/bin/bash

eselect()
{
    local application="${1}"
    local version="${2}"

    if [[ -h "${application}" ]]; then
        unlink "${application}"
    fi

    if [[ -f "${application}" ]]; then
        echo "${application} is an executable and not a symbolic link. Refusing to overwrite." >&2
        return 1
    fi

    local appimage=".appcache/${application}/${application}-${version}-$(arch).appimage"
    if [[ -x "${appimage}" ]]; then
        echo "Selecting ${appimage} for ${application}"

        ln -sT "${appimage}" "${application}"
    else
        echo "${appimage} is not executable." >&2
    fi
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
    if [[ ! -d ".appcache/${app}" ]]; then
        return 0
    fi

    local arch="$(arch)"
    ls -l .appcache/${app}/*.appimage | awk '{print $9}' | sed -e "s#.appcache/${app}/${app}-\(.*\).${arch}.appimage#\\1#"
}

__eselect_completions()
{
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local prev="${COMP_WORDS[COMP_CWORD-1]}"
    local cmds="$(find .appcache -maxdepth 1 -a -type d)"
    local likely=""

    local likely=""
    if [[ -n "${prev}" && "${prev}" != "eselect" ]]; then
        for version in $(__eselect_versions "${prev}"); do
            if [[ "${version}" =~ ^${cur} ]]; then
                likely="${likely} ${version}"
            fi
        done

    else
        likely="$(__eselect_apps "${cur}")"
    fi

    COMPREPLY=( $(compgen -W "${likely}") )
}

complete -F __eselect_completions eselect
