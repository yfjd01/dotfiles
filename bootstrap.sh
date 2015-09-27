#!/bin/bash
# inspired by everyone else who's ever done such a thing, but mostly Paul Vilchez
# who turned me on to this whole dotfiles thing, unbeknownst to him

source ./lib.sh

set -e

bot "Setting up your dotfiles for you, you handsome bastard."

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUNDLE_DIR="${BASE_DIR}/vim/bundle"
BACKUP_DIR="${BASE_DIR}/vim/backup"
AUTOLOAD_DIR="${BASE_DIR}/vim/autoload"

MY_NAME="$(whoami)"

bot "Starting with Vim bits"
action "cleaning up vim directives"
#vim dir setup
if [ -L ~/.vim ]; then #is ~/.vim a symlink
  rm ~/.vim
elif [ -d ~/.vim ]; then #is ~/.vim a directory
  mv ~/.vim ~/.vim-old
fi

ln -Fs ${BASE_DIR}/vimrc ~/.vimrc #this is hella basic, but should suffice for now
# I don't want to symlink this dir, I want to create and do the installation of stuff on this machine, not carry around the config... right?
ln -Fs ${BASE_DIR}/vim/ ~/.vim

action "Setting up vim directories"
#does the DIR exist? if not, create it
[ -d $BACKUP_DIR ]   || mkdir -p $BACKUP_DIR
[ -d $BUNDLE_DIR ]   || mkdir -p $BUNDLE_DIR
[ -d $AUTOLOAD_DIR ] || mkdir -p $AUTOLOAD_DIR

install pathogen
action "Downloading pathogen..."
#TODO: only download if pathogen is not already installed
PATHOGEN_DEST="${AUTOLOAD_DIR}/pathogen.vim"
curl -LSso $PATHOGEN_DEST https://tpo.pe/pathogen.vim #I should totally be checking for completion of this
ok "Pathogen download complete"

#install vim bundles
action "Installing NERDTree"
declare -a nerd_tree=("NERDTree file navigation" "https://github.com/scrooloose/nerdtree.git")
get_vim_bundle $BUNDLE_DIR "${nerd_tree[0]}" "${nerd_tree[1]}"
warn "Don't forget to run :Helptags when you first run vim!"

action "Installing Solarized theme"
declare -a solarized_theme=("Solarized theme" "https://github.com/altercation/vim-colors-solarized.git")
get_vim_bundle $BUNDLE_DIR "${solarized_theme[0]}" "${solarized_theme[1]}"

action "Installing syntax packages"
declare -a coffeescript_syntax=("Vim Coffeescript syntax package" "https://github.com/kchmck/vim-coffee-script.git")
get_vim_bundle $BUNDLE_DIR "${coffeescript_syntax[0]}" "${coffeescript_syntax[1]}"

declare -a arduino_syntax=("Arduino syntax package" "https://github.com/sudar/vim-arduino-syntax.git")
get_vim_bundle $BUNDLE_DIR "${arduino_syntax[0]}" "${arduino_syntax[1]}"

declare -a less_syntax=("Less syntax package" "https://github.com/groenewege/vim-less.git")
get_vim_bundle $BUNDLE_DIR "${less_syntax[0]}" "${less_syntax[1]}"

action "Installing vim-airline status bar tool"
declare -a airline_tool=("Vim Airline status bar tool" "https://github.com/bling/vim-airline.git")
get_vim_bundle $BUNDLE_DIR "${airline_tool[0]}" "${airline_tool[1]}"

action "Installing vim indent guide tool"
declare -a indent_guide=("Vim Indent Guides" "https://github.com/nathanaelkane/vim-indent-guides.git")
get_vim_bundle $BUNDLE_DIR "${indent_guide[0]}" "${indent_guide[1]}"

bot "Setting up Git preferences"
if [ -f ~/.gitconfig ]; then
  mv ~/.gitconfig ~/.gitconfig-old
fi
ln -s ${BASE_DIR}/gitconfig ~/.gitconfig
ln -Fs ${BASE_DIR}/gitmessage ~/.gitmessage
ok "Finished setting up git prefs"

#terminal prefs (what's the difference between input and bash_profile prefs?)
bot "Setting up terminal prefs"
if [ -f ~/.inputrc ]; then
  mv ~/.inputrc ~/.inputrc-old
fi
ln -Fs ${BASE_DIR}/inputrc ~/.inputrc

if [ -f ~/.bashrc ]; then
  mv ~/.bashrc ~/.bashrc-old
fi
ln -Fs ${BASE_DIR}/bashrc ~/.bashrc

bot "Setting up terminal extras"
if [ -f ~/.functions ]; then
  mv ~/.functions ~/.functions-old
fi
ln -Fs ${BASE_DIR}/functions ~/.functions

if [ -f ~/.aliases ]; then
  mv ~/.aliases ~/.aliases-old
fi
ln -Fs ${BASE_DIR}/aliases ~/.aliases

ok "Finished with terminal prefs"

# determine the platform you're using, which will determine whether we use
# homebrew or apt-get (in a far off universe where I may possibly choose a Ubuntu machine again)
PLATFORM="$(uname -s)"
case "$(uname -s)" in
  "Darwin")
    echo "You're running OS X. This is good."
    echo "Soon this will install homebrew for you"
    bot "Setting up Homebrew and those bits"
    # I know, I know. installing arbitrary stuff pulled via curl is bad news bears
    #check if homebrew is installed?
    if brew help | grep -q "Example usage:"; then
      #installed, rad
      ok "Homebrew already installed"
    else
      action "Installing Homebrew now"
      #install_homebrew
    fi
    action "Installing homebrew packages"
    install_brews
    #install_casks #once I'm sure that this is a good thing, I'll turn it on, but it needs to do things like check whether those applications are already installed and other checks.
    #maybe move that stuff over to a "first run" type script, because so far bootstrap.sh can be used almost any time, anywhere, with little to no bad news
    ok "Finished with Homebrew and brews"
    ;;
  "Linux")
    echo "You're running linux… good for you I guess?"
    # this should use apt-get instead, but we'll worry about that later, if ever
    ;;
esac

#TODO: install good ruby gems/tools like rvm or rbenv (I forget which one is en vouge and the current golden child.
#sublime text prefs

bot "Everything is done! Congrats"
