
function info { echo "[*] $*" }
function warn { echo "[!] $*" }
function err  { echo "[!!] $*" }
function bail { err $*; exit 1 }

setopt EXTENDED_GLOB


function input {
    (( $# == 2 )) || bail "'input' called with $# arguments (expects 2)"
    unset cmn_val
	vared -cp "$1" cmn_val
    export $2="$cmn_val"
}


function confirm {
    (( $# == 1 )) || bail "'confirm' called with $# arguments (expected 1)"
    unset cmn_val
    vared -cp "$1 (Y/n) " cmn_val
    [[ -z "$cmn_val" || "$cmn_val" =~ '^\s*[Yy](es?)?\s*$' ]]
}


function header {
	local border=$(repeat $(echo -n $* | wc -m) echo -n "=")
    echo "\n$*\n$border\n"
}

cd

################################################################################
#                                                                              #
# Homebrew setup
#                                                                              #
################################################################################

header "Homebrew install"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

info "Add my homebrew tap"
brew tap https://github.com/MHmorgan/homebrew-tap.git

header "GitHub CLI install"
brew install gh || bail "installation failed ✗"

info "Login to GitHub…"
gh auth login || bail "login failed ✗"


################################################################################
#                                                                              #
# Dotfiles setup
#                                                                              #
################################################################################

header "Dotfiles setup"

info "Cloning dotfile bare repo"
git clone --bare $URL .dotfiles || bail "Cloning failed ✗"

alias dot='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'

# Backup any dotfiles which already exists
info "Creating backup of existing dotfiles"
for FILE in $(dot ls-tree --name-only -r master)
do
	if [[ -f "$FILE" ]]; then
		echo $FILE
		mv $FILE $FILE~
	fi
done

# Checkout the repo
info "Checking out dotfiles"
dot checkout
dot config advice.addIgnoredFile false
dot config branch.master.remote origin
dot config branch.master.merge refs/heads/master


################################################################################
#                                                                              #
# Applications
#                                                                              #
################################################################################

APPS=(
	'python@3.10'
	'rust'
	'starship'
	'neovim'
	'thefuck'
	'fortune'
	'neofetch'
	'cowsay'
	'tmux'
	'lazygit'
	'pandoc'
	'gcc'
	'zsh-autosuggestions'
	'mhmorgan/commode'
	'mhmorgan/selector'
)

for APP in $APPS
do
	header "Installing $APP"
	brew install $APP
done


echo "\nNext steps:
	1. Add '<user> ALL=(ALL) NOPASSWD:ALL' to /etc/sudoers"

