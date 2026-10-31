_:
{
  home.stateVersion = "26.05";

  programs.git = {
    enable = true;
    settings = {
      user.name = "Freakqency";
      user.email = "36022725+Freakqency@users.noreply.github.com";
      init.defaultBranch = "main";
      alias.st = "status";
      alias.lg = "log --oneline -3"
      alias.br = "branch"
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings."github-nixos" = {
      HostName = "github.com";
      User = "git";
      IdentityFile = "~/.ssh/nixos_deploy";
      IdentitiesOnly = "yes";
    };
  };

  home.file.".vimrc".source = ./vimrc;
}
