#!/bin/bash

# Colors for output readability
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Global variables
SILENT_MODE=0
LOG_FILE="${LOG_FILE:-/var/log/popos_maintenance.log}"
APT_UPDATED=0
declare -A COMMANDS

# Check commands
check_commands() {
    for cmd in flatpak fwupdmgr pop-upgrade lynis wget unzip curl; do
        COMMANDS["$cmd"]=$(command -v "$cmd" >/dev/null 2>&1 && echo 1 || echo 0)
    done
}

check_commands

# Ensure log file
[ ! -f "$LOG_FILE" ] && sudo touch "$LOG_FILE" && sudo chmod 640 "$LOG_FILE" && sudo chown root:adm "$LOG_FILE"

# Check root
[ "$(id -u)" -ne 0 ] && { echo "This script requires root privileges. Please run with sudo."; exit 1; }

check_network() {
    ping -c 1 8.8.8.8 >/dev/null 2>&1 && return 0 || { log_message "${YELLOW}No network. Skipping network tasks.${NC}"; return 1; }
}

# Helper function to log messages
log_message() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" | tee -a "$LOG_FILE" > /dev/null
    if [ $SILENT_MODE -eq 0 ]; then
        echo -e "$message"
    fi
}

update_apt() {
    [ $APT_UPDATED -eq 0 ] && { log_message "Updating APT..."; apt-get update -y || { log_message "${RED}APT update failed.${NC}"; exit 1; }; APT_UPDATED=1; }
}

# Apply All Updates
apply_updates() {
    log_message "${GREEN}Let’s get your system up to date...${NC}"
    if check_network; then
        update_apt
        apt-get upgrade -y || { log_message "${RED}APT upgrade failed.${NC}"; return 1; }
        apt autoremove -y || { log_message "${RED}APT autoremove failed.${NC}"; return 1; }
        apt autoclean -y || { log_message "${RED}APT autoclean failed.${NC}"; return 1; }
        [ ${COMMANDS[flatpak]} -eq 1 ] && flatpak update -y &
        [ ${COMMANDS[fwupdmgr]} -eq 1 ] && { fwupdmgr refresh && fwupdmgr update -y; } &
        wait
    fi
    if [ ${COMMANDS[pop-upgrade]} -eq 1 ]; then
        log_message "Updating system & recovery partition..."
        pop-upgrade release check
        if [ $SILENT_MODE -eq 0 ]; then
            read -p "Perform the release upgrade now? (y/N): " upgrade
            if [[ $upgrade =~ ^[Yy]$ ]]; then
                pop-upgrade release upgrade || log_message "${YELLOW}System upgrade failed.${NC}"
                pop-upgrade recovery upgrade from-release || log_message "${YELLOW}Recovery upgrade failed.${NC}"
            else
                log_message "Release upgrade skipped-no worries!"
            fi
        else
            log_message "Skipping release upgrade in silent mode."
        fi
    fi
    log_message "${GREEN}All updates applied successfully—nice work!${NC}"
    # Check if a reboot is required
    if [ -f /var/run/reboot-required ]; then
        if [ $SILENT_MODE -eq 0 ]; then
            read -p "Reboot required. Reboot now? (y/N): " reboot_choice
            if [[ $reboot_choice =~ ^[Yy]$ ]]; then
                log_message "Rebooting now..."
                reboot
            else
                log_message "Reboot skipped. Please reboot manually later."
            fi
        else
            log_message "Reboot required but skipped in silent mode. Please reboot manually."
        fi
    else
        log_message "No reboot required."
    fi
}

# Config New Install
config_new_install() {
    log_message "${GREEN}Setting up your new Pop!_OS install...${NC}"
    # Check if Lynis is installed
    if [ ${COMMANDS[lynis]} -eq 0 ]; then
        echo "Lynis is not installed."
        read -p "Would you like to install Lynis to run local security checks? (y/n): " install_choice
        if [ "$install_choice" = "y" ] || [ "$install_choice" = "Y" ]; then
            echo "Installing Lynis..."
            if apt install lynis -y; then
                echo "${GREEN}Lynis installed successfully.${NC}"
            else
                echo "${RED}Failed to install Lynis.${NC}"
                return 1
            fi
        else
            echo "Lynis is required for security checks. Exiting."
            return 1
        fi
    else
        echo "Lynis is already installed."
    fi

    # Prompt to run security checks
    read -p "Would you like to run security checks with Lynis for your Debian-based personal computer? (y/n): " run_choice
    if [ "$run_choice" = "y" ] || [ "$run_choice" = "Y" ]; then
        # Create a custom Lynis profile for personal Debian use
        profile_path="/etc/lynis/personal.prf"
        echo "Creating custom Lynis profile at $profile_path..."

        cat > "$profile_path" << 'EOF'
# Custom Lynis profile for personal Debian-based computer
# Focus on personal use security checks

# Enable specific tests relevant for personal use
test_category_authentication=1
test_category_filesystems=1
test_category_users=1
test_category_ssh=1
test_category_software=1
test_category_kernel=1
test_category_firewalls=1
test_category_homedirs=1

# Skip tests less relevant for personal use
skip-test=NETW-2704  # Skip advanced network checks
skip-test=PHP-2372   # Skip PHP-specific checks
skip-test=DBS-1800   # Skip database checks
skip-test=WEB-8000   # Skip web server checks

# Set log level to focus on warnings and suggestions
log-level=warning
EOF

        # Run Lynis with the custom profile
        echo "Running Lynis security scan with custom profile..."
        lynis audit system --profile "$profile_path" --quiet

        # Display results summary
        echo "Security scan completed. Check /var/log/lynis.log for details and /var/log/lynis-report.dat for a report."
        echo "Key suggestions:"
        grep -E "Suggestion" /var/log/lynis-report.dat | head -n 5
    else
        echo "Security checks skipped."
    fi
: '
    log_message "Updating Lynis signatures..."
    lynis update info
    log_message "Hardening ulimit and core dumps..."
    echo "ulimit -c 0" | tee -a /etc/profile
    echo "* hard core 0" | tee -a /etc/security/limits.conf
    log_message "Applying kernel protections..."
    sysctl -w kernel.unprivileged_userns_clone=0
    sysctl -w net.ipv4.conf.all.rp_filter=1
    echo "kernel.unprivileged_userns_clone=0" | tee -a /etc/sysctl.d/99-hardening.conf
    echo "net.ipv4.conf.all.rp_filter=1" | tee -a /etc/sysctl.d/99-hardening.conf
    sysctl -p
    log_message "Setting sudo timeout to 5 minutes..."
    echo "Defaults timestamp_timeout=5" | tee /etc/sudoers.d/timeout
    log_message "Securing /tmp with tmpfs..."
    echo "tmpfs /tmp tmpfs nosuid,nodev,noexec 0 0" | tee -a /etc/fstab
    mount -a || log_message "${YELLOW}Warning: /tmp mount failed. Check /etc/fstab.${NC}"
    log_message "Securing home directory..."
    chmod 700 /home/$USER
    log_message "Configuring firewall..."
    apt install -y ufw
    ufw default deny incoming
    ufw default allow outgoing
    if dpkg -l | grep -q samba; then
        ufw allow from 192.168.1.0/24 to any port 137,138 proto udp
        ufw allow from 192.168.1.0/24 to any port 139,445 proto tcp
        log_message "Samba ports opened in firewall."
    else
        log_message "Samba not detected; skipping Samba-specific firewall rules."
    ufw logging medium
    ufw enable
    log_message "Checking IPv6 usage..."
    if ip -6 addr show | grep -q "inet6"; then
        read -p "IPv6 is in use. Disable it? (y/N): " disable_ipv6
        if [[ $disable_ipv6 =~ ^[Yy]$ ]]; then
            sysctl -w net.ipv6.conf.all.disable_ipv6=1
            echo "net.ipv6.conf.all.disable_ipv6=1" | tee -a /etc/sysctl.conf
            sysctl -p
            log_message "IPv6 disabled."
        else
            log_message "IPv6 left enabled."
        fi
    else
        log_message "No IPv6 detected; skipping disable."
    fi
    sysctl -p
    log_message "Hardening SSH..."
    sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
    if [ $SILENT_MODE -eq 0 ]; then
        read -p "Disable SSH password authentication? Ensure key-based auth is set up (y/N): " ssh_choice
        if [[ $ssh_choice =~ ^[Yy]$ ]]; then
            sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
        fi
    fi
    sudo sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config
    sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
    sudo systemctl restart sshd || log_message "${RED}Failed to restart SSH service.${NC}"
    log_message "Disabling Avahi daemon..."
    systemctl disable avahi-daemon && systemctl stop avahi-daemon
    log_message "Disabling Pop!_OS telemetry..."
    systemctl disable pop-hw-probe && systemctl mask pop-hw-probe
    log_message "Configuring NextDNS..."
    read -p "Do you use NextDNS? Enter your profile ID (or press Enter to skip): " nextdns_id
    if [ -n "$nextdns_id" ]; then
        mkdir -p /etc/systemd/resolved.conf.d
        cat << EOF | tee /etc/systemd/resolved.conf.d/nextdns.conf
[Resolve]
DNS=45.90.28.0#$nextdns_id.dns.nextdns.io
DNS=2a07:a8c0::#$nextdns_id.dns.nextdns.io
DNS=45.90.30.0#$nextdns_id.dns.nextdns.io
DNS=2a07:a8c1::#$nextdns_id.dns.nextdns.io
Domains=~.
DNSOverTLS=yes
EOF
        systemctl restart systemd-resolved
        log_message "NextDNS configured with profile $nextdns_id."
    else
        log_message "NextDNS configuration skipped."
    fi
    log_message "Configuring NTP..."
    sed -i 's/#NTP=/NTP=pool.ntp.org/' /etc/systemd/timesyncd.conf
    systemctl restart systemd-timesyncd
    log_message "${GREEN}Your new install is fully configured—great job!${NC}"
'
}

# System Health Check
check_system_health() {
    log_message "${GREEN}Checking your system’s health...${NC}"
    log_message "Load Average:"; uptime
    log_message "Disk Usage:"; df -h | grep '^/dev'
    log_message "Memory Usage:"; free -h
    log_message "Top 5 Memory-Intensive Processes:"; ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 6
    log_message "Failed Systemd Services:"; systemctl --failed
    log_message "${GREEN}Health check complete—everything looks good!${NC}"
}

# Backup System
backup_system() {
    log_message "${GREEN}Backing up your home directory...${NC}"
    BACKUP_DIR=~/backups/$(date +'%Y-%m-%d_%H%M%S')
    mkdir -p "$BACKUP_DIR" || { log_message "${RED}Failed to create backup directory.${NC}"; return 1; }
    tar -czvf "$BACKUP_DIR/home_backup.tar.gz" ~ --exclude="$BACKUP_DIR" || { log_message "${RED}Backup failed.${NC}"; return 1; }
    log_message "${GREEN}Backup saved to $BACKUP_DIR/home_backup.tar.gz—safe and sound!${NC}"
}

# Manage Flatpaks
manage_flatpaks() {
    log_message "${GREEN}Flatpak Management Options:${NC}"
    echo "1) List Installed Flatpaks"; echo "2) Uninstall a Flatpak"; echo "3) Update Flatpaks"
    read -p "Choose an option: " choice
    case $choice in
        1) flatpak list ;;
        2) read -p "Enter the Flatpak ID to uninstall: " flatpak_id; flatpak uninstall "$flatpak_id" -y || log_message "${RED}Failed to uninstall Flatpak $flatpak_id.${NC}" ;;
        3) flatpak update -y || log_message "${RED}Flatpak update failed.${NC}" ;;
        *) log_message "${RED}Invalid option—please try again.${NC}" ;;
    esac
}

# Manage Cron Jobs
manage_cron_jobs() {
    log_message "${GREEN}Cron Job Management:${NC}"
    echo "1) View Current Cron Jobs"; echo "2) Remove a Cron Job"
    read -p "Choose an option: " choice
    case $choice in
        1) crontab -l ;;
        2) echo "Current Cron Jobs:"; crontab -l | nl; read -p "Enter the line number to remove: " line; crontab -l | sed "${line}d" | crontab -; log_message "${GREEN}Cron job removed successfully.${NC}" ;;
        *) log_message "${RED}Invalid option—please try again.${NC}" ;;
    esac
}

# Disk Cleanup
disk_cleanup() {
    log_message "${GREEN}Cleaning up your disk...${NC}"
    apt autoclean -y || log_message "${YELLOW}APT autoclean failed.${NC}"
    apt autoremove -y || log_message "${YELLOW}APT autoremove failed.${NC}"
    rm -rf ~/.cache/* || log_message "${YELLOW}Cache cleanup failed.${NC}"
    journalctl --vacuum-time=30d || log_message "${YELLOW}Journal cleanup failed.${NC}"
    log_message "${GREEN}Disk cleanup done—your system feels lighter!${NC}"
}

# Security Checks
security_checks() {
    log_message "${GREEN}Running security checks...${NC}"
    log_message "Firewall Status:"; ufw status || log_message "${YELLOW}UFW not installed.${NC}"
    log_message "Open Ports:"; ss -tuln || netstat -tuln
    log_message "World-Writable Files:"; find / -xdev -type f -perm -o+w -print 2>/dev/null | head -n 10
    log_message "${GREEN}Security checks completed—your system’s looking secure!${NC}"
}

# Install and Configure Apps
install_and_configure_apps() {
    log_message "${GREEN}Let’s install some apps...${NC}"
    if [ ${COMMANDS[flatpak]} -eq 0 ]; then
        read -p "Flatpak is not installed. Install it? (y/N): " install_flatpak
        if [[ $install_flatpak =~ ^[Yy]$ ]]; then
            apt install -y flatpak || { log_message "${RED}Failed to install Flatpak.${NC}"; return 1; }
            flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        fi
    fi
    for cmd in wget unzip curl; do
        if ! command -v $cmd >/dev/null 2>&1; then
            apt install -y $cmd || { log_message "${RED}Failed to install $cmd.${NC}"; return 1; }
        fi
    done
    while true; do
        clear
        log_message "Select an app to install and configure:"
        options=(
            "Brave" "BleachBit" "Cryptomator" "Element" "GIMP" "Grayjay" "Jitsi Meet" "KeepassXC"
            "LibreWolf" "Nextcloud Client" "Obsidian" "Proton Pass" "Proton VPN" "Shortwave"
            "Signal" "Standard Notes" "Syncthing" "Terminator" "Thunderbird" "Tor Browser"
            "VLC" "VScodium" "Back to Main Menu"
        )
        select opt in "${options[@]}"; do
            case $opt in
                "Brave")
                    log_message "Installing Brave..."
                    if dpkg -l | grep -q brave-browser; then
                        log_message "Brave already installed."
                    else
                        curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
                        echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
                        update_apt
                        apt install -y brave-browser || log_message "${RED}Brave installation failed.${NC}"
                        log_message "Brave installed. Disable Brave Rewards in settings for max privacy."
                    fi
                    [ $SILENT_MODE -eq 0 ] && read -p "Press Enter to continue..."
                    break
                    ;;
                "BleachBit")
                    log_message "Installing BleachBit..."
                    if dpkg -l | grep -q bleachbit; then
                        log_message "BleachBit already installed."
                    else
                        apt install -y bleachbit || log_message "${RED}BleachBit installation failed.${NC}"
                        log_message "BleachBit installed. Run 'bleachbit' and enable shredding."
                    fi
                    [ $SILENT_MODE -eq 0 ] && read -p "Press Enter to continue..."
                    break
                    ;;
                "Cryptomator")
                    log_message "Installing Cryptomator..."
                    if flatpak list | grep -q org.cryptomator.Cryptomator; then
                        log_message "Cryptomator already installed."
                    else
                        flatpak install -y flathub org.cryptomator.Cryptomator || log_message "${RED}Cryptomator installation failed.${NC}"
                        log_message "Cryptomator installed. Create an encrypted vault."
                    fi
                    [ $SILENT_MODE -eq 0 ] && read -p "Press Enter to continue..."
                    break
                    ;;
                "Element")
                    log_message "Installing Element..."
                    if flatpak list | grep -q im.riot.Riot; then
                        log_message "Element already installed."
                    else
                        flatpak install -y flathub im.riot.Riot || log_message "${RED}Element installation failed.${NC}"
                        log_message "Element installed. Sign in or create a Matrix account."
                    fi
                    [ $SILENT_MODE -eq 0 ] && read -p "Press Enter to continue..."
                    break
                    ;;
                "GIMP")
                    log_message "Installing GIMP..."
                    if dpkg -l | grep -q gimp; then
                        log_message "GIMP already installed."
                    else
                        apt install -y gimp || log_message "${RED}GIMP installation failed.${NC}"
                        log_message "GIMP installed."
                    fi
                    [ $SILENT_MODE -eq 0 ] && read -p "Press Enter to continue..."
                    break
                    ;;
                "Grayjay")
                    log_message "Installing Grayjay..."
                    install_dir="$HOME/.local/opt/Grayjay"
                    if [ -f "$install_dir/Grayjay" ]; then
                        read -p "Grayjay is already installed at $install_dir. Overwrite? (y/N): " overwrite
                        if [[ ! "$overwrite" =~ ^[Yy]$ ]]; then
                            log_message "Installation skipped."
                            [ $SILENT_MODE -eq 0 ] && read -p "Press Enter to continue..."
                            break
                        fi
                        rm -rf "$install_dir"
                    fi
                    wget "https://updater.grayjay.app/Apps/Grayjay.Desktop/Grayjay.Desktop-linux-x64.zip" -O /tmp/Grayjay.zip || {
                        log_message "${RED}Download failed.${NC}"
                        break
                    }
                    unzip /tmp/Grayjay.zip -d /tmp/Grayjay-tmp || {
                        log_message "${RED}Extraction failed.${NC}"
                        rm -f /tmp/Grayjay.zip
                        break
                    }
                    version_dir=$(ls /tmp/Grayjay-tmp | grep "Grayjay.Desktop-linux-x64")
                    mkdir -p "$install_dir"
                    mv /tmp/Grayjay-tmp/"$version_dir"/* "$install_dir" || {
                        log_message "${RED}Failed to move files.${NC}"
                        rm -rf /tmp/Grayjay-tmp /tmp/Grayjay.zip
                        break
                    }
                    chmod +x "$install_dir/Grayjay"
                    mkdir -p "$HOME/.local/bin"
                    cat > "$HOME/.local/bin/grayjay" << EOL
#!/bin/bash
cd $install_dir && ./Grayjay
EOL
                    chmod +x "$HOME/.local/bin/grayjay"
                    rm -f /usr/local/bin/grayjay
                    mkdir -p "$HOME/.local/share/applications"
                    cat > "$HOME/.local/share/applications/grayjay.desktop" << EOL
[Desktop Entry]
Name=Grayjay
Exec=$HOME/.local/bin/grayjay
Icon=$install_dir/grayjay.png
Type=Application
Terminal=false
EOL
                    chmod +x "$HOME/.local/share/applications/grayjay.desktop"
                    rm -rf /tmp/Grayjay.zip /tmp/Grayjay-tmp || log_message "${YELLOW}Cleanup failed.${NC}"
                    log_message "Grayjay installed in $install_dir. Launch from menu or 'grayjay'."
                    [ $SILENT_MODE -eq 0 ] && read -p "Press Enter to continue..."
                    break
                    ;;
                "Jitsi Meet")
                    log_message "Installing Jitsi Meet..."
                    if flatpak list | grep -q org.jitsi.jitsi-meet; then
                        log_message "Jitsi Meet already installed."
                    else
                        flatpak install -y flathub org.jitsi.jitsi-meet || log_message "${RED}Jitsi Meet installation failed.${NC}"
                        log_message "Jitsi Meet installed. Start a meeting or join one directly."
                    fi
                    [ $SILENT_MODE -eq 0 ] && read -p "Press Enter to continue..."
                    break
                    ;;
                "KeepassXC")
                    log_message "Installing KeepassXC..."
                    if dpkg -l | grep -q keepassxc; then
                        log_message "KeepassXC already installed."
                    else
                        apt install -y keepassxc || log_message "${RED}KeepassXC installation failed.${NC}"
                        log_message "KeepassXC installed. Create a new database with a strong password."
                    fi
                    [ $SILENT_MODE -eq 0 ] && read -p "Press Enter to continue..."
                    break
                    ;;
                "LibreWolf")
                    log_message "Installing LibreWolf..."
                    if command -v librewolf >/dev/null 2>&1; then
                        log_message "LibreWolf already installed."
                    else
                        apt install -y software-properties-common
                        add-apt-repository -y ppa:intika/librewolf
                        apt update
                        apt install -y librewolf || log_message "${RED}LibreWolf installation failed.${NC}"
                        wget "https://raw.githubusercontent.com/vomxy/user.js/master/user.js" -O ~/librewolf.user.js
                        profile_dir=$(find ~/.librewolf -maxdepth 1 -type d -name "*.default-release" | head -n 1)
                        if [ -n "$profile_dir" ]; then
                            cp ~/librewolf.user.js "$profile_dir/user.js"
                            log_message "Privacy-focused user.js applied to $profile_dir."
                        fi
                        rm ~/librewolf.user.js
                        log_message "LibreWolf installed with enhanced privacy settings."
                    fi
                    [ $SILENT_MODE -eq 0 ] && read -p "Press Enter to continue..."
                    break
                    ;;
                "Nextcloud Client")
                    log_message "Installing Nextcloud Client..."
                    if dpkg -l | grep -q nextcloud-desktop; then
                        log_message "Nextcloud Client already installed."
                    else
                        apt install -y nextcloud-desktop || log_message "${RED}Nextcloud Client installation failed.${NC}"
                        log_message "Nextcloud Client installed. Connect to your Nextcloud server."
                    fi
                    [ $SILENT_MODE -eq 0 ] && read -p "Press Enter to continue..."
                    break
                    ;;
                "Obsidian")
                    log_message "Installing Obsidian..."
                    if flatpak list | grep -q md.obsidian.Obsidian; then
                        log_message "Obsidian already installed."
                    else
                        flatpak install -y flathub md.obsidian.Obsidian || log_message "${RED}Obsidian installation failed.${NC}"
                        log_message "Obsidian installed. Create a local vault and disable telemetry."
                    fi
                    [ $SILENT_MODE -eq 0 ] && read -p "Press Enter to continue..."
                    break
                    ;;
                "Proton Pass")
                    log_message "Installing Proton Pass..."
                    if dpkg -l | grep -q proton-pass; then
                        log_message "Proton Pass already installed."
                    else
                        wget "https://proton.me/download/pass/linux/proton-pass_1.29.3_amd64.deb" -O ~/proton-pass.deb
                        dpkg -i ~/proton-pass.deb
                        apt-get install -f -y
                        rm ~/proton-pass.deb
                        log_message "Proton Pass installed. Sign in with your Proton account."
                    fi
                    [ $SILENT_MODE -eq 0 ] && read -p "Press Enter to continue..."
                    break
                    ;;
                "Proton VPN")
                    log_message "Installing Proton VPN..."
                    if dpkg -l | grep -q protonvpn; then
                        log_message "Proton VPN already installed."
                    else
                        wget "https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.3_all.deb" -O ~/protonvpn.deb
                        dpkg -i ~/protonvpn.deb
                        apt update
                        apt install -y protonvpn || log_message "${RED}Proton VPN installation failed.${NC}"
                        rm ~/protonvpn.deb
                        log_message "Proton VPN installed. Log in and enable the kill switch."
                    fi
                    [ $SILENT_MODE -eq 0 ] && read -p "Press Enter to continue..."
                    break
                    ;;
                "Shortwave")
                    log_message "Installing Shortwave..."
                    if flatpak list | grep -q de.haeckerfelix.Shortwave; then
                        log_message "Shortwave already installed."
                    else
                        flatpak install -y flathub de.haeckerfelix.Shortwave || log_message "${RED}Shortwave installation failed.${NC}"
                        log_message "Shortwave installed. Add your favorite stations."
                    fi
                    [ $SILENT_MODE -eq 0 ] && read -p "Press Enter to continue..."
                    break
                    ;;
                "Signal")
                    log_message "Installing Signal..."
                    if dpkg -l | grep -q signal-desktop; then
                        log_message "Signal already installed."
                    else
                        wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor | tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
                        echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' | sudo tee /etc/apt/sources.list.d/signal-xenial.list
                        apt update && apt install -y signal-desktop-beta || log_message "${RED}Signal installation failed.${NC}"
                        log_message "Signal installed. Link it to your phone for encrypted messaging."
                    fi
                    [ $SILENT_MODE -eq 0 ] && read -p "Press Enter to continue..."
                    break
                    ;;
                "Standard Notes")
                    log_message "Installing Standard Notes..."
                    if flatpak list | grep -q org.standardnotes.standardnotes; then
                        log_message "Standard Notes already installed."
                    else
                        flatpak install -y flathub org.standardnotes.standardnotes || log_message "${RED}Standard Notes installation failed.${NC}"
                        log_message "Standard Notes installed. Sign in to sync your encrypted notes."
                    fi
                    [ $SILENT_MODE -eq 0 ] && read -p "Press Enter to continue..."
                    break
                    ;;
                "Syncthing")
                    log_message "Installing Syncthing..."
                    if dpkg -l | grep -q syncthing; then
                        log_message "Syncthing already installed."
                    else
                        apt install -y syncthing || log_message "${RED}Syncthing installation failed.${NC}"
                        systemctl enable syncthing@$USER.service
                        systemctl start syncthing@$USER.service
                        log_message "Syncthing installed. Access it at http://localhost:8384 to configure."
                    fi
                    [ $SILENT_MODE -eq 0 ] && read -p "Press Enter to continue..."
                    break
                    ;;
                "Terminator")
                    log_message "Installing Terminator..."
                    if dpkg -l | grep -q terminator; then
                        log_message "Terminator already installed."
                    else
                        apt install -y terminator || log_message "${RED}Terminator installation failed.${NC}"
                        log_message "Terminator installed. Right-click to split terminals."
                    fi
                    [ $SILENT_MODE -eq 0 ] && read -p "Press Enter to continue..."
                    break
                    ;;
                "Thunderbird")
                    log_message "Installing Thunderbird..."
                    if dpkg -l | grep -q thunderbird; then
                        log_message "Thunderbird already installed."
                    else
                        apt install -y thunderbird || log_message "${RED}Thunderbird installation failed.${NC}"
                        log_message "Thunderbird installed. Configure your email and disable telemetry."
                    fi
                    [ $SILENT_MODE -eq 0 ] && read -p "Press Enter to continue..."
                    break
                    ;;
                "Tor Browser")
                    log_message "Installing Tor Browser..."
                    if dpkg -l | grep -q torbrowser-launcher; then
                        log_message "Tor Browser already installed."
                    else
                        apt install -y torbrowser-launcher || log_message "${RED}Tor Browser installation failed.${NC}"
                        torbrowser-launcher & # Launch to download and install
                        log_message "Tor Browser installed. Set security level to 'Safest'."
                    fi
                    [ $SILENT_MODE -eq 0 ] && read -p "Press Enter to continue..."
                    break
                    ;;
                "VLC")
                    log_message "Installing VLC..."
                    if dpkg -l | grep -q vlc; then
                        log_message "VLC already installed."
                    else
                        apt install -y vlc || log_message "${RED}VLC installation failed.${NC}"
                        log_message "VLC installed. Disable network access in preferences for privacy."
                    fi
                    [ $SILENT_MODE -eq 0 ] && read -p "Press Enter to continue..."
                    break
                    ;;
                "VScodium")
                    log_message "Installing VScodium..."
                    if flatpak list | grep -q com.vscodium.codium; then
                        log_message "VScodium already installed."
                    else
                        flatpak install -y flathub com.vscodium.codium || log_message "${RED}VScodium installation failed.${NC}"
                        mkdir -p ~/.config/VSCodium/User
                        echo '{"telemetry.enableTelemetry": false}' > ~/.config/VSCodium/User/settings.json
                        log_message "VScodium installed with telemetry disabled. Add extensions as needed."
                    fi
                    [ $SILENT_MODE -eq 0 ] && read -p "Press Enter to continue..."
                    break
                    ;;
                "Back to Main Menu")
                    return
                    ;;
                *)
                    log_message "${RED}Invalid option—please try again.${NC}"
                    ;;
            esac
        done
    done
}

# Parse Command-Line Arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --silent) SILENT_MODE=1; shift ;;
        --log-file=*) LOG_FILE="${1#*=}"; shift ;;
        *) log_message "${RED}Unknown option: $1${NC}"; exit 1 ;;
    esac
done

# Main Menu
if [ $SILENT_MODE -eq 0 ]; then
    while true; do
        clear
        log_message "Welcome to your Pop!_OS Maintenance Toolbox"
        echo "Please select an option:"
        options=(
            "Apply All Updates" "Config New Install" "System Health Check" "Backup System"
            "Manage Flatpaks" "Manage Cron Jobs" "Disk Cleanup"
            "Install and Configure Apps"
            "Security Checks" "Exit"
        )
        select opt in "${options[@]}"; do
            case $opt in
                "Apply All Updates") apply_updates; [ $SILENT_MODE -eq 0 ] && read -p "Press Enter to continue..."; break ;;
                "Config New Install") config_new_install; [ $SILENT_MODE -eq 0 ] && read -p "Press Enter to continue..."; break ;;
                "System Health Check") check_system_health; [ $SILENT_MODE -eq 0 ] && read -p "Press Enter to continue..."; break ;;
                "Backup System") backup_system; [ $SILENT_MODE -eq 0 ] && read -p "Press Enter to continue..."; break ;;
                "Manage Flatpaks") manage_flatpaks; [ $SILENT_MODE -eq 0 ] && read -p "Press Enter to continue..."; break ;;
                "Manage Cron Jobs") manage_cron_jobs; [ $SILENT_MODE -eq 0 ] && read -p "Press Enter to continue..."; break ;;
                "Disk Cleanup") disk_cleanup; [ $SILENT_MODE -eq 0 ] && read -p "Press Enter to continue..."; break ;;
                "Install and Configure Apps") install_and_configure_apps; break ;;
                "Security Checks") security_checks; [ $SILENT_MODE -eq 0 ] && read -p "Press Enter to continue..."; break ;;
                "Exit") log_message "${GREEN}Thanks for using the toolbox—see you next time!${NC}"; exit 0 ;;
                *) log_message "${RED}Invalid option—please try again.${NC}" ;;
            esac
        done
    done
else
    log_message "${GREEN}Running silently in the background...${NC}"
    apply_updates
    disk_cleanup
    security_checks
    backup_system
    log_message "${GREEN}Silent maintenance done—your system’s all set!${NC}"
fi