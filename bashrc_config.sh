#! /bin/bash
echo "export XAUTHORITY=~/.Xauthority" >> ~/.bashrc
echo "alias ll='ls -lha --color=auto'" >> ~/.bashrc
echo "alias cls=clear" >> ~/.bashrc >> ~/.bashrc
echo "export PS1="\[\033[38;5;10m\]\u\[$(tput sgr0)\]@\[$(tput sgr0)\]\[\033[38;5;196m\]\h\[$(tput sgr0)\]:\[$(tput sgr0)\]\[\033[38;5;14m\]\w\[$(tput sgr0)\]\\$\[$(tput sgr0)\]"" >> ~/.bashrc
