#!/bin/zsh

defaults write com.apple.dock "tilesize" -int "46"
defaults write com.apple.dock "autohide" -bool "true"
defaults write com.apple.dock "autohide-time-modifier" -float "0.5"
defaults write com.apple.dock "mineffect" -string "suck"
defaults write NSGlobalDomain "AppleShowAllExtensions" -bool "true"
defaults write com.apple.dock "expose-group-apps" -bool "true"
killall Dock

defaults write com.apple.finder "ShowPathbar" -bool "true"
defaults write com.apple.finder "_FXSortFoldersFirst" -bool "true"
defaults write com.apple.finder "FXDefaultSearchScope" -string "SCcf"
defaults write com.apple.finder "FXEnableExtensionChangeWarning" -bool "false"
defaults write NSGlobalDomain "NSTableViewDefaultSizeMode" -int "3"
defaults write com.apple.finder "_FXSortFoldersFirstOnDesktop" -bool "true"
killall Finder

defaults write com.apple.spaces "spans-displays" -bool "true"
killall SystemUIServer

defaults write com.apple.AppleMultitouchTrackpad "DragLock" -bool "true"
defaults write com.apple.AppleMultitouchTrackpad "TrackpadThreeFingerDrag" -bool "true"
defaults write com.apple.TextEdit "SmartQuotes" -bool "false"
defaults write com.apple.CloudSubscriptionFeatures.optIn "545129924" -bool "false"
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -int "1"
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -int "1"
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -int "0"

scutil --set ComputerName "Einstein"
scutil --set LocalHostName "einstein"

mkdir ~/Pictures/Screenshots
defaults write com.apple.screencapture "location" -string "~/Pictures/Screenshots"
defaults write com.apple.screencapture "show-thumbnail" -bool "false"
killall SystemUIServer

touch ~/.zprofile
echo 'echo "reading ~/.zprofile"' >> ~/.zprofile
touch ~/.zshrc
echo 'echo "reading ~/.zshrc"' >> ~/.zshrc

xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
