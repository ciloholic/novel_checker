#!/bin/sh

set -e

echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
cat <<EOF >> ~/.bash_aliases
alias ll='ls -lh'
alias la='ls -lha'
EOF
