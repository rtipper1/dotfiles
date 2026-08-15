# Login shells (including tmux panes) read this instead of ~/.bashrc.
# Keep interactive config in one place.
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi
