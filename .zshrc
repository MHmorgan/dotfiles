# vim: filetype=zsh:

export PATH=".:$HOME/bin/:$HOME/.local/bin:$HOME/local/bin:$HOME/scripts:/usr/bin:/bin/:/usr/X11R6/bin"

################################################################################
#                                                                              #
# Nordic setup
#                                                                              #
################################################################################

# If starting a shell on a vnc server, just hijack the session
# and ssh into a cad server instead.
if [[ "$(hostname)" =~ "vncsrv[0-9]+.nordicsemi.no" ]]
then
    vared -cp "SSH into a cad server? (Y/n) " INP
    if [[ -z "$INP" || "$INP" =~ '^\s*[Yy](es?)?\s*$' ]]
	then
		MYCADSRV=cad10.nordicsemi.no
		echo "It looks like you are on a vnc server ($(hostname))"
		echo "Moving to a cad server instead ($MYCADSRV)"
		ssh -Y $USER@$MYCADSRV
	fi
fi

fpath=(${HOME}/dogit/completion/zsh $fpath)
autoload -Uz compinit
compinit 

# Case-insensitive command line completion
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Menu when selecting multiple items
zstyle ':completion:*' menu select

setopt share_history
setopt histignorealldups

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
export PATH="$PATH:/pri/$USER/dogit"
source /pro/dogit/training/dogit-support/shell/source_dogit_aliases_zsh


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
	chucknorris
	git
	lol
	pip
	pylint
	python
	ripgrep
	rust
	stewie
	thefuck
	tmux
	zsh-autosuggestions
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

alias vc='eval `dogit vc zsh`'
alias rw='dogit rw -s . ; cd `pwd`'
alias tools='echo "Loading the following tools:" ; dogit tools -v ; eval `dogit tools -l`' 
alias sim='$VC_WORKSPACE/methodology/DesignKit/scripts/notools/gridsim/gridsim.py'

alias work=mahi
alias cdvc='cd $VC_WORKSPACE && pwd'
alias cdcssc='cd /cad/caduser/tools/cssc && pwd'
alias cddelivery='cd /pro/haltium4460/delivery/digital/ && pwd'

alias lolaliases='$EDITOR $HOME/.oh-my-zsh/plugins/lol/README.md'


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
			/datastore01/jenkins01/node-simsrv*/workspace/Lilium/AppMcu_SYN/lastSuccessfulBuild*
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
		local SEL=$(selector ${=mypaths} -af "$*")
		[[ -n "$SEL" ]] || return
		#
		# Relative paths must be processed before changing directories.
		#
		if [[ $SEL =~ "^/" ]]; then
			local DIR=$SEL
		else
			local DIR=$VC_WORKSPACE/$SEL
		fi
		echo $DIR
		# -P use the physical directory structure instead of following symbolic links
		cd -P $DIR
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

function gitaliases {
	local file=$HOME/.oh-my-zsh/plugins/git/README.md
	local command='
		$2 ~ /^\s*g/ {
			gsub(/^\s*/, "", $2)
			gsub(/^\s*/, "", $3)
			gsub(/\s*$/, "", $2)
			gsub(/\s*$/, "", $3)
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

