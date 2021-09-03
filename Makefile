NIXADDR =""
vm/bootstrap0:
        ssh root@$(NIXADDR) " \
                parted /dev/sda -- mklabel msdos; \
                parted /dev/sda -- mkpart primary 1MiB -8GiB; \
                parted /dev/sda -- mkpart primary linux-swap -8GiB 100\%; \
                mkfs.ext4 -L nixos /dev/sda1; \
                mkswap -L swap /dev/sda2; \
                mount /dev/disk/by-label/nixos /mnt; \
                swapon /dev/sda2; \
                nixos-generate-config --root /mnt; \
                sed --in-place '/system\.stateVersion = .*/ a \
                        \  boot\.loader\.grub\.device = \"/dev/sda/\";\n \
                        \  services.openssh.enable = true;\n \
                        \  services.openssh.passwordAuthentication = true;\n \
                        \  services.openssh.permitRootLogin = \"yes\";\n \
                        \  users.users.root.initialPassword = \"root\";\n \
                ' /mnt/etc/nixos/configuration.nix; \
                nixos-install --no-root-passwd; \
                reboot; \
        "
