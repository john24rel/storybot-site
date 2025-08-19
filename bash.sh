eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH="/usr/local/bin:$PATH"
alias kg="kubectl get"
alias ke="kubectl edit"
alias kc="kubectl create"
alias ka="kubectl apply --force -f"
alias kd="kubectl describe"
alias k="kubectl"
alias kr="kubectl run"
parse_git_branch() {
    local ref sync_status dirty="" stash_count

    ref=$(git symbolic-ref --short HEAD 2>/dev/null || git describe --tags --exact-match 2>/dev/null || echo "(detached)")

    if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        # Check if repo is dirty (unstaged or staged changes)
        if ! git diff --quiet --ignore-submodules HEAD 2>/dev/null || ! git diff --cached --quiet --ignore-submodules HEAD 2>/dev/null; then
            dirty+=" 📝dirty"
        fi

        # Show stash count if any
        stash_count=$(git stash list 2>/dev/null | wc -l | tr -d ' ')
        if [[ "$stash_count" -gt 0 ]]; then
            dirty+=" 📦$stash_count"
        fi

        # Show rebase/merge/cherry-pick state
        if [ -d .git/rebase-merge ] || [ -d .git/rebase-apply ]; then
            sync_status="%F{magenta}🔄 REBASE%f"
        elif [ -f .git/MERGE_HEAD ]; then
            sync_status="%F{magenta}🔀 MERGING%f"
        elif [ -f .git/CHERRY_PICK_HEAD ]; then
            sync_status="%F{magenta}🍒 PICKING%f"
        elif git rev-parse --abbrev-ref --symbolic-full-name @{u} > /dev/null 2>&1; then
            local ahead behind
            read ahead behind < <(git rev-list --left-right --count HEAD...@{u} 2>/dev/null)
            if [[ "$ahead" -eq 0 && "$behind" -eq 0 ]]; then
                sync_status="%F{green}✔ updated%f"
            elif [[ "$behind" -gt 0 ]]; then
                sync_status="%F{yellow}⬇ update%f"
            elif [[ "$ahead" -gt 0 ]]; then
                sync_status="%F{cyan}⬆ ahead%f"
            fi
        else
            sync_status="%F{red}⚠ no remote%f"
        fi

        echo "$ref [$sync_status$dirty]"
    else
        echo ""
    fi
}

COLOR_DEF='%f'
COLOR_USR='%F{777}'
COLOR_DIR='%F{190}'
COLOR_GIT='%F{34}'
NEWLINE=$'\n'    
PROMPT='${COLOR_USR}%n@%M ${COLOR_DIR}%~ ${COLOR_GIT}$(parse_git_branch)${COLOR_DEF}${NEWLINE}%% '
