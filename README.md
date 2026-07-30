# linuxsetup

Personal collection of setup scripts for Debian/Ubuntu and RHEL-family
(AlmaLinux, Rocky, Fedora) hosts.

| Script | Purpose |
| --- | --- |
| `lib.sh` | Shared helper (`detect_pkg_mgr`), sourced by the other scripts — not run directly. |
| `commontools.sh` | Installs base CLI tools (htop, wget, nmap, etc.) and common updates. |
| `docker.sh` | Installs Docker CE + Compose plugin from Docker's official repo, optionally Portainer. |
| `kvm.sh` | Installs KVM/libvirt + Cockpit and bridges a network interface (`br0`) for VM guest networking. Reconfigures host networking — read the in-script warning before running over SSH. |
| `bash_profile_config.sh` | Adds a standard set of aliases/prompt to `~/.bashrc`, optionally Bitwarden SSH-agent integration. Safe to re-run (idempotent). |
| `swapcreate.sh` | Creates and enables a swapfile with sane sysctl tuning. |

All scripts detect apt vs. dnf automatically via `lib.sh` and only need to be
run once per host (most are idempotent; `kvm.sh` refuses to run if a `br0`
connection already exists).

## Deprecated

`deprecated/` holds scripts that are either specific to one personal machine
or superseded/broken and no longer maintained. See `deprecated/README.md` for
why each one is there. Don't run them without reviewing first.
