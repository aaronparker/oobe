#!/bin/zsh

# Dock settings
defaults write com.apple.dock "tilesize" -int "46"
defaults write com.apple.dock "autohide" -bool "true"
defaults write com.apple.dock "autohide-time-modifier" -float "0.5"
defaults write com.apple.dock "mineffect" -string "suck"
defaults write NSGlobalDomain "AppleShowAllExtensions" -bool "true"
defaults write com.apple.dock "expose-group-apps" -bool "true"
defaults write com.apple.dock showAppExposeGestureEnabled -int 1
killall Dock

# Finder settings
defaults write com.apple.finder "ShowPathbar" -bool "true"
defaults write com.apple.finder "_FXSortFoldersFirst" -bool "true"
defaults write com.apple.finder "FXDefaultSearchScope" -string "SCcf"
defaults write com.apple.finder "FXEnableExtensionChangeWarning" -bool "false"
defaults write NSGlobalDomain "NSTableViewDefaultSizeMode" -int "3"
defaults write com.apple.finder "_FXSortFoldersFirstOnDesktop" -bool "true"
defaults write com.apple.finder _FXEnableColumnAutoSizing -bool YES
killall Finder

# Enable spanning of Spaces across multiple displays
defaults write com.apple.spaces "spans-displays" -bool "true"
# killall SystemUIServer

# Modify screenshot location
mkdir ~/Pictures/Screenshots
defaults write com.apple.screencapture "location" -string "~/Pictures/Screenshots"
defaults write com.apple.screencapture "show-thumbnail" -bool "false"
killall SystemUIServer

# Trackpad and TextEdit settings
defaults write com.apple.AppleMultitouchTrackpad "DragLock" -bool "true"
defaults write com.apple.AppleMultitouchTrackpad "TrackpadThreeFingerDrag" -bool "true"
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -int "1"
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -int "1"
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -int "0"
defaults write com.apple.TextEdit "SmartQuotes" -bool "false"
defaults write com.apple.CloudSubscriptionFeatures.optIn "545129924" -bool "false"
defaults write com.apple.universalaccess mouseDriverCursorSize -float 1.5

# Dont create .DS_Store Files On Network Or USB Volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Spotlight - disable related content
defaults write com.apple.Spotlight EnabledPreferenceRules '("Custom.relatedContents")'

# Get the model name of the local machine
model_name=$(system_profiler SPHardwareDataType | awk '/Model Name/{print $3,$4,$5}')

# Check the model and set hostname accordingly
if [[ "$model_name" == *"Mac mini"* ]]; then
    echo "Running command for Mac mini..."
    scutil --set ComputerName "Marty"
    scutil --set LocalHostName "marty"
elif [[ "$model_name" == *"MacBook Air"* ]]; then
    echo "Running command for MacBook Air..."
    scutil --set ComputerName "Einstein"
    scutil --set LocalHostName "einstein"
    defaults write -g NSForceSoftwareVideoDecoder -bool true
    defaults -currentHost write com.apple.controlcenter BatteryShowPercentage -bool true
else
    echo "Unknown model: $model_name"
fi

# Zsh
touch ~/.zprofile
echo 'echo "reading ~/.zprofile"' >> ~/.zprofile
touch ~/.zshrc
echo 'echo "reading ~/.zshrc"' >> ~/.zshrc

# Homebrew
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# Terminal
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
defaults import com.apple.Terminal ./TerminalPreferences.plist

# Login Window Message
sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText "If my calculations are correct, when this baby hits eighty-eight miles per hour... you're gonna see some serious shit."
