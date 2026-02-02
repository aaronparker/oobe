#!/bin/zsh

# COLOR
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Ask for the administrator password upfront.
echo Enter root password
sudo -v

# Keep Sudo until script is finished
while true; do
  sudo -n true
  sleep 60
  kill -0 "$$" || exit
done 2>/dev/null &

# Update macOS
echo
echo "${GREEN}Searching for updates."
sudo softwareupdate -i -a

# Homebrew
echo Installing Homebrew
# sudo xcode-select --install
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# Login Window Message
echo Setting login window message
sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText "If my calculations are correct, when this baby hits eighty-eight miles per hour... you're gonna see some serious shit."

# Get the model name of the local machine
echo Get model
model_name=$(system_profiler SPHardwareDataType | awk '/Model Name/{print $3,$4,$5}')

# Check the model and set hostname accordingly
if [[ "$model_name" == *"Mac mini"* ]]; then
    echo "Running command for Mac mini..."
    sudo scutil --set ComputerName "Marty"
    sudo scutil --set LocalHostName "marty"
elif [[ "$model_name" == *"MacBook Air"* ]]; then
    echo "Running command for MacBook Air..."
    sudo scutil --set ComputerName "Einstein"
    sudo scutil --set LocalHostName "einstein"
    defaults write -g NSForceSoftwareVideoDecoder -bool true
    defaults -currentHost write com.apple.controlcenter BatteryShowPercentage -bool true
else
    echo "Unknown model: $model_name"
fi

# Dock settings
echo Dock settings
defaults write com.apple.dock "tilesize" -int "46"
defaults write com.apple.dock "autohide" -bool "true"
defaults write com.apple.dock "autohide-time-modifier" -float "0.5"
defaults write NSGlobalDomain "AppleShowAllExtensions" -bool "true"
defaults write com.apple.dock "expose-group-apps" -bool "true"
defaults write com.apple.dock showAppExposeGestureEnabled -int 1
killall Dock

# Finder settings
echo Finder settings
defaults write com.apple.finder "ShowPathbar" -bool "true"
defaults write com.apple.finder "_FXSortFoldersFirst" -bool "true"
defaults write com.apple.finder "FXDefaultSearchScope" -string "SCcf"
defaults write com.apple.finder "FXEnableExtensionChangeWarning" -bool "false"
defaults write NSGlobalDomain "NSTableViewDefaultSizeMode" -int "3"
defaults write com.apple.finder "_FXSortFoldersFirstOnDesktop" -bool "true"
defaults write com.apple.finder _FXEnableColumnAutoSizing -bool YES
defaults write com.apple.finder NewWindowTarget -string "Pfhm"
killall Finder

# Enable spanning of Spaces across multiple displays
echo Spaces settings
defaults write com.apple.spaces "spans-displays" -bool "false"
# killall SystemUIServer

# Modify screenshot location
echo Screenshot settings
mkdir ~/Pictures/Screenshots
defaults write com.apple.screencapture "location" -string "~/Pictures/Screenshots"
defaults write com.apple.screencapture "show-thumbnail" -bool "false"
killall SystemUIServer

# Trackpad and TextEdit settings
echo Trackpad and other settings
defaults write com.apple.AppleMultitouchTrackpad "DragLock" -bool "true"
defaults write com.apple.AppleMultitouchTrackpad "TrackpadThreeFingerDrag" -bool "true"
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -int "1"
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -int "1"
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -int "0"
defaults write com.apple.TextEdit "SmartQuotes" -bool "false"
defaults write com.apple.CloudSubscriptionFeatures.optIn "545129924" -bool "false"
# defaults write com.apple.universalaccess mouseDriverCursorSize 1.5

# Dont create .DS_Store Files On Network Or USB Volumes
echo Disable DS_Store files on network and USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Spotlight - disable related content
echo Disable Spotlight related content
defaults write com.apple.Spotlight EnabledPreferenceRules '("Custom.relatedContents")'

# Widgets - set appearance to light mode
echo Set widgets to light mode
defaults write com.apple.widgets widgetAppearance 0

# Zsh profile
echo Install ohmyzsh and set zsh profile
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
echo '' >> ~/.zshrc
echo 'alias cls="clear"' >> ~/.zshrc
echo 'alias dir="ls -l"' >> ~/.zshrc
echo 'alias drink="brew update && brew upgrade && brew cleanup"' >> ~/.zshrc
echo 'export DEFAULT_USER=$USER' >> ~/.zshrc
echo 'export HOMEBREW_NO_ENV_HINTS=1' >> ~/.zshrc
echo 'cd /Users/aaron/projects' >> ~/.zshrc
echo '' >> ~/.zshrc

# Terminal
echo Import Terminal preferences
defaults import com.apple.Terminal ./TerminalPreferences.plist

# Run brew install
echo Run brew bundle based on model
if [[ "$model_name" == *"Mac mini"* ]]; then
    echo "Running brew bundle for Mac mini..."
    brew bundle install --file ./Macmini-Brewfile.txt
elif [[ "$model_name" == *"MacBook Air"* ]]; then
    echo "Running brew bundle for MacBook Air..."
    brew bundle install --file ./MacBookAir-Brewfile.txt
else
    echo "Unknown model: $model_name"
fi

# Configure the dock pinned apps
echo Configure the dock pinned apps
dockutil --remove all
dockutil --add /Applications/Safari.app
dockutil --add /Applications/Microsoft\ Edge.app
dockutil --add /System/Applications/Calendar.app
dockutil --add /Applications/Visual\ Studio\ Code.app
dockutil --add /System/Applications/Utilities/Terminal.app
