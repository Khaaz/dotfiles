#!/bin/sh

prompt_install() {
	echo -n "$1 is not installed. Would you like to install it? (y/n) " >&2
	old_stty_cfg=$(stty -g)
	stty raw -echo
	answer=$( while ! head -c 1 | grep -i '[ny]'; do true; done )
	stty $old_stty_cfg && echo
	if echo "$answer" | grep -iq "^y"; then
		if [ -x "$(command -v pacman)" ]; then
			sudo pacman -S $1

			# optional install for i3
			if [ "$1" == "i3"]; then
				sudo pacman -S dmenu
			fi

		else
			echo "Not on Arch! Please install $1 on your own and run this deploy script again." 
		fi 
	fi
}

check_for_software() {
	echo "Checking to see if $1 is installed"
	if ! [ -x "$(command -v $1)" ]; then
		prompt_install $1
	else
		echo "$1 is installed."
	fi
}

check_default_shell() {
	if [ -z "${SHELL##*zsh*}" ]; then
			echo "Default shell is zsh."
	else
		echo -n "Default shell is not zsh. Do you want to chsh -s \$(which zsh)? (y/n)"
		old_stty_cfg=$(stty -g)
		stty raw -echo
		answer=$( while ! head -c 1 | grep -i '[ny]'; do true; done )
		stty $old_stty_cfg && echo
		if echo "$answer" | grep -iq "^y"; then
			chsh -s $(which zsh)
		else
			echo "Warning: Your configuration won't work properly. If you exec zsh, it'll exec tmux which will exec your default shell which isn't zsh."
		fi
	fi
}

echo "We're going to do the following:"
echo "1. Check to make sure you have i3, termite, zsh, tmux, vim installed"
echo "2. Install them if you don't"
echo "3. Check to see if your default shell is zsh"
echo "4. Change it if it's not" 

echo "Run install script? (y/n)"
old_stty_cfg=$(stty -g)
stty raw -echo
answer=$( while ! head -c 1 | grep -i '[ny]'; do true; done )
stty $old_stty_cfg
if echo "$answer" | grep -iq "^y"; then
	echo 
else
	echo "Quitting, nothing was changed."
	exit 0
fi


check_for_software i3
echo 
check_for_software termite
echo 
check_for_software zsh
echo 
check_for_software vim
echo
check_for_software tmux
echo

check_default_shell

echo
echo -n "Would you like to backup your current dotfiles? (y/n) "
old_stty_cfg=$(stty -g)
stty raw -echo
answer=$( while ! head -c 1 | grep -i '[ny]'; do true; done )
stty $old_stty_cfg
if echo "$answer" | grep -iq "^y"; then
	mv ~/.zshrc ~/.zshrc.old
	mv ~/.tmux.conf ~/.tmux.conf.old
	mv ~/.vimrc ~/.vimrc.old
else
	echo -e "\nNot backing up old dotfiles."
fi

# sourcing

printf "source '$HOME/dotfiles/zsh/zshrc_manager.sh'" > ~/.zshrc
printf "so $HOME/dotfiles/vim/vimrc.vim" > ~/.vimrc
printf "source-file $HOME/dotfiles/tmux/tmux.conf" > ~/.tmux.conf

echo
echo "Please log out and log back in for default shell to be initialized."
