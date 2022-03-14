# OSX installation and configuration script, inspired by the many examples that are available
# online and modified to my needs.

#!/bin/sh

# Install Xcode command line tools
if test ! $(which xcode-select); then
    echo "Installing Xcode command-line tools"
    xcode-select --install
fi

# Check for Homebrew to be present, install if it's missing
if [ ! -d /opt/homebrew ]; then
    echo "Installing homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' > ~/.zprofile
    # We want Brew to be available during the rest of the installation process as well
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Update Brew
brew update

# Install iterm2
echo "Installing Iterm2"
brew install --cask iterm2

# Install oh-my-zsh
if [ ! -d ~/.oh-my-zsh ]; then
    echo "Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    # Installation starts a new shell. We need to logout so the installation script can proceed.
    logout
fi

# Install powerlevel10k theme
if [ ! -d ~/.oh-my-zsh/themes/powerlevel10k ]; then
    echo "Installing powerlevel10 theme"
    git clone https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/themes/powerlevel10k
fi

# Update theme in .zshrc. Since sed is a bitch on OSX you'll need to add the additional single
# quotes due to sed -i expects a backup file first before the subsitute details.
echo "Updating theme"
sed -i '' 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc

# install powerline fonts
echo "Installing powerline fonts"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/powerline/fonts/master/install.sh)"

echo "Further configuration of the Powerline theme is done when starting Iterm"

# Install other apps
echo "Installing cask..."
CASKS=(
    vlc
    slack
    spotify
    visual-studio-code
    google-cloud-sdk
    google-chrome
    flux
    whatsapp
    telegram
    todoist
)
echo "Installing cask apps..."
brew install --cask ${CASKS[@]}

PACKAGES=(
    awscli
    ffmpeg
    terraform
    pwgen
    ansible
    wget
    helm
    stern
    kubectl
    kubectx
    zsh-autosuggestions
    zsh-completions
    dockutil
    readline
)
echo "Installing packages..."
brew install ${PACKAGES[@]}
# any additional steps you want to add here
# link readline
brew link --force readline

# Add Visual Studio Code to $PATH
echo 'export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"' >> ~/.zshrc
#source ~/.zshrc

# Install Visual Studio Code extension
EXTENSIONS=(
    vscodevim.vim
    eamodio.gitlens
    redhat.vscode-yaml
    HashiCorp.terraform
    ms-kubernetes-tools.vscode-kubernetes-tools
    ms-azuretools.vscode-docker
)

# Visual Studio Code can't handle all extensions at once so we'll iterate over them one by one
echo "Installing Visual Studio Code extensions"
for extension in "${EXTENSIONS[@]}"; do
    code --install-extension "$extension"
done

# OSX modifications
# TODO: Some of these need more work
echo "Applying OSX modifications"

# Setting Dock to auto-hide and removing the auto-hiding delay
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0

# Enable Magnification
defaults write com.apple.dock magnification -float 1

# Set Dock icon size for magnification
defaults write com.apple.dock largesize -int 64; killall Dock

# Setting the icon size of Dock items to 36 pixels for optimal size/screen-realestate
defaults write com.apple.dock tilesize -int 36

# Disable annoying backswipe in Chrome
defaults write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool false

# Setting screenshots location to ~/Desktop
defaults write com.apple.screencapture location -string "$HOME/Desktop"

# Setting trackpad & mouse speed to a reasonable number
defaults write -g com.apple.trackpad.scaling 2
defaults write -g com.apple.mouse.scaling 2.5

# Configure keyboard speed settings
defaults write -g InitialKeyRepeat -int 10
defaults write -g KeyRepeat -int 1

# TODO: Need to check keyboard and trackpad values as they are not yet where I want them.

# Disable smart quotes and smart dashes as they are annoying when typing code
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Disable auto rearrangment of spaces based on usage
defaults write com.apple.dock mru-spaces -bool false

# Require password when ending screen saver after 5 seconds
defaults write com.apple.screensaver askForPassword 1
defaults write com.apple.screensaver askForPasswordDelay 5

echo "Applying changes to Dock"

# Remove everything from dock
dockutil --remove all
# Default apps I want to have in my Dock.
dockutil --add /Applications/iTerm.app
dockutil --add /Applications/Google\ Chrome.app
dockutil --add /Applications/Safari.app
dockutil --add /Applications/Visual\ Studio\ Code.app
dockutil --add /Applications/Slack.app
dockutil --add /System/Applications/Calendar.app
dockutil --add /System/Applications/Notes.app
dockutil --add /Applications/Todoist.app
dockutil --add /System/Applications/System\ Preferences.app
dockutil --add /Applications/ --view grid
dockutil --add ~/Downloads/ --view grid
dockutil --add ~/Documents/ --view grid

# Create aliases file with default shortcuts
cat << EOF > ~/.aliases
alias kl="kubectl"
alias kx="kubectx"
alias ks="kubens"
EOF
echo "source ~/.aliases" >> ~/.zshrc

# Enable kubectl autocompletion
echo "source <(kubectl completion zsh)" >> ~/.zshrc

# Enable Gcloud autocompletion
echo "source /opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc" >> ~/.zshrc

# Enable ZSH autosuggestions and autocompletion
echo "source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh" >> ~/.zshrc