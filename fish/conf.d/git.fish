# Git aliases and abbreviations for Fish

# Basic Git abbreviations (expand as you type)
abbr --add gs git status
abbr --add ga git add
abbr --add gaa git add --all
abbr --add gc git commit
abbr --add gcm git commit -m
abbr --add gca git commit --amend
abbr --add gco git checkout
abbr --add gcb git checkout -b
abbr --add gb git branch
abbr --add gbd git branch -d
abbr --add gbD git branch -D
abbr --add gp git push
abbr --add gpl git pull
abbr --add gf git fetch
abbr --add gm git merge
abbr --add gr git rebase
abbr --add gl git log --oneline
abbr --add gd git diff
abbr --add gdc git diff --cached
abbr --add gsh git stash
abbr --add gshp git stash pop

# Advanced Git abbreviations
abbr --add glog git log --oneline --graph --decorate --all
abbr --add glg git log --color --graph --pretty=format:'%Cred%h%Creset -%C\(yellow\)%d%Creset %s %Cgreen\(%cr\) %C\(bold blue\)<%an>%Creset' --abbrev-commit
abbr --add gundo git reset --soft HEAD~1
abbr --add gclean git clean -fd
abbr --add gwip git add . && git commit -m "WIP"
abbr --add gunwip git reset HEAD~1

# Git status with short format
abbr --add gss git status -s

# Quick commit all changes
abbr --add gcam git commit -am

# Push current branch
abbr --add gpush git push origin (git branch --show-current 2>/dev/null || echo main)

# Pull current branch  
abbr --add gpull git pull origin (git branch --show-current 2>/dev/null || echo main)

# Show current branch
abbr --add gcurrent git branch --show-current

# Git log with stats
abbr --add gstat git log --stat

# Unstage files
abbr --add gunstage git reset HEAD

# Discard changes
abbr --add gdiscard git checkout --

# Show remote URLs
abbr --add gremote git remote -v

