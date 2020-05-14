#! /bin/bash
echo 'export XAUTHORITY=~/.Xauthority' >> ~/.bashrc
echo "alias ll='ls -lha --color=auto'" >> ~/.bashrc
echo 'alias cls=clear' >> ~/.bashrc
echo 'export PS1="\[\e[32m\]\u\[\e[m\]@\[\e[31m\]\h\[\e[m\]:\[\e[33m\]\t\[\e[m\]:\[\e[36m\]\w\[\e[m\] "' >> ~/.bashrc
bash
