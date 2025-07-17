# ~/.bashrc: executed by bash(1) for non-login shells.

# Note: PS1 and umask are already set in /etc/profile. You should not
# need this unless you want different defaults for root.
# PS1='${debian_chroot:+($debian_chroot)}\h:\w\$ '
# umask 022

# You may uncomment the following lines if you want `ls' to be colorized:
export LS_OPTIONS='--color=auto'
# eval "`dircolors`"
alias ls='ls $LS_OPTIONS --time-style="+%F %H:%M:%S"'
alias ll='ls $LS_OPTIONS --time-style="+%F %H:%M:%S" -l'
alias l='ls $LS_OPTIONS --time-style="+%F %H:%M:%S" -lAa'
#
# Some more alias to avoid making mistakes:
# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'

PS1='\[\033[1;{{ system.accounts.prompt_color_host }}m\]\h\[\033[00m\]@\[\033[1;{{ system.accounts.prompt_color_user }}m\]\u\[\033[00m\]:\[\033[01;{{ system.accounts.prompt_color_root }}m\]\w\[\033[00m\]\$ '
# actually not on every node MySQL is installed but it does not hurt to configure the prompt here in generell
export MYSQL_PS1=$(echo -e "`hostname -s`@\\u mysql:\\d> ")