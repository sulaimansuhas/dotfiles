#!/bin/bash

#What we need: 
# - FISH
# - CARGO

source .bashrc


if [[ $OSTYPE == 'darwin'* ]]; then
  export DETECTED_OS="OSX"
  echo '🍎 macOS detected'

  # Function to install packages via brew
  install_package() {
	  local package=$1
	  if brew list "$package" >/dev/null 2>&1; then
		  echo "✅ $package already installed"
	  else
		  echo "📦 Installing $package..."
		  if brew install "$package"; then
			  echo "✅ $package installed successfully"
		  else
			  echo "❌ Failed to install $package"
			  return 1
		  fi
	  fi
  }

  if ! command -v brew >/dev/null 2>&1; then
	  echo "🍺 Homebrew not found. Installing..."
	  # Check if curl is available
	  if ! command -v curl >/dev/null 2>&1; then
		  echo "❌ Error: curl is required but not installed"
		  exit 1
	  fi
	  # Install Homebrew
	  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  # Set up Homebrew in current session
  if [ -f "/opt/homebrew/bin/brew" ]; then
	  eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -f "/usr/local/bin/brew" ]; then
	  eval "$(/usr/local/bin/brew shellenv)"
  fi

  echo "🔄 Updating Homebrew..."
  brew update
  
  # Install Fish shell
  echo "🐟 Installing Fish shell..."
  install_package "fish"

  # Install Rust/Cargo
  if command -v cargo >/dev/null 2>&1; then
	  echo "🦀 Cargo is installed: $(cargo --version)"
  else
	  echo "🦀 Installing Rust and Cargo..."
	  curl https://sh.rustup.rs -sSf | sh
  fi 

  if command -v fish >/dev/null 2>&1; then
	  echo "✅ Fish: $(fish --version)"
	  echo "💡 To make Fish your default shell, run:"
	  echo "   echo $(which fish) | sudo tee -a /etc/shells"
	  echo "   chsh -s $(which fish)"
  else
	  echo "❌ Fish not found in PATH"
  fi
elif [[ $OSTYPE == 'linux'* ]]; then
	export DETECTED_OS="linux" 
	echo '🐧 Linux detected (assume ubuntu) '

	install_package() {
		local package=$1
		if dpkg -l | grep -q "^ii  $package "; then
			echo "✅ $package already installed"
		else
			echo "📦 Installing $package..."
			sudo apt update && sudo apt install -y "$package"
		fi
	}

	# Install Fish shell
	echo "🐟 Installing Fish shell..."
	install_package "fish"

	# Install Rust/Cargo
	echo "🦀 Installing Rust and Cargo..."
	curl https://sh.rustup.rs -sSf | sh

	if command -v cargo >/dev/null 2>&1; then
	  echo "✅ Cargo: $(cargo --version)"
	else
	  echo "❌ Cargo not found in PATH"
	fi

	if command -v fish >/dev/null 2>&1; then
	  echo "✅ Fish: $(fish --version)"
	  echo "💡 To make Fish your default shell, run:"
	  echo "   echo $(which fish) | sudo tee -a /etc/shells"
	  echo "   chsh -s $(which fish)"
	else
	  echo "❌ Fish not found in PATH"
	fi

else
	export DETECTED_OS="unknown"
	echo '❓ Unknown OS detected'
	exit 1
fi

echo "🔗 Setting up Fish configuration..."

# Remove existing Fish config (with backup)
if [ -d ~/.config/fish ]; then
    echo "📦 Backing up existing Fish config..."
    mv ~/.config/fish ~/.config/fish.backup-$(date +%s)
fi

# Create target directories
find fish -type d -exec mkdir -p ~/.config/{} \;

# Then symlink all files (no individual backups needed)
find fish -type f -exec sh -c '
    target="$HOME/.config/$1"
    ln -s "$PWD/$1" "$target"
    echo "🔗 Linked: $1"
' _ {} \;


echo "🎣 Installing Fish plugins..."
if fish -c "
if not functions -q fisher
    echo 'Installing Fisher...'
    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
    fisher install jorgebucaran/fisher
end
echo 'Updating plugins...'
fisher update
"; then
    echo "✅ Fish plugins installed"
else
    echo "⚠️  Plugin installation failed, but Fish config is ready"
fi

if fish -c "functions -q tide" 2>/dev/null; then
	echo "✅ Tide found, configuring..."
	fish -c "tide configure --auto --style=Lean --prompt_colors='True color' --show_time='24-hour format' --lean_prompt_height='One line' --prompt_spacing=Sparse --icons='Few icons' --transient=Yes"
else
	echo "❌ Tide not installed in Fish"
fi


# Run additional setup scripts
if [ -d "scripts" ]; then
    echo ""
    echo "🚀 Running additional setup scripts..."
    
    # Find all executable scripts and sort them
    for script in scripts/*; do
        if [ -f "$script" ] && [ -x "$script" ]; then
            echo ""
            echo "▶️  Running $(basename "$script")..."
            
            if "$script"; then
                echo "✅ $(basename "$script") completed successfully"
            else
                echo "❌ $(basename "$script") failed (exit code: $?)"
                read -p "Continue with remaining scripts? (y/N): " -n 1 -r
                echo
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    echo "Stopping script execution"
                    exit 1
                fi
            fi
        fi
    done
    
    echo ""
    echo "🎊 All setup scripts completed!"
else
    echo "📁 No scripts/ directory found, skipping additional setup"
fi

