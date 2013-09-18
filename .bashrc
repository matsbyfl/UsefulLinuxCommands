# #### Runars .bashrc - MACenabled#####
#

########################
# Bash history tweaks
########################

# Set larger history
HISTSIZE=9000
HISTFILESIZE=$HISTSIZE

# Ignore duplicates and commands with leading spaces
HISTCONTROL=ignorespace:ignoredups

# Appended to the histfile instead of overwriting on exit
shopt -s histappend

#history() {
#  _bash_history_sync
#  builtin history "$@"
#}

_bash_history_sync() {
  # Append this session to history
  builtin history -a
  HISTFILESIZE=$HISTSIZE     
}

export PROMPT_COMMAND="_bash_history_sync; $PROMPT_COMMAND"

up() {
	LIMIT=$1

	if [ -z "$LIMIT" ]; then
		LIMIT=1
	fi

	SEARCHPATH=$PWD
	
	# If argument is not numeric, try match path
	if ! [[ "$LIMIT" =~ ^[0-9]+$ ]] ; then
	 	if ! [[ "$SEARCHPATH" =~ ^.*$LIMIT.*$ ]] ; then
			echo "expression not found"
		else
			while [ true ]; do 
				SEARCHPATH=$SEARCHPATH/..
				cd $SEARCHPATH
				if [[ ${PWD##*/} =~ ^.*$LIMIT.*$ ]]; then
					break;
				elif [[ -z ${PWD##*/} ]]; then
					break;
				fi 
			done
		fi
	else 
		# go n directories up
		for ((i=1; i <= LIMIT; i++))
			do
				SEARCHPATH=$SEARCHPATH/..
			done
		cd $SEARCHPATH
	fi
}

#  colors
export CLICOLOR=true
export LSCOLORS=${LSCOLORS:-ExFxCxDxBxegedabagacad}

# Prompt
        RED="\[\033[0;31m\]"
     YELLOW="\[\033[0;33m\]"
      GREEN="\[\033[0;32m\]"
       BLUE="\[\033[0;34m\]"
  LIGHT_RED="\[\033[1;31m\]"
LIGHT_GREEN="\[\033[1;32m\]"
      WHITE="\[\033[1;37m\]"
 LIGHT_GRAY="\[\033[0;37m\]"
 COLOR_NONE="\[\e[0m\]"

# Override cd to check for localevn. 
# Is exists, source it => Use this to create separate env for different dirs, e.g CVS_ROOT, JAVA_HOME etc
cd() {
  builtin cd "$@"
  [ -f localenv ] && colorString setting localenv.. && source localenv
}

# Function to quick cd to git repositories, uses _set_gitrepository-TC
cg() {
	builtin cd $GIT_REPO/$1
}

# Function to checkout branches, uses _set_listbranches-TC
branch() {
    git checkout $1
}

# Get branches and remove * to not fuck up TabCompletion
getBranches() {
	BRANCHES=$(git branch | sed 's/*//')
	echo $BRANCHES
}

# tunneling

#alias tunnel_prod_db="ssh -L 54321:icarus:5432 rmy@beast.enonic.net"
#alias tunnel_prod_ldap="ssh -L 3891:ldap:389 rmy@beast.enonic.net"

# System test stuff

#alias tail_packages_log="acoc ssh root@versiontest tail -100f /home/cms-commando-unstable-packages/enonic-cms/logs/catalina.out"

#myfunction() {
    #do things with parameters like $1 such as
#    mv $1 $1.bak
#    cp $2 $1
#}
#alias myname=myfunction


# Custom tab completion
########################

# Activate
shopt -s progcomp

#Functions

 _set_gitrepository-TC() {
 	local cur
 	cur=${COMP_WORDS[COMP_CWORD]}
 	COMPREPLY=( $( compgen -W '$( ls $GIT_REPO)' $cur ))
 }

 _set_listbranches-TC() {
 	local cur
 	cur=${COMP_WORDS[COMP_CWORD]}
 	COMPREPLY=( $( compgen -W '$( getBranches)' $cur ))
 }

# Bind custom tab-completions
complete -F _set_gitrepository-TC cg
complete -F _set_listbranches-TC branch

# PROMPT STUFF
########################

## Enables executing .dirrc file if present in directory
function _execute_dirrc() {
	if [ "${PREV}" != "$(pwd -P)" ]; then
	    if [ -r .dirrc ]; then
	        . ./.dirrc
	    fi
	    PREV=$(pwd -P)
	fi
}

# GIT Aware prompt
########################

# Detect whether the current directory is a git repository.
function is_git_repository {
  git branch > /dev/null 2>&1
}

function set_git_branch {
  # Capture the output of the "git status" command.
  git_status="$(git status 2> /dev/null)"

  # Set color based on clean/staged/dirty.
  if [[ ${git_status} =~ "working directory clean" ]]; then
	state="${BLUE}"
  elif [[ ${git_status} =~ "Changes to be committed" ]]; then
	state="${RED}"
	elif [[ ${git_status} =~ "no changes added to commit" ]]; then
	state="${YELLOW}"	
  else
	state="${RED}"
  fi
  
  # Set arrow icon based on status against remote.
  remote_pattern="# Your branch is (.*) of"
  if [[ ${git_status} =~ ${remote_pattern} ]]; then
if [[ ${BASH_REMATCH[1]} == "ahead" ]]; then
remote="↑"
    else
remote="↓"
    fi
else
remote=""
  fi
diverge_pattern="# Your branch and (.*) have diverged"
  if [[ ${git_status} =~ ${diverge_pattern} ]]; then
remote="↕"
  fi
  
  # Get the name of the branch.
  branch_pattern="^# On branch ([^${IFS}]*)"
  if [[ ${git_status} =~ ${branch_pattern} ]]; then
branch=${BASH_REMATCH[1]}
  fi

  # Set the final branch string.
  BRANCH="${state}[${branch}]${remote}${COLOR_NONE} "
}

function set_git_enabled_prompt () {

  # Set the BRANCH variable.
  if is_git_repository ; then
	set_git_branch
  else
	BRANCH=' '
  fi
  
  # Set the bash prompt variable.
  PS1="\[\e[$((32-${?}))m\]\w\[\e[0m\]${BRANCH}\$ "
}

# Bind prompt-commands
export PROMPT_COMMAND="set_git_enabled_prompt; $PROMPT_COMMAND"
#export PROMPT_COMMAND="_execute_dirrc; $PROMPT_COMMAND"

SCALA_HOME=/usr/local/share/scala
PATH=$PATH:$HOME/.rvm/bin:$SCALA_HOME/bin # Add RVM to PATH for scripting

# Prompt
#PS1="${GREY}[\$(+%H:%M:%S)]${WHITE}\u@\h:${BLUE}\w${GREY}\>${DEFAULT} "

#export $PS1
