# Sets reasonable macOS defaults.
# Or, in other words, set shit how I like in macOS.
# The original idea (and a couple settings) were grabbed from:
#   https://github.com/mathiasbynens/dotfiles/blob/master/.macos
set_macos_defaults() {
    ###############################################################################
    # System                                                                      #
    ###############################################################################

    # Disable press-and-hold for keys in favor of key repeat
    defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

    # Set a blazingly fast keyboard repeat rate
    # defaults write NSGlobalDomain KeyRepeat -int 1
    # defaults write NSGlobalDomain InitialKeyRepeat -int 10


    ###############################################################################
    # Finder                                                                      #
    ###############################################################################

    # allow quitting via ⌘ + Q; doing so will also hide desktop icons
    # defaults write com.apple.finder QuitMenuItem -bool true

    # disable window animations and Get Info animations
    defaults write com.apple.finder DisableAllAnimations -bool true

    # Use list view in all Finder windows by default
    # Four-letter codes for the other view modes: `icnv`, `clmv`, `glyv`
    defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

    # Keep folders on top when sorting by name
    defaults write com.apple.finder _FXSortFoldersFirst -bool true

    # Finder: show all filename extensions
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true

    # Show icons for hard drives, servers, and removable media on the desktop
    defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
    defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
    defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
    defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

    # Avoid creating .DS_Store files on network or USB volumes
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

    # Show hidden files
    defaults write com.apple.finder AppleShowAllFiles -bool true

    # Show the ~/Library folder
    chflags nohidden ~/Library

    # Show the /Volumes folder
    chflags nohidden /Volumes

    # Apply finder changes
    killall finder

    ###############################################################################
    # File Vault                                                                  #
    ###############################################################################

    # Enable vault
    defaults write com.apple.MCX.FileVault2 Enable -string yes

    ###############################################################################
    # Screenshots                                                                 #
    ###############################################################################

    # Set up directory to save screenshots inside ~/Downloads/screenshots.
    # I choose  this directory because download folder is my most reviewed dir
    mkdir -p ~/Downloads/screenshots
    defaults write com.apple.screencapture location ~/Downloads/screenshots

    # Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
    defaults write com.apple.screencapture type -string "png"

    ###############################################################################
    # Dock                                                                        #
    ###############################################################################

    # Show in Dock just opened applications
    defaults write com.apple.dock static-only -bool true

    # Automatically hide and show the dock
    defaults write com.apple.dock autohide -bool true

    # Disable changes in the Dock
    defaults write com.apple.dock contents-inmutable -bool true

    # The size of the largest magnification. Min 16, Max 128
    defaults write com.apple.dock largesize -int 50
    defaults write com.apple.dock tilesize -int 50

    # orientation of the Dock. Values bottom, left and right
    defaults write com.apple.dock orientation -string bottom

    # Apply all Dock settings
    killall Dock

    ###############################################################################
    # Menu Extras                                                                 #
    ###############################################################################

    # The number of seconds to delay after login before adding or removing menu extras
    defaults write com.apple.mcxMenuExtras delaySeconds -int 5
    defaults write com.apple.mcxMenuExtras maxWaitSeconds -int 30

    # Things that shows in the menu extra
    defaults write com.apple.mcxMenuExtras AirPort.menu -bool yes
    defaults write com.apple.mcxMenuExtras Bluetooth.menu -bool yes
    defaults write com.apple.mcxMenuExtras CPU.menu -bool yes
    defaults write com.apple.mcxMenuExtras Clock.menu -bool yes
    defaults write com.apple.mcxMenuExtras Volume.menu -bool yes

    # show battery percentage
    defaults write com.apple.menuextra.battery ShowPercent -string yes

    # Apply changes inside menu extra
    killall SystemUIServer

    ###############################################################################
    # iCloud                                                                      #
    ###############################################################################

    # Start iTunes from responding to the keyboard media keys. To disable put unload
    launchctl load -w /System/Library/LaunchAgents/com.apple.rcd.plist 2> /dev/null

    # Save to disk (not to iCloud) by default
    defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

    ###############################################################################
    # Terminal                                                                    #
    ###############################################################################

    # Only use UTF-8 in Terminal.app
    defaults write com.apple.terminal StringEncodings -array 4

    red "============================"
    green "Done. Note that some of these changes require a logout/restart to take effect."
    red "============================"

    ###############################################################################
    # Spotify                                                                     #
    ###############################################################################

    # Does not run when start
    defaults write com.spotify.client AutoStartSettingIsHidden -int 0
}

# Obtain  vendor and product ID for bluetooth device attached.
# Explanation:
# system_profiler SPBluetoothDataType       -- json show system specifications of the bluetooth in Json Format. To check all list can use system_profiler -listDataTypes
# grep -e                                   -- filter for both productID and vendor ID. Values are in Hexadecimal
# grep -o -e "\"0.*\""                      -- delete the 0x of Hexadecimal values
# tr -d '"'                                 -- delete the quotes remaining from the json output
# xargs -L1 printf "%d\n" {} 2>/dev/null    -- get all arguments from the previous filters and convert to hexadecimal, ensuring that all the error output goes to /dev/null
# grep -v 0                                 -- filter remaining 0 in the output to just get the desired ID
function get_bluetooth_device_info() {
    KEY_TO_FILTER=$1
    echo $(system_profiler SPBluetoothDataType -json 2>/dev/null | grep -e $KEY_TO_FILTER| grep -o -e "\"0.*\"" | tr -d '"' | xargs -L1 printf "%d\n" {} 2>/dev/null | grep -v 0)
}

# Obtain  vendor and product ID for bluetooth device attached.
# Explanation:
# ioreg -p IOUSB -c IOUSBDevice             -- information about mac USB devices
# grep -e class -e idVendor -e idProduct    -- filter for class, vendor and product
# grep -A2 "Apple Internal Keyboard"        -- filter for apple internal keyboard and two lines for the filtered vendor and product
# grep -o -e "$KEY_TO_FILTER.*$"            -- filter for the device information required
# grep -o -e \d+                            -- filter for getting just the number
function get_keyboard_device_info() {
    KEY_TO_FILTER=$1
    ioreg -p IOUSB -c IOUSBDevice | grep -e class -e idVendor -e idProduct| grep -A2 "Apple Internal Keyboard" | grep -o -e "$KEY_TO_FILTER.*$" | grep -o -e "\d\+"
}

function change_caps_lock_to_control() {
    VENDOR_ID=$1
    PRODUCT_ID=$2

    CAPS_LOCK_KEY_ID=30064771300
    CONTROL_KEY_ID=30064771129

    blue "Read current configuration of your keyboard"
    defaults -currentHost read -g | grep -e "$VENDOR_ID-$PRODUCT_ID"
    STATUS=$?
    if [[ $STATUS == 0 ]];
    then
        green "This device is already configured"
    else
        blue "Change Caps Lock to Control in bluetooth keyboard"
        defaults -currentHost write -g com.apple.keyboard.modifiermapping.$VENDOR_ID-$PRODUCT_ID-0 -array-add "<dict><key>HIDKeyboardModifierMappingDst</key><integer>$CAPS_LOCK_KEY_ID</integer><key>HIDKeyboardModifierMappingSrc</key><integer>$CONTROL_KEY_ID</integer></dict>"
        red "========================================="
        green "Success! This actions required restart"
        red "========================================="
    fi
}

# More information: https://apple.stackexchange.com/questions/13598/updating-modifier-key-mappings-through-defaults-command-tool
function change_caplock_to_control_in_keyboards() {

    BT_VENDOR_ID=$(get_bluetooth_device_info "device_vendorID")
    BT_PRODUCT_ID=$(get_bluetooth_device_info "device_productID")
    change_caps_lock_to_control $BT_VENDOR_ID $BT_PRODUCT_ID

    KEYBOARD_VENDOR_ID=$(get_keyboard_device_info "idVendor")
    KEYBOARD_PRODUCT_ID=$(get_keyboard_device_info "idProduct")
    change_caps_lock_to_control $KEYBOARD_VENDOR_ID $KEYBOARD_PRODUCT_ID
}

# ============================================================================
# MAIN
# ============================================================================

if test "$(uname)" = "Darwin"
then
    blue "Setting MacOS sane defaults"
    set_macos_defaults
    change_caplock_to_control_in_keyboards
fi
