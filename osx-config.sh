# OSX installation and configuration script, inspired by the many examples that are available
# online and modified to my needs.

#!/bin/sh

# Install Xcode command line tools
if test ! $(which xcode-select); then
    echo "Installing Xcode command-line tools"
    xcode-select --install
fi

# Check for Homebrew to be present, install if it's missing
if test ! $(which brew); then
    echo "Installing homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' > ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
    #source ~/.zprofile
fi

# Update Brew
brew update

# Install iterm2
echo "Installing Iterm2"
brew install --cask iterm2

# Update the Terminal
# Install oh-my-zsh
echo "Installing oh-my-zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Install powerlevel10k theme
echo "Installing powerlevel10 theme"
if [ ! -d ~/.oh-my-zsh/themes/powerlevel10k ]; then
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

echo "Installing Visual Studio Code extensions"
while IFS= read -r line; do
    code --install-extension --force $line
done <<< "$EXTENSIONS"

# OSX modifications
echo "Applying OSX modifications"

# Setting Dock to auto-hide and removing the auto-hiding delay
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0
# Set Dock icon size for magnification
defaults write com.apple.dock largesize -int 64; killall Dock

# Setting the icon size of Dock items to 36 pixels for optimal size/screen-realestate
defaults write com.apple.dock tilesize -int 36

# Disable annoying backswipe in Chrome
defaults write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool false

# Setting screenshots location to ~/Desktop
defaults write com.apple.screencapture location -string "$HOME/Desktop"

# Enabling the Develop menu and the Web Inspector in Safari
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" -bool true

# Setting trackpad & mouse speed to a reasonable number
defaults write -g com.apple.trackpad.scaling 2
defaults write -g com.apple.mouse.scaling 2.5

# Configure keyboard speed settings
defaults write -g InitialKeyRepeat -int 10
defaults write -g KeyRepeat -int 1

# Disable smart quotes and smart dashes as they are annoying when typing code
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Disable auto rearrangment of spaces based on usage
defaults write com.apple.dock mru-spaces -bool false

# Require password when ending screen saver after 5 seconds
defaults write com.apple.screensaver askForPassword 1
defaults write com.apple.screensaver askForPasswordDelay 5

# Default apps I want to have in my Dock. I might consider just using Dockutil for this at a later moment
# https://github.com/kcrawford/dockutil
defaults delete com.apple.dock persistent-apps
defaults delete com.apple.dock recent-apps
defaults delete com.apple.dock persistent-others

dock_persistent_apps() {
    printf '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>%s</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>', "$1"
}
dock_persistent_others() {
    printf '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>%s</string><key>_CFURLStringType</key><integer>0</integer></dict></dict><key>title-type</key><string>directory-tile</string></dict>', "$1"
}

defaults write com.apple.dock persistent-apps -array \
    "$(dock_persistent_apps /Applications/iTerm.app)" \
    "$(dock_persistent_apps /Applications/Google\ Chrome.app)" \
    "$(dock_persistent_apps /Applications/Safari.app)" \
    "$(dock_persistent_apps /Applications/Visual\ Studio\ Code.app)" \
    "$(dock_persistent_apps /Applications/Slack.app)" \
    "$(dock_persistent_apps /System/Applications/Calendar.app)" \
    "$(dock_persistent_apps /System/Applications/Notes.app)" \
    "$(dock_persistent_apps /Applications/Spotify.app)"
# I typically have Dock items for Applications, Downloads and Documents as well. This works, but the tile-type isn't the one I want. I looks like the default is file-tile.
defaults write com.apple.dock persistent-others -array \
    "$(dock_persistent_others /Applications/)" \
    "$(dock_persistent_others ~/Downloads/)" \
    "$(dock_persistent_others ~/Documents/)"
killall Dock

# Create aliases file with default shortcuts
cat << EOF > ~/.aliases
alias kl="kubectl"
alias kx="kubectx"
alias ks="kubens"
EOF
echo "source ~/.aliases" >> ~/.zshrc

# Enable kubectl autocompletion
echo "source <(kubectl completion zsh)" >> ~/.zshrc

# Enable ZSH autosuggestions and autocompletion
echo "source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh" >> ~/.zshrc