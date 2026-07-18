#! /bin/bash
echo "############   Installing Updates and Common Tools###############"
echo "############       This will take some time...    ###############"

if command -v dnf &>/dev/null; then
    sudo dnf --enablerepo=extras install epel-release -y > commontools.log 2>&1
    sudo dnf update -y
    sudo dnf install htop screen iftop wget zip unzip ntfs-3g nano mc net-tools curl nfs-utils tar links bind-utils iputils traceroute whois nmap openssl -y

    # dnf update above may have installed a newer kernel without booting
    # into it. Packages like kernel-modules-extra (xt_addrtype, etc.) only
    # get pulled for the newest installed kernel, so anything relying on a
    # module missing from the still-running old kernel (e.g. Docker's
    # iptables NAT rules) will fail until a reboot.
    latest_kernel=$(rpm -q kernel --last 2>/dev/null | head -1 | awk '{print $1}')
    latest_kernel=${latest_kernel#kernel-}
    if [[ -n "$latest_kernel" && "$latest_kernel" != "$(uname -r)" ]]; then
        echo "NOTE: kernel $latest_kernel is installed but not running (currently: $(uname -r))."
        echo "A reboot is recommended before relying on new kernel modules (e.g. before running docker.sh)."
    fi
elif command -v apt &>/dev/null; then
    sudo apt update -y
    sudo apt install htop screen iftop wget zip unzip ntfs-3g nano mc net-tools curl nfs-common tar links bsdmainutils dnsutils iputils-ping traceroute whois nmap openssl -y
    sudo apt upgrade -y
else
    echo "Unsupported package manager. Skipping package installation."
fi

git config --global credential.helper "cache --timeout=86400"
