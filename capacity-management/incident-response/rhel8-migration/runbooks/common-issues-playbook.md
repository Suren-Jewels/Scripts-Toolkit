# Common Issues Playbook (RHEL8 Migration)

## Boot Issues
- GRUB missing → Reinstall GRUB  
- Kernel panic → Rebuild initramfs  
- Wrong kernel version → Update GRUB config  

## Network Issues
- NIC not detected → Install correct drivers  
- No IP → Restore ifcfg-* files  
- DNS failures → Fix resolv.conf  

## Service Issues
- Unit fails to start → Check systemctl status  
- Config errors → Validate syntax  
- SELinux denials → Review AVC logs  

## Application Issues
- Missing dependencies → Install required packages  
- Python version mismatch → Use virtualenv  
- Library path issues → Update LD_LIBRARY_PATH  
