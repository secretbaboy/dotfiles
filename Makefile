NIXADDR ="172.16.1.164"
NIXUSER ="kt"
MAKEFILE_DIR ="/code/nix_config/machines/"

vm/copy:
	rsync -avzhe ssh  \
		$(MAKEFILE_DIR) $(NIXUSER)@$(NIXADDR):/etc/nixos/; \

switch:
	sudo nixos-rebuild switch

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
			\  boot.loader.grub.device = \"/dev/sda/\";\n \
			\  services.openssh.enable = true;\n \
			\  services.openssh.passwordAuthentication = true;\n \
			\  services.openssh.permitRootLogin = \"yes\";\n \
			\  users.users.root.initialPassword = \"root\";\n \
			\  users.users.$(NIXUSER).isNormalUser = true;\n \
			\  users.users.$(NIXUSER).home = \"/home/kt\" ;\n \
			\  users.users.$(NIXUSER).extraGroups = \[\"wheel\"\];\n \
		' /mnt/etc/nixos/configuration.nix; \
		nixos-install --no-root-passwd; \
		reboot; \
	"

vm/bootstrap:
	ssh root@$(NIXADDR) " \
		nix-channel --add \
			https://github.com/nix-community/home-manager/archive/release-21.05.tar.gz home-manager; \
		nix-channel --update; \
	"
	$(MAKE) vm/copy
	ssh $(NIXUSER)@$(NIXADDR) " \
		sudo reboot; \
	"
