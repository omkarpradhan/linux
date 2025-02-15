# linux
Linux system settings, configurations, and customizations 

# Author 

Omkar Pradhan (omkarpradhan@gmail.com)

# Files
| Name | Desciption |
|------|------------|
|README.md| this document|
|config-gnome-desktop.sh|CLI for quickly configuring desktop settings|

<!-- # Folder tree -->

# System settings

## Power management

1. Battery charging threshold is controlled from BIOS -> press F2 during power on to enter BIOS settings. Threshold settings are not exposed to userspace
2. TLP is used to control various other hardware settings for power management
   Enable immediately with `tlp start` 
3. Service is called `tlp.service` and can controlled as usual with `systemctl`
4. Configuraiton files are `/etc/tlp.conf` or config. files in `/etc/tlp.d/`. Default config. is in `/usr/share/tlp/defaults.conf` which should not be changed
5. TLP settings can be interrogated with `tlp-stat`
6. Screen refresh rate can be lowerd (to 48 Hz) to reduce battery drain
   1. [] Add this feature (using DBUS interface) to TLP configurations

## Display settings

1. Lowering the refresh rate to 48 Hz seems to help with power consumption - done manually in settings
2. Default grub was also modified with line `GRUB_CMDLINE_LINUX_DEFAULT="quiet splash video=eDP-1:2256x1504@48"`. Not sure if this enforces persistence of this setting after power cycle

## Enabling deep sleep and hibernate

[Link to steps](https://luisartola.com/solving-the-framework-laptop-battery-drain/)

[source link](https://www.linuxuprising.com/2021/08/how-to-enable-hibernation-on-ubuntu.html)

[another link to steps](https://ubuntuhandbook.org/index.php/2021/08/enable-hibernate-ubuntu-21-10/#google_vignette)

### Swap file creationg/update
Disable and remove current swap file (if any) and create a new swap file (if not already present). Size of swap file should be >= RAM\

`sudo swapoff /[current-swap-file-name]`\
`sudo rm /[current-swap-file-name]`\
`dd if=/dev/zero of=swapfile bs=1M count=34816`\
`sudo chmod 600 /swapfile`\
`sudo mkswap /swapfile`\
`sudo swapon /swapfile`

### GRUB Configuration

1. Update the grub file in `/etc/default/grub` with the following addition to the existing `GRUB_CMDLINE_LINUX_DEFAULT`\

`GRUB_CMDLINE_LINUX_DEFAULT="quiet splash video=eDP-1:2256x1504@48 mem_sleep_default=deep resume=UUID=[partition-UUID] resume_offset=[physical-offset-of-swap-file]`

Note: Append to existing arguments\

2. The UUID found from\
`findmnt -no UUID -T /swapfile`

3. The physical offset is the 4th number in the output of\
`sudo filefrag -v /swapfile`

4. Now update GRUB and reboot
`sudo update-grub`\
`sudo reboot`

### Configure `initramfs`

1. Create or edit `etc/initramfs-tools/conf.d/resume` and add the following line

`resume=UUID=[partition-UUID] resume_offset=[physical-offset-of-swap-file]`

2. Update

`sudo update-initramfs -c -k all`
`sudo reboot`

### Disable Secure Boot

Disable secure boot in BIOS settings 

### Edit `fstab`

Edit `/etc/fstab` and add the following line at the end\

`/swapfile	none	swap	sw	0	0`

Swap file settings will now persist over reboots

### Use Hibernate or Suspend-then-hibernate

The services can  be enabled as\
`sudo systemctl hibernate`\
`sudo systemctl suspend-then-hibernate`\

Setup aliases for convenient commands