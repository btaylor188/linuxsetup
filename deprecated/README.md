# Deprecated

Archived, unmaintained, and no longer fixed. Kept for reference only — do not run
these without reviewing them first.

- **backup_script.sh** — hardcoded to one machine ("Sovereign": `/opt/docker` →
  `/mnt/Storage/Backup/Docker/Sovereign`). Not portable.
- **crontab.txt** — example crontab referencing `/opt/scripts/docker_backup.sh`,
  a path that doesn't match any script in this repo.
- **x11.sh** — runs both the `yum` and `apt` install blocks unconditionally on
  every host instead of detecting the distro; whichever package manager isn't
  present just fails loudly.
- **checkdockerratelimit.sh** — one-off diagnostic for Docker Hub pull rate
  limits, not part of the core setup flow.
- **cockpit_centos.sh** — has a syntax bug (`systemctl enable libvirtd --nowsudo`),
  uses obsolete `yum`, and mostly duplicates what `kvm.sh` already installs
  (cockpit, cockpit-machines, libvirt).
- **proxmox_repo.sh** — not idempotent (re-running turns `#deb` into `##deb` in
  `pve-enterprise.list`), and specific to Proxmox VE hosts.
