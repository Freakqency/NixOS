# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "mayhem"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.

  networking.networkmanager = {
    enable = true;
    ensureProfiles = {
      # Points to your secure file containing the variables
      environmentFiles = [ "/home/surya/NixOS/hosts/mayhem/wifi.env" ];

      profiles = {
        "home-wifi" = {
          connection = {
            id = "home-wifi";
            type = "wifi";
            interface-name = "wlo1";
            autoconnect = true;
            autoconnect-priority = 100;
          };
          wifi = {
            ssid = "$HOME_SSID";
          };
          wifi-security = {
            key-mgmt = "wpa-psk";
            psk = "$HOME_PSK";
          };
          ipv4 = {
            method = "manual";
            address1 = "192.168.1.10/24";
            gateway = "192.168.1.254";
            dns = "192.168.1.254;1.1.1.1;";
          };
        };
      };
    };
  };

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.surya = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "sudo"
    ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
      vim
      podman
      qemu
      usbutils
      unzip
    ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDjzmLn70tqYoirv6hSs0W6gV4U+D5RF5fWMKd5KjSA88zYgqtr1HHpW1Gqg3grvY1sEuZuiYwtOsxvuGtoSTyL3PvjtxoVqWXQIsj0VgmTGf0zuJ6iWUmL8vy9oZ5sICtCgapq+NzbLIo4cbE4CbqpZxeWVHGY4jkj1AiUTJF0am5cLl30TVkUf8YuWIZ0bxrd9mavZWDan8intXM/pqu1yjJGc/WjQSR7dQx+ABhzdkvWcQFZmcHqZBwTkpaV823M7mLH3qcVqMPS2qsw4ToNhv8MYsNv3pPYYHcGK/loS2+PVjWKJv5kG6V1X2/VeyilQtQzAeBJM76ucGQMGuL5c2V7l0r1I/oA3ktjgx/fAC9qy4U0nCApYLJ8aXWZOl7fzit5OcxZkKl9fuqnuFiKiXSPlNoXQYEDmh89GU19kW0v0H7Z3xIwURjbEwxRszPwislQD9pEuBrMzeER/4hZpHJFUzFCalCl+xGbugD2MJ24HblOGWVBpC4xvcnULds= surya@MacBookAir.attlocal.net"
    ];
  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    extra-substituters = [ "https://cache.numtide.com" ];
    extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  services.tailscale.enable = true;

  virtualisation.podman = {
    enable = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  # Helps with some third-party binary compatibility.
  programs.nix-ld.enable = true;

  # programs.firefox.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages =
  let
    agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  in
  [
    agents.codex
    agents.claude-code
  ]
  ++ (with pkgs; [
    bun
    git
    nodejs_24
    gh
    gitleaks
    tmux
    jq
    ripgrep
    fd
    btop
    python3
    uv
  ]);


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  services.logind.settings.Login = {
      HandleSwitch = "ignore";
      HandleLidSwitchExternalPower = "ignore";
      HandleLidSwitchDocked = "ignore";
  };

  services.thermald.enable =  true;

  services.journald.extraConfig = ''
      SystemMaxUse = 1G
  '';

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?

  home-manager = {
    useGlobalPkgs = true;     # use the system's pkgs instead of building a second copy
    useUserPackages = true;   # install into /etc/profiles/per-user/surya, like users.users.*.packages
    users.surya = import ./home.nix;
  };

  zramSwap = {
      enable = true;
      memoryPercent = 50;
      algorithm = "zstd";
  };

}
