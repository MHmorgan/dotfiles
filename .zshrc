# vim: filetype=zsh:

################################################################################
#                                                                              #
# Nordic setup
#                                                                              #
################################################################################

fpath=(${HOME}/dogit/completion/zsh $fpath)
autoload -Uz compinit
compinit 

# Case-insensitive command line completion
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Menu when selecting multiple items
zstyle ':completion:*' menu select

setopt share_history
setopt histignorealldups

export PATH=""
export PATH=$PATH:.:/usr/bin:/bin/:/usr/X11R6/bin
source /cad/gnu/modules/modules-tcl/init/zsh
module load common_setup
module use /cad/gnu/modules/modulefiles2.0

export PRINTER="xeroxtrh1"
export SVN_EDITOR="vi"
module load gnutools/grid-engine
qsubcall(){
  qsub -N "mahi" -M "mahi@nordicsemi.no" -cwd -V -j y -o qsublog_\$JOB_ID.log -b y -S /bin/sh $*
  
}
qrsubcall(){
  qrsh -N "mahi" -now no -pty yes -cwd -V $*
}

# Python 3.8 module
module switch misctools/anaconda/3-2020.07

# Copied, and modified, content of /pro/dogit/training/dogit-support/shell/source_dogit_env_zsh
module load misctools/git/2.19.1
export PATH=/pri/$USER/dogit:$PATH
source /pro/dogit/training/dogit-support/shell/source_dogit_aliases_zsh


################################################################################
#                                                                              #
# Oh my zsh
#                                                                              #
################################################################################

# Path to your oh-my-zsh installation.
export ZSH="/pri/mahi/.oh-my-zsh"

ZSH_THEME="robbyrussell"

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
	cargo
	git
	pip
	pylint
	python
	ripgrep
	rust
	rustup
	stewie
	tmux
)

source $ZSH/oh-my-zsh.sh


################################################################################
#                                                                              #
# Personal
#                                                                              #
################################################################################

# Needed after started using PuTTY. If not 'Could not open a connection
# to your authonticantion agent' where printed when running dogit.
# eval $(ssh-agent -s)

export MAHI="/work/mahi"
export EMAIL="magnus.hirth@nordicsemi.no"

# User specific commands should have top priority
export PATH="$HOME/bin/:$PATH"

export PATH="$PATH:$HOME/.local/bin:$HOME/local/bin:$HOME/scripts:$MAHI/bin:$MAHI/scripts"
export MANPATH="$MANPATH:/work/mahi/man"

# Cssc tools
export PATH="$PATH:/cad/caduser/tools/cssc/bin"

# Cargo binaries
export PATH="$PATH:$HOME/.cargo/bin"

# Chibi scheme
export PATH="$PATH:/pri/mahi/chibi/bin"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/pri/mahi/chibi/lib"

# Awesome prompt <3
eval "$(starship init zsh)"

# Make ls colors nice in xfce terminal
eval $(dircolors -b)

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

alias q=qsubcall
alias qr=qrsubcall
alias vim='/usr/bin/vim -X'
alias ll="ls -lh"
alias l1="ls -1"
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

alias vc='eval `dogit vc zsh`'
alias rw='dogit rw -s . ; cd `pwd`'
alias tools='echo "Loading the following tools:" ; dogit tools -v ; eval `dogit tools -l`' 
alias sim='$VC_WORKSPACE/methodology/DesignKit/scripts/notools/gridsim/gridsim.py'

alias work=mahi
alias cdvc='cd $VC_WORKSPACE && pwd'
alias cdcssc='cd /cad/caduser/tools/cssc && pwd'
alias cddelivery='cd /pro/haltium4460/delivery/digital/ && pwd'


################################################################################
#                                                                              #
# Functions
#                                                                              #
################################################################################

function cdl {
	cd $1 &&
	ll
}


function cdls {
	cd $1 &&
	ls
}

function home {
	echo $HOME
	cd $HOME &&
	ll
}

function mahi {
	echo /work/mahi
	cd /work/mahi &&
	ll
}

if type selector &>/dev/null
then
	function goto {
		mypaths=(
			$HOME/{Documents,scripts,lib,projects,cosmic}
			$HOME/projects/*(/)
			/pro/*/work/mahi
			/deliverables/*/digital/ApplicationMcu
		)
		#
		# Add workspace directories only if VC_WORKSPACE is set
		#
		if [[ -n "$VC_WORKSPACE" ]]
		then
			for TMP in $(echo \
				$VC_WORKSPACE/products/*/*/hdn/ApplicationMcu/{syn,lec,vclp} \
				$VC_WORKSPACE/products/*/*/tools/cosmic/*(/) \
				$VC_WORKSPACE/products/*/*/abc \
				$VC_WORKSPACE/platforms/*/blocks/ApplicationMcu/{dft,upf})
			do
				mypaths+=(${TMP#$VC_WORKSPACE/})
			done
		fi
		local SEL=$(selector ${=mypaths})
		[[ -n "$SEL" ]] || return
		#
		# Relative paths must be processed before changing directories.
		#
		if [[ $SEL =~ "^/" ]]; then
			local DIR=$SEL/$1
		else
			local DIR=$VC_WORKSPACE/$SEL/$1
		fi
		echo $DIR
		cd $DIR
		ll
	}
fi


# Generate ls and cd for personal directories
for mydir in \
	$HOME/cosmic \
	$HOME/projects \
	$HOME/projects/louis \
	$HOME/projects/stewie \
	$HOME/projects/tammy \
	$HOME/scripts 
do
	myname=${mydir##*/}
	eval "function cd$myname {
		local DIR=$mydir/\$1
		echo \$DIR
		cd \$DIR
		ll
	}"

	eval "function ls$myname {
		local DIR=$mydir/\$1
		echo \$DIR
		ll \$DIR
	}"
done


# Generate ls and cd for project work directories
for mydir in $(echo /hizz/pro/*/work/mahi)
do
	myname=${${mydir#/hizz/pro/}%/work/mahi}
	eval "function cd$myname {
		local DIR=$mydir/\$1
		echo \$DIR
		cd \$DIR
		ll
	}"

	eval "function ls$myname {
		local DIR=$mydir/\$1
		echo \$DIR
		ll \$DIR
	}"
done


function backup {
	local src=$1

	if ! [[ -f "$src" ]]
	then
		echo "source file not found: $src"
		return 1
	fi

	cp -uvpr $src $src~
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

# Status
function dst {
	autoload -U colors && colors
	pushd $HOME &> /dev/null
	echo "$fg_bold[default]Dotfiles status$reset_color"
	dot status
	popd &> /dev/null
}

# Synchronizing
function dos {
	autoload -U colors && colors
	pushd $HOME &> /dev/null
	if [[ -n "$(dot status --short)" ]]
	then
		echo "$fg_bold[default]Committing dotfiles updates$reset_color"
		dot commit -va || return 1
	fi
	echo "$fg_bold[default]Pulling in remote updates$reset_color" &&
	dot pull &&
	echo "$fg_bold[default]Pushing our updates to remote$reset_color" &&
	dot push
	popd &> /dev/null
}

