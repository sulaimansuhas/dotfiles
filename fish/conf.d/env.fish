# Add ~/.local/bin if it exists and isn't already in PATH
if test -d "$HOME/.local/bin"; and not contains "$HOME/.local/bin" $PATH
    # Prepending path in case a system-installed binary needs to be overridden
    set -gx PATH "$HOME/.local/bin" $PATH
end

# Add Cargo bin if it exists and isn't already in PATH
if test -d "$HOME/.cargo/bin"; and not contains "$HOME/.cargo/bin" $PATH
    set -gx PATH "$HOME/.cargo/bin" $PATH
end

# Detect OS
set -l os (uname -s)

if test "$os" = "Darwin"  # macOS
    if test -d "/usr/local/opt/llvm/bin"; and not contains "/usr/local/opt/llvm/bin" $PATH
        set -gx PATH "/usr/local/opt/llvm/bin" $PATH
    end
    /opt/homebrew/bin/brew shellenv | source
else if test "$os" = "Linux"
    # Linux-specific paths if needed
end
