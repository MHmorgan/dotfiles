# vim: filetype=zsh:

################################################################################
#                                                                              #
# Oh my zsh
#                                                                              #
################################################################################

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
	brew
	chucknorris
	git
	lol
	pip
	pylint
	python
	ripgrep
	rust
	thefuck
	tmux
	vscode
	zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

export EDITOR='vim'


################################################################################
#                                                                              #
# Personal
#                                                                              #
################################################################################

export PATH="$PATH:$HOME/.cargo/bin:$HOME/.local/bin:$HOME/bin:/usr/lib/dart/bin:$HOME/flutter/bin:$HOME/scripts"

#
# Cargo bin
#
export PATH="$PATH:$HOME/.cargo/bin"

#
# Nim bin
#
export PATH="$PATH:$HOME/.nimble/bin"

#
# Dart & flutter bin
#
export PATH="$PATH:/usr/lib/dart/bin:$HOME/flutter/bin:$HOME/.pub-cache/bin"

#
# Go bin & GOPATH
#
export GOROOT="/usr/local/go"
export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"
export PATH="$PATH:$GOROOT/bin:$GOBIN"

function goinstall() {
	test -n "$GOROOT" || { echo "Missing GOROOT" ; return 1 }
	test -n "$1" || { echo "Missing go tar file." ; return 1 }
	local SRC=$1
	sudo rm -rf $GOROOT
	sudo tar -C ${GOROOT/\/go/} -xzf $SRC
}

#
# PostgreSQL bin
#
export PATH="$PATH:/usr/lib/postgresql/13/bin"

#
# Homebrew setup - differs between MacOS and Linux
#
if [[ ! "$OSTYPE" =~ darwin ]]; then
	eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
	
	PYTHON_VERSION='3.10'
	export PATH="/home/linuxbrew/.linuxbrew/opt/python@${PYTHON_VERSION}/bin:$PATH"
	export LDFLAGS="-L/home/linuxbrew/.linuxbrew/opt/python@${PYTHON_VERSION}/lib"
	export CPPFLAGS="-I/home/linuxbrew/.linuxbrew/opt/python@${PYTHON_VERSION}/include"
	export PKG_CONFIG_PATH="/home/linuxbrew/.linuxbrew/opt/python@${PYTHON_VERSION}/lib/pkgconfig"
else
	export PATH="/usr/local/opt/python@3.10/bin:$PATH"
	export LDFLAGS="-L/usr/local/opt/python@3.10/lib"
	export PKG_CONFIG_PATH="/usr/local/opt/python@3.10/lib/pkgconfig"
fi


eval "$(starship init zsh)"
# export SPACESHIP_PROMPT_ADD_NEWLINE=false
# export SPACESHIP_PROMPT_SEPARATE_LINE=false


# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/m/google-cloud-sdk/path.zsh.inc' ]; then . '/home/m/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/m/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/m/google-cloud-sdk/completion.zsh.inc'; fi


if type nvim &>/dev/null
then 
	export EDITOR='nvim'
elif type vim &>/dev/null
then
	export EDITOR='vim'
else
	export EDITOR='vi'
fi

eval $(thefuck --alias)


################################################################################
#                                                                              #
# Aliases
#                                                                              #
################################################################################

alias ll="ls -l"
alias l1="ls -1"
alias lsd="ls -d *(/)"
alias lld="ls -lhd *(/)"
alias less="less -r"

if type nvim &>/dev/null
then
	alias n="nvim"
fi

alias lg='lazygit'

alias co='commode'
alias cod='commode download'
alias cou='commode upload'
alias cols='commode ls'
alias cobs='commode boilerplates'
alias cob='commode boilerplate'
alias cobd='commode boilerplate download'
alias cobi='commode boilerplate install'
alias cobu='commode boilerplate upload'

alias lolaliases='$EDITOR $HOME/.oh-my-zsh/plugins/lol/README.md'

alias pyvenv='python3 -m venv --upgrade-deps venv'
alias ipython='ipython3 --autocall=1 --pprint'


################################################################################
#                                                                              #
# Functions
#                                                                              #
################################################################################

function cdl {
	cd $1
	ll
}


function cdls {
	cd $1
	ls
}

function home {
	echo $HOME
	cd $HOME
	ll
}

# Generate ls and cd functions for all the project directories.
if [[ -d $HOME/projects ]]
then
	for mydir in $(ls $HOME/projects)
	do
		eval "function cd$mydir () {
			local DIR=$HOME/projects/$mydir/\$1
			echo \$DIR
			cd \$DIR
			ll
		}"

		eval "function ls$mydir () {
			local DIR=$HOME/projects/$mydir/\$1
			echo \$DIR
			ll \$DIR
		}"
	done
fi

if type selector &>/dev/null
then
	function goto {
		mypaths=(
			$HOME/{Documents,Downloads,projects,scripts,lib}
			$HOME/Documents/*(/)
			$HOME/projects/*(/)
			$HOME/projects/*/*(/)
			/home/linuxbrew/.linuxbrew/Homebrew/Library/Taps/mhmorgan/homebrew-tap
		)
		local SEL=$(selector ${=mypaths} -af "$*")
		[[ -n "$SEL" ]] || return
		local DIR=$SEL
		echo $DIR
		# -P use the physical directory structure instead of following symbolic links
		cd -P $DIR
		ll
	}
fi

function backup {
	local src=$1

	if ! [[ -f "$src" ]]
	then
		echo "source file not found: $src"
		return 1
	fi

	cp -uvpr $src $src~
}

function gitaliases {
	local file=$HOME/.oh-my-zsh/plugins/git/README.md
	local command='
		$2 ~ /^ *g/ {
			gsub(/(^ *| *$)/, "", $2)
			gsub(/(^ *| *$)/, "", $3)
			print $2 "\t" $3
		}
	'
	# Look through all aliases or grep for a some specific aliases
	if (( $# < 1 ))
	then
		awk -F '|' $command $file | less
	else
		awk -F '|' $command $file | grep $@
	fi
}


################################################################################
#                                                                              #
# Dotfiles
#                                                                              #
################################################################################

# Git base command
alias dot='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'

# Add
alias doa='git --git-dir=$HOME/.dotfiles --work-tree=$HOME add --force'

# Lazygit
alias dlg='lazygit --git-dir=$HOME/.dotfiles --work-tree=$HOME'

# Checkout
alias dco='git --git-dir=$HOME/.dotfiles --work-tree=$HOME checkout'

# Status
function dst {
	autoload -U colors && colors
	[[ $PWD == $HOME ]] || echo "$fg_no_bold[yellow]This command should be run from your home folder$reset_color"

	echo "$fg_bold[default]Dotfiles status$reset_color"
	dot status
}

# Synchronizing
function dos {
	autoload -U colors && colors
	[[ $PWD == $HOME ]] || echo "$fg_no_bold[yellow]This command should be run from your home folder$reset_color"

	if [[ -n "$(dot status --short)" ]]
	then
		echo "$fg_bold[default]Committing dotfiles updates$reset_color"
		dot commit -va || return 1
	fi

	echo "$fg_bold[default]Pulling in remote updates$reset_color" &&
	dot pull &&
	echo "$fg_bold[default]Pushing our updates to remote$reset_color" &&
	dot push
}

# Files
function dls {
	autoload -U colors && colors
	[[ $PWD == $HOME ]] || echo "$fg_no_bold[yellow]This command should be run from your home folder$reset_color"

	echo "$fg_bold[default]Tracked dotfiles$reset_color"
	local branch=$(dot branch | grep '^\*' | tr -d '*[:space:]')
	dot ls-tree -r --name-only $branch
}


################################################################################
#                                                                              #
# Fun stuff
#                                                                              #
################################################################################

neofetch
fortune | cowsay -n

