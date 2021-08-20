ln -sf ~/dotfiles/.bashrc ~/.bashrc
ln -sf ~/dotfiles/.vimrc ~/.vimrc
ln -sf ~/dotfiles/.Xmodmap ~/.Xmodmap
#ln -sf ~/dotfiles/.vim ~/.vim this is pretty buggy just install vundle normally and everything will work
ln -sf ~/dotfiles/.vimrc ~/.vimrc

source .bashrc
xmodmap .Xmodmap
