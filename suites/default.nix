{ lib }:
let
  inherit (builtins) mapAttrs isFunction;
  inherit (lib.flk) importDefaults;

  profiles = importDefaults (toString ../profiles);
  users = importDefaults (toString ../users);

  allProfiles =
    let
      sansCore = lib.filterAttrs (n: _: n != "core") profiles;
    in
    lib.collect isFunction sansCore;

  allUsers = lib.collect isFunction users;


  suites = with profiles; rec {
    boot = [ efi-grub ];
    core = [ users.root users.pachums usb ] ++ boot;
    graphics = [ printing xorg graphical gnome ];
    develop = [ shell nix-builder ];
    sensors = [ location bluetooth sound ];
    desktop = core ++ graphics ++ develop ++ sensors;
  };
in
mapAttrs (_: v: lib.flk.profileMap v) suites // {
  inherit allProfiles allUsers;
}
