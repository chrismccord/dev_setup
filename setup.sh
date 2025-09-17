#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect the operating system
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        print_status "Detected macOS"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        print_status "Detected Linux"
    else
        print_error "Unsupported operating system: $OSTYPE"
        exit 1
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install package manager if needed
install_package_manager() {
    if [[ "$OS" == "macos" ]]; then
        if ! command_exists brew; then
            print_status "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        else
            print_success "Homebrew already installed"
        fi
    elif [[ "$OS" == "linux" ]]; then
        # Update package list
        print_status "Updating package list..."
        sudo apt update
    fi
}

# Install zsh if not already installed
install_zsh() {
    if ! command_exists zsh; then
        print_status "Installing zsh..."
        if [[ "$OS" == "macos" ]]; then
            brew install zsh
        elif [[ "$OS" == "linux" ]]; then
            sudo apt install -y zsh
        fi
    else
        print_success "zsh already installed"
    fi
}

# Install Oh My Zsh
install_oh_my_zsh() {
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        print_status "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        print_success "Oh My Zsh already installed"
    fi
}

# Install tmux
install_tmux() {
    if ! command_exists tmux; then
        print_status "Installing tmux..."
        if [[ "$OS" == "macos" ]]; then
            brew install tmux
        elif [[ "$OS" == "linux" ]]; then
            sudo apt install -y tmux
        fi
    else
        print_success "tmux already installed"
    fi
}

# Install tmux plugin manager (TPM)
install_tpm() {
    if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
        print_status "Installing tmux plugin manager (TPM)..."
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    else
        print_success "TPM already installed"
    fi
}

# Install neovim
install_neovim() {
    if ! command_exists nvim; then
        print_status "Installing Neovim..."
        if [[ "$OS" == "macos" ]]; then
            brew install neovim
        elif [[ "$OS" == "linux" ]]; then
            # Install from official appimage for latest version
            sudo apt install -y software-properties-common
            sudo add-apt-repository ppa:neovim-ppa/unstable -y
            sudo apt update
            sudo apt install -y neovim
        fi
    else
        print_success "Neovim already installed"
    fi
}

# Install system dependencies for neovim
install_nvim_dependencies() {
    print_status "Installing Neovim system dependencies..."

    if [[ "$OS" == "macos" ]]; then
        # Install clipboard support and file finding tools
        if ! command_exists pbcopy; then
            print_warning "pbcopy not found - clipboard may not work properly"
        fi

        # Install ripgrep and fd for better file finding
        if ! command_exists rg; then
            brew install ripgrep
        fi
        if ! command_exists fd; then
            brew install fd
        fi

    elif [[ "$OS" == "linux" ]]; then
        # Install clipboard support
        sudo apt install -y xclip

        # Install ripgrep and fd-find for better file finding
        sudo apt install -y ripgrep fd-find

        # Create symlink for fd if it's installed as fdfind
        if command_exists fdfind && ! command_exists fd; then
            sudo ln -sf $(which fdfind) /usr/local/bin/fd
        fi
    fi
}

# Install Git (usually pre-installed but ensure it's there)
install_git() {
    if ! command_exists git; then
        print_status "Installing Git..."
        if [[ "$OS" == "macos" ]]; then
            brew install git
        elif [[ "$OS" == "linux" ]]; then
            sudo apt install -y git
        fi
    else
        print_success "Git already installed"
    fi
}

# Install Node.js and npm (for nvim LSP servers)
install_node() {
    if ! command_exists node; then
        print_status "Installing Node.js..."
        if [[ "$OS" == "macos" ]]; then
            brew install node
        elif [[ "$OS" == "linux" ]]; then
            # Install Node.js 18.x LTS
            curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
            sudo apt install -y nodejs
        fi
    else
        print_success "Node.js already installed"
    fi
}

# Install NVM for Node version management
install_nvm() {
    if [[ ! -d "$HOME/.nvm" ]]; then
        print_status "Installing NVM..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
        # Source nvm immediately
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    else
        print_success "NVM already installed"
    fi
}

# Create necessary directories
create_directories() {
    print_status "Creating necessary directories..."

    # Create nvim config directory
    mkdir -p "$HOME/.config/nvim"

    # Create bash config directory (referenced in .zshrc)
    mkdir -p "$HOME/.zsh"

    # Create basic zsh config files if they don't exist
    touch "$HOME/.zsh/env"
    touch "$HOME/.zsh/config"
    touch "$HOME/.zsh/aliases"
    touch "$HOME/.zsh/completions"
    touch "$HOME/.zsh/paths"
    touch "$HOME/.zsh/functions"
    touch "$HOME/.zsh/exports"
}

# Copy configuration files
copy_config_files() {
    print_status "Copying configuration files..."

    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # Copy tmux config
    if [[ -f "$script_dir/.tmux.conf" ]]; then
        cp "$script_dir/.tmux.conf" "$HOME/.tmux.conf"
        print_success "Copied .tmux.conf"
    else
        print_warning ".tmux.conf not found in script directory"
    fi

    # Copy zsh config
    if [[ -f "$script_dir/.zshrc" ]]; then
        cp "$script_dir/.zshrc" "$HOME/.zshrc"
        print_success "Copied .zshrc"
    else
        print_warning ".zshrc not found in script directory"
    fi

    # Copy neovim config
    if [[ -f "$script_dir/init.lua" ]]; then
        cp "$script_dir/init.lua" "$HOME/.config/nvim/init.lua"
        print_success "Copied init.lua"
    else
        print_warning "init.lua not found in script directory"
    fi
}

# Set zsh as default shell
set_default_shell() {
    if [[ "$SHELL" != *"zsh"* ]]; then
        print_status "Setting zsh as default shell..."

        # Add zsh to /etc/shells if not already there
        local zsh_path=$(which zsh)
        if ! grep -q "$zsh_path" /etc/shells; then
            echo "$zsh_path" | sudo tee -a /etc/shells
        fi

        # Try different methods to change shell
        if command_exists chsh; then
            print_status "Attempting to change shell with chsh..."
            if chsh -s "$zsh_path" 2>/dev/null; then
                print_success "Default shell set to zsh (restart terminal to take effect)"
            else
                print_warning "chsh failed. Trying alternative method..."
                # Try with sudo
                if sudo chsh -s "$zsh_path" "$USER" 2>/dev/null; then
                    print_success "Default shell set to zsh with sudo (restart terminal to take effect)"
                else
                    print_warning "Could not change default shell automatically."
                    print_status "Please run manually: chsh -s $zsh_path"
                    print_status "Or add this to your shell profile: export SHELL=$zsh_path"
                fi
            fi
        else
            print_warning "chsh command not found. Please change shell manually:"
            print_status "Run: chsh -s $zsh_path"
        fi
    else
        print_success "zsh is already the default shell"
    fi
}

# Main installation function
main() {
    print_status "Starting dev environment setup..."

    # Detect OS
    detect_os

    # Install package manager
    install_package_manager

    # Install core dependencies
    install_git
    install_zsh
    install_oh_my_zsh
    install_tmux
    install_tpm
    install_neovim
    install_nvim_dependencies
    install_node
    install_nvm

    # Create directories and copy configs
    create_directories
    copy_config_files

    # Set default shell
    set_default_shell

    print_success "Setup complete!"
    print_status "Next steps:"
    echo "  1. Restart your terminal or run: source ~/.zshrc"
    echo "  2. Open tmux and press Ctrl-a + I to install tmux plugins"
    echo "  3. Open nvim - plugins will auto-install on first run"
    echo "  4. In nvim, wait for lazy.nvim to finish installing plugins"

    if [[ "$OS" == "linux" ]]; then
        echo "  5. You may need to logout/login for shell change to take effect"
    fi
}

# Run main function
main "$@"
