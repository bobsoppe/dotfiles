#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

# Bootstrap dotfiles on a fresh Mac.
# Usage: curl --fail --silent --show-error --location \
#   https://raw.githubusercontent.com/bobsoppe/dotfiles/main/install.sh | bash

# ── 1. Homebrew ──────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl --fail --silent --show-error --location https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# ── 2. Core tools ────────────────────────────────────────────
for tool in chezmoi gh git; do
  command -v "$tool" &>/dev/null || brew install "$tool"
done

# ── 3. Clone dotfiles repo ──────────────────────────────────
if [ ! -d "$HOME/.local/share/chezmoi/.git" ]; then
  echo "Cloning dotfiles..."
  chezmoi init bobsoppe/dotfiles
fi

# ── 4. Brewfile (installs 1Password, fish, gh, etc.) ─────────
if [ -f "$HOME/.local/share/chezmoi/Brewfile" ]; then
  echo "Installing Homebrew packages..."
  brew bundle --file="$HOME/.local/share/chezmoi/Brewfile"
fi

# ── 5. GitHub CLI auth ───────────────────────────────────────
# Authenticate the gh CLI for general GitHub operations (gh repo, gh pr, etc.).
# Drive the user through `gh auth login` interactively if not already authenticated.
if ! gh auth status &>/dev/null; then
  echo "Authenticating with GitHub..."
  gh auth login --hostname github.com --git-protocol ssh --web
fi

# ── 6. 1Password ─────────────────────────────────────────────
# The signing-related git templates call `op read` at apply time.
# ssh/config references the agent socket at the path 1Password installs it.
# Drive the user through the GUI setup if not already initialised.
_op_socket="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

if ! op account list --format=json 2>/dev/null | grep --quiet '"url"' || [ ! -S "$_op_socket" ]; then
  cat <<'MSG'

1Password setup required.

  1. Launch the 1Password desktop app (opening it now…)
  2. Sign in to your account
  3. Open Settings → Developer and enable:
       • "Use the SSH agent"
       • "Integrate with 1Password CLI" (biometric unlock)
  4. Press Enter here when ready, or Ctrl-C to abort.

MSG
  open -a 1Password || true
  read -r -p "Press Enter when 1Password is signed in and SSH agent is enabled... " </dev/tty

  while ! op account list --format=json 2>/dev/null | grep --quiet '"url"' || [ ! -S "$_op_socket" ]; do
    echo "Still waiting on 1Password CLI session and SSH agent socket..."
    read -r -p "Press Enter to re-check, or Ctrl-C to abort... " </dev/tty
  done
fi

# ── 7. Apply dotfiles ────────────────────────────────────────
echo "Applying dotfiles..."
chezmoi apply


# ── 8. macOS defaults ────────────────────────────────────────
# Diverges from Apple factory defaults.

# NSGlobalDomain
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 1
defaults write NSGlobalDomain com.apple.springing.enabled -bool true

# Dock
defaults write com.apple.dock mineffect -string scale
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock tilesize -int 32

# Finder
defaults write com.apple.finder FinderSpawnTab -bool false
defaults write com.apple.finder FXDefaultSearchScope -string SCcf
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.finder FXPreferredViewStyle -string clmv
defaults write com.apple.finder FXRemoveOldTrashItems -bool true
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false

# Trackpad
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerTapGesture -int 0
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerTapGesture -int 0

# Mouse
defaults write com.apple.driver.AppleBluetoothMultitouch.mouse MouseTwoFingerDoubleTapGesture -int 0
defaults write com.apple.driver.AppleBluetoothMultitouch.mouse MouseButtonMode -string TwoButton
defaults write com.apple.AppleMultitouchMouse MouseTwoFingerDoubleTapGesture -int 0
defaults write com.apple.AppleMultitouchMouse MouseButtonMode -string TwoButton

# Menu bar clock
defaults write com.apple.menuextra.clock ShowSeconds -bool true

# Window Manager (Sonoma+ desktop behavior)
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false
defaults write com.apple.WindowManager HideDesktop -bool true
defaults write com.apple.WindowManager AutoHide -bool true

# Mail
defaults write com.apple.mail-shared AddressDisplayMode -int 0
defaults write com.apple.mail-shared ExpandPrivateAliases -bool true
defaults write com.apple.mail-shared AlertForNonmatchingDomains -bool false

# Safari
defaults write com.apple.Safari.SandboxBroker ShowDevelopMenu -bool true

# Symbolic hotkeys (disable Mission Control, Apple Intelligence, F-key focus, misc)
_hotkeys_plist="$HOME/Library/Preferences/com.apple.symbolichotkeys.plist"
for _id in 7 8 9 10 11 12 13 32 33 34 35 36 37 52 57 65 79 80 81 82 118 119 120 121 122 123 124 125 126 127 128 129 162 163 164 165 175 179 190 222; do
  /usr/libexec/PlistBuddy -c "Set :AppleSymbolicHotKeys:${_id}:enabled false" "$_hotkeys_plist" 2>/dev/null || true
done

# Screencapture
defaults write com.apple.screencapture location -string "${HOME}/Downloads"

killall Dock
killall Finder
killall SystemUIServer

echo ""
echo "✓ Done."
