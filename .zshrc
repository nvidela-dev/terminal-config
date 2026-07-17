# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║                                   ZSHRC                                      ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                              Core Configuration                              │
# └──────────────────────────────────────────────────────────────────────────────┘

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Locale
export LC_ALL=en_US.UTF-8

# Oh My Zsh
ZSH_THEME="agnoster"
export ZSH="$HOME/.oh-my-zsh"
plugins=(git zsh-autosuggestions)
source $ZSH/oh-my-zsh.sh

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                            Version Managers                                  │
# └──────────────────────────────────────────────────────────────────────────────┘

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# Java (Uncomment if needed)
# export JAVA_HOME=$(/usr/libexec/java_home -v 21)

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                                  Tmux                                        │
# └──────────────────────────────────────────────────────────────────────────────┘

# Auto-start tmux session
if [ -z "$TMUX" ]; then
  tmux new-session -As main
fi

alias tmk="tmux kill-server"
alias tls="tmux ls"
alias tmc="nvim ~/.conf/tmux/tmux.conf"

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                              Shell & Editor                                  │
# └──────────────────────────────────────────────────────────────────────────────┘

# Zsh
alias zrl="omz reload"
alias zrc="nvim ~/.zshrc"

# Neovim
alias nv="nvim ."
alias nvrc="nvim ~/.config/nvim"

# Markdown Reader
alias md="glow -p"

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                                   Git                                        │
# └──────────────────────────────────────────────────────────────────────────────┘

alias lzy="lazygit"
alias c="git commit -m"

# Branching
alias b="git checkout"
alias bb="git checkout -"
alias bdev="git checkout develop"

# Rebasing
alias rbc="git rebase --continue"
alias sq="git rebase -i --root"
alias sd="git fetch origin develop:develop && git rebase -i develop"
alias sm="git fetch origin main:main && git rebase -i main && git status"
alias devrb="git fetch origin develop:develop && git rebase develop && git status"
alias mainrb="git fetch origin main:main && git rebase main && git status"

# Push
alias obi="git push --force"

# GitHub Search
ORG="xxx"
ghf() {
  local baseUrl="https://github.com/search?q=org%3A$ORG+"
  local query="$1"
  local encoded_query=$(echo "$query" | jq -sRr @uri)
  local url="${baseUrl}${encoded_query}&type=code"
  open -a "Google Chrome" "$url"
}

# Open current repo in GitHub
repo() {
  local url
  url=$(git remote get-url origin 2>/dev/null)
  if [[ -z "$url" ]]; then
    echo "Not a git repository or no origin remote"
    return 1
  fi
  url=${url#git@github.com:}
  url=${url%.git}
  open "https://github.com/$url"
}

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                          Jira Ticket Lookup                                  │
# └──────────────────────────────────────────────────────────────────────────────┘

t_num() {
  branch_name=$(git branch --show-current)
  prefix_removed="${branch_name#*/}"
  prefix="${prefix_removed%%-*}"
  number=$(echo "$prefix_removed" | grep -oE '[0-9]+')
  ticket_number="${prefix}-${number// /}"
  echo "$ticket_number"
}

jira() {
  n=$(t_num)
  echo "Jumping to Ticket: ${n}"
  jira_url="https://xxx.atlassian.net/browse/${n}"
  open -a "Google Chrome" "$jira_url"
}

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                               Navigation                                     │
# └──────────────────────────────────────────────────────────────────────────────┘

alias ls="ls -1 --color"
alias :qa!="exit"

# Directories
alias sysconf="cd ~/.config"
alias h="cd ~/Hangar"
alias s="cd ~/Stash"
alias sb="cd ~/Sandbox"
alias dl="cd ~/Downloads"
alias wavd="cd ~/Music/Wav\ Dump"

# Quick Access
alias note="nvim ~/Docs/Notes/Current.md"
alias notesav="mv ~/Docs/Notes/Current.md ~/Docs/Notes/Historical/$(date +%m-%d-%Y).md"
alias notes="open ~/Docs/Notes/"
alias notesh="open ~/Docs/Notes/Historical/"
alias notesd="open ~/Docs/Notes/Docs/"
alias notesd="open ~/Docs/Notes/Plans/"

notedoc() {
    read "filename?Document name: "

    # Add .md if user didn't include it
    [[ "$filename" != *.md ]] && filename="${filename}.md"

    mkdir -p ~/Docs/Notes/Docs

    mv ~/Docs/Notes/Current.md ~/Docs/Notes/Docs/"$filename"

    # Create a fresh Current.md
    touch ~/Docs/Notes/Current.md

    echo "Saved as ~/Docs/Notes/Docs/$filename"
}

noteplan() {
    read "filename?Plan name: "

    [[ "$filename" != *.md ]] && filename="${filename}.md"

    mkdir -p ~/Docs/Notes/Plans

    mv ~/Docs/Notes/Current.md ~/Docs/Notes/Plans/"$filename"
    touch ~/Docs/Notes/Current.md

    nvim ~/Docs/Notes/Current.md
}

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                                 Docker                                       │
# └──────────────────────────────────────────────────────────────────────────────┘

alias dkd="docker-compose down"
alias dku="docker-compose up"
alias dkps="docker ps"
alias dklogs="docker logs"

# Container Execution
CONTAINER="ContainerName"
alias awxa="docker exec $CONTAINER awslocal"
alias awxs="docker exec $CONTAINER awslocal"
alias dxa="docker exec $CONTAINER"
alias dxs="docker exec $CONTAINER"

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                             Brew Services                                    │
# └──────────────────────────────────────────────────────────────────────────────┘

alias brewls="brew services list"

# MongoDB
alias mongostart="brew services start mongodb-community@6.0"
alias mongostop="brew services stop mongodb-community@6.0"

# PostgreSQL
alias pgstart="brew services start postgresql"
alias pgstop="brew services stop postgresql"

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                               JavaScript                                     │
# └──────────────────────────────────────────────────────────────────────────────┘

alias mdb="npx json-server db.json"
alias jcc="npx jest --coverage"
alias rsb="npm run storybook"
alias rdev="npm run dev"
alias nfw="npm run format:write"

# Debug Pipe Configuration
export DEBUG_PIPE="/tmp/node-debug-pipe"
alias loginit='rm -f $DEBUG_PIPE && mkfifo $DEBUG_PIPE && echo "Pipe created at $DEBUG_PIPE"'
alias logwatch='echo "Waiting for logs..." && tail -f $DEBUG_PIPE'
alias logkill='rm -f $DEBUG_PIPE && echo "Pipe removed"'

npmlog() {
    npm run "$@" 2> $DEBUG_PIPE
}


# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                                  Java                                        │
# └──────────────────────────────────────────────────────────────────────────────┘

jtest() {
  mvn test
  open ./target/index.html
}

jrun() {
  echo "Building the project..."
  mvn clean install
  if [ $? -ne 0 ]; then
    echo "Build failed. Exiting."
    return 1
  fi
  echo "Running the project..."
  mvn spring-boot:run
}

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                                 Python                                       │
# └──────────────────────────────────────────────────────────────────────────────┘

alias pyenv="source ~/myenv/.venv/bin/activate"
alias p3="python3"

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                                Scrapers                                      │
# └──────────────────────────────────────────────────────────────────────────────┘

alias scraper="cd ~/Hangar/supermarket-scraper && set -a && source .env && set +a && make run"
alias scraper-front="cd ~/Hangar/supermarket-scraper-front && npm run dev"

# Created by `pipx` on 2026-01-13 14:01:10
export PATH="$PATH:/Users/nvidela/.local/bin"
alias lain="open \"https://archive.org/details/serial-experiments-lain-english/BluRay+(MKV+-+Highest+Quality)/Serial+Experiments+Lain+-+S01E02.mkv\""

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │                                Utilities                                     │
# └──────────────────────────────────────────────────────────────────────────────┘

# List .asd files alongside their source files
lasd() {
  local files=(*.asd(N))
  if [[ ${#files[@]} -eq 0 ]]; then
    echo "No .asd files found."
    return 0
  fi
  for asd in "${files[@]}"; do
    local base="${asd%.asd}"
    printf "%-40s | %s\n" "$base" "$asd"
  done
}

# Remove all .asd files from current directory
xasdx() {
  local files=(*.asd(N))
  if [[ ${#files[@]} -eq 0 ]]; then
    echo "No .asd files found in current directory."
    return 0
  fi
  echo "Found ${#files[@]} .asd file(s):"
  printf '  %s\n' "${files[@]}"
  echo ""
  read -q "confirm?Remove these files? [y/N] "
  echo ""
  if [[ "$confirm" == "y" ]]; then
    rm -f "${files[@]}"
    echo "Removed ${#files[@]} .asd file(s)."
  else
    echo "Aborted."
  fi
}

# Kill all node processes
alias nodenuke='pkill -9 node'

# Start the Lock-In TUI from anywhere
lockin() {
  (cd /Users/nvidela/Hangar/lock-in && go run ./cmd/lock-in "$@")
}

# Start the Usual Suspects TUI from anywhere
usualsuspects() {
  (cd /Users/nvidela/Hangar/usual-suspects && go run ./cmd/usual-suspects "$@")
}

# Start the Dev Stats TUI from anywhere
devstats() {
  (cd /Users/nvidela/Hangar/dev-stats && go run ./cmd/dev-stats "$@")
}

# Open Claude Code in the ClaudeLearnNest folder and auto-run /teach
learnnest() {
  (cd /Users/nvidela/Docs/Study/ClaudeLearnNest && claude "/teach")
}
