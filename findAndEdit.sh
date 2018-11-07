#!/bin/bash

export FAE_EDIT="${EDITOR} -p"

fal()
{
	local pattern=""
	for part in "${@}"; do
		if [[ -n "${pattern}" ]]; then
			pattern+="|"
		fi
		pattern+="${part}"
	done
	local files="$(ag -g ${pattern} 2>/dev/null)"
    echo "${files}"
}
fae()
{
    local files="$(fal ${@} | tr '\n' ' ')"
	${FAE_EDIT} ${files}
}
