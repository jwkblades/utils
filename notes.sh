#!/bin/bash
note()
{
    local notebook="${@//:/\/}"
    local filename="$(basename "${notebook}" ".md")"
    local path="$(dirname "${notebook}${filename}")"
    echo "Working on '${@}', base='${path}', file='${filename}'" >&2
    if [[ ${notebook} =~ \/$ || -z "${notebook}" ]]; then
        filename="$(date +"%Y%m%d-%H%M%S")"
        path="$(dirname "${notebook}${filename}")"
    fi

    if [[ "${@}" =~ ^\.\/.*?\.md$ ]]; then
        ${EDITOR} "${@}"
    else
        mkdir -p "${HOME}/notes/${path}"
        ${EDITOR} "${HOME}/notes/${path}/${filename}.md"
    fi
}

vnote()
{
    if [[ -n "${1}" ]]; then
        if [[ "${1}" =~ ^\.\/.*?\.md$ ]]; then
            pandoc -f gfm "${1}" | w3m -T text/html
        elif [[ -f "${HOME}/notes/${1}.html" ]]; then
            xdg-open "${HOME}/notes/${1}.html"
        else
            pandoc -f gfm ${HOME}/notes/${1}.md | w3m -T text/html
        fi
    else
        echo "No note specified."
    fi
}

cnote()
{
    if [[ -n "${1}" ]]; then
        pandoc --toc --standalone -f gfm -o ${HOME}/notes/${1}.html ${HOME}/notes/${1}.md
    else
        echo "No note specified."
    fi
}

__notes_list()
{
    local hd="$(echo ${HOME} | sed 's|\/|\\/|g')"
    if [[ "${1}" =~ ^\.\/ ]]; then
        find . -name "*.md" -type f
    else
        find ${HOME}/notes/ -name "*.md" -type f | sed "s/${hd}\/notes\///g"
    fi
}

__notes_completions()
{
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local prev="${COMP_WORDS[COMP_CWORD-1]}"
    local IFS=$'\n'
    if [[ -n "${cur}" ]]; then
        mapfile -t COMPREPLY < <(
            __notes_list "${cur}" | while IFS= read -r item; do
                if [[ "${item}" == "${cur}"* ]]; then
                    echo "${item@E}"
                fi
            done
        )
    else
        mapfile -t COMPREPLY < <(__notes_list)
    fi
}

complete -F __notes_completions note
complete -F __notes_completions vnote
complete -F __notes_completions cnote
