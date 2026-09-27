{
  pkgs,
  inputs,
  outputs,
  userConfig,
  hostname,
  ...
}:

{
  imports = [ ./theme.nix ];

  theme.name = "nord";

  fonts.packages = with pkgs; [
    fira-code
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.optimise.automatic = true;
  nix.gc.automatic = false;

  programs.fish.enable = true;
  environment.shells = [ pkgs.fish ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "bak";
    extraSpecialArgs = {
      inherit inputs outputs;
      userConfig = userConfig;
      hmModules = "${inputs.self}/modules/home-manager";
    };
    users.${userConfig.name} = import "${inputs.self}/home/${userConfig.name}/${hostname}";
  };
}
