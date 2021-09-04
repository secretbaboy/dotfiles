Pre-requisites:
- Change New NixOS VM root passwd.
- Another Linux machine with make. 
- Run Makefile on that Linux machine as root.
- Put configuration.nix and hardware-configuration.nix in /code/nix-config/machines/

Step 1:
make NIXADDR="X.X.X.X" vm/bootstrap0

Step 1:
make NIXADDR="X.X.X.X" vm/bootstrap

