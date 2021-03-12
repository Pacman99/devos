# override defaults to nixpkgs/master
{
  # modules to pull from override, stable version is automatically disabled
  modules = [ ];

  # if a modules name changed in override, add the old name here
  disabledModules = [ ];

  # packages pulled from override
  packages = pkgs: final: prev: {
    inherit (pkgs)
      discord
      element-desktop
      manix
      nixpkgs-fmt
      nixUnstable
      qutebrowser
      signal-desktop
      starship;

  };
}
