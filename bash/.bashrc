# ==========================================
# 1. NON-INTERACTIVE GUARD
# ==========================================
# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# ==========================================
# 2. SYSTEM ENVIRONMENT & ENCODING
# ==========================================
# Starship requires UTF-8 to render icons correctly
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export BROWSER="google-chrome-stable"

# ==========================================
# 3. CUSTOM SYSTEM PATHS
# ==========================================
# Ensures Bash can find Starship if installed in local directories
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# ==========================================
# 4. STANDARD ALIASES (Optional)
# ==========================================
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# ==========================================
# 5. STARSHIP INITIALIZATION
# ==========================================
# This MUST stay at the absolute bottom of the file
if command -v starship &> /dev/null; then
    eval "$(starship init bash)"
else
    echo "Warning: starship binary not found in PATH"
fi

