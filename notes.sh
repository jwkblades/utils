#!/bin/bash
note()
{
    local notebook="${1//:/\/}"
    local filename="$(basename "${notebook}")"
    local path="$(dirname "${notebook}${filename}")"
    if [[ ${notebook} =~ \/$ || -z "${notebook}" ]]; then
        filename="$(date +"%Y%m%d-%H%M%S")"
        path="$(dirname "${notebook}${filename}")"
    fi

    if [[ "${1}" =~ ^\.\/.*?\.md$ ]]; then
        ${EDITOR} "${1}"
    else
        mkdir -p ${HOME}/notes/${path}
        ${EDITOR} ${HOME}/notes/${path}/${filename}.md
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
    find ${HOME}/notes/ -name "*.md" -a -type f | tr '\n' ' ' | sed 's/\s*$//' | sed 's/\.md\(\s*\)/\1/g' | sed "s/${hd}\/notes\///g"
    find . -name "*.md" -a -type f | tr '\n' ' ' | sed 's/\s*$//'
}

__notes_completions()
{
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local prev="${COMP_WORDS[COMP_CWORD-1]}"
    if [[ -n ${cur} ]]; then
        local possible="$(__notes_list)"
        local likely=""
        for item in ${possible}; do
            if [[ ${item} =~ ^${cur} ]]; then
                likely="${likely} ${item}"
            fi
        done
        COMPREPLY=( $(compgen -W "${likely}") )
        return 0
    fi
    COMPREPLY=( $(compgen -W "$(__notes_list)") )
}

complete -F __notes_completions note
complete -F __notes_completions vnote
complete -F __notes_completions cnote
