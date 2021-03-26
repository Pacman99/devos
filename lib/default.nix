args@{ nixos, self, ... }:
let inherit (nixos) lib; in
lib.makeExtensible (final:
  let callLibs = file: import file
    ({
      inherit lib;

      dev = final;
    } // args);
  in
  with final;
  {
    inherit callLibs;

    attrs = callLibs ./attrs.nix;
    os = callLibs ./devos;
    lists = callLibs ./lists.nix;
    strings = callLibs ./strings.nix;

    mkFlake = callLibs ./mkFlake;
    evalFlakeArgs = callLibs ./mkFlake/evalFlakeArgs.nix;

    inherit (attrs) mapFilterAttrs genAttrs' pathsToImportedAttrs concatAttrs;
    inherit (lists) pathsIn;
    inherit (strings) rgxToString;
  })
