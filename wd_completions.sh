#!/bin/bash
__wd_searcher=""

if [[ -e $(which ag 2>/dev/null) ]]; then
    __wd_searcher=ag
elif [[ -e $(which ack 2>/dev/null) ]]; then
    __wd_searcher=ack
else
    echo "WorkingDirectory (wd) depends on ag or ack to run."
    return 1
fi

wd()
{
    local cmd="${1}"
    case "${cmd}" in
        "")
            cd
            ;;
        add)
            # Remove an existing entry (assuming it exists), and move all the
            # remaining entries to a temporary file. Then add the new entry to
            # the end of the file, and finally overwrite the current file with
            # the new one.
            ${__wd_searcher} --nonumbers -v "^${2}\t" ~/.wdcache > ~/.wdcache.new
            echo -e "${2}\t$(pwd)" >> ~/.wdcache.new
            mv ~/.wdcache.new ~/.wdcache
            ;;
        rem|remove)
            # Move all entries, except the one to be removed, to a temporary
            # file. Then move the temporary file over the current one.
            ${__wd_searcher} --nonumbers -v "^${2}\t" ~/.wdcache > ~/.wdcache.new
            mv ~/.wdcache.new ~/.wdcache
            ;;
        list)
            # List every entry in the file... the _really_ easy way.
            cat ~/.wdcache
            ;;
        *)
            # For any other command given, attempt to find an entry with the
            # requested name (the command) and if it exists cd to the
            # associated directory. If it doesn't exist, print an error.
            local d="$(${__wd_searcher} --nonumbers "^${cmd}\t" ~/.wdcache | cut -f2 2>/dev/null)"
            if [[ -n "${d}" ]]; then
                cd "${d}"
            else
                echo "Unknown working directory '${cmd}'"
            fi
            ;;
    esac
}

__wd_dir_list()
{
    # Get all the names of the cached directories.
    echo $(awk '{print $1}' ~/.wdcache | tr '\n' ' ' | sed 's/\s*$//')
}

__wd_completions()
{
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local prev="${COMP_WORDS[COMP_CWORD-1]}"
    local commands="add list rem remove"

    # If we have started a command, it is time to narrow down the
    # tab-completion results that can be returned. To do this, we take a look
    # at all the directories and commands we know about, and filter based on
    # using them as a regular expression. Anything that doesn't start with the
    # provided command is removed from the possible completions list.
    if [[ -n ${cur} ]]; then
        local possible="${commands} $(__wd_dir_list)"
        local likely=""
        for item in ${possible}; do
            if [[ ${item} =~ ^${cur} ]]; then
                likely="${likely} ${item}"
            fi
        done
        COMPREPLY=( $(compgen -W "${likely}") )
        return 0
    fi

    # If we aren't in the processes of tab-completing a command, then it is
    # time to look for other context to provide completions on. 
    case "${prev}" in
        # If we are adding or listing the wd cache, then there is nothing we
        # can complete at this point. So return.
        "add" | "list")
            return 0
            ;;
        # If we are attempting to remove a wd from the cache, we can provide a
        # list of all the named directories we know about.
        "rem" | "remove")
            COMPREPLY=( $(compgen -W "$(__wd_dir_list)") )
            return 0
            ;;
        # And finally, if we don't have anything at this point (just starting
        # out the command) then tab completion can contain all sub-commands and
        #named directories we know about.
        "wd")
            COMPREPLY=( $(compgen -W "${commands} $(__wd_dir_list)") )
            return 0
            ;;
    esac
}

complete -F __wd_completions wd
