{ buildPackages, callPackage }:

{ rustc, cargo, ... }:

rec {
  rust = {
    inherit rustc cargo;
  };

  fetchCargoTarball = buildPackages.callPackage ../../../build-support/rust/fetchCargoTarball.nix {
    git = buildPackages.gitMinimal;
    inherit cargo;
  };

  buildRustPackage = callPackage ../../../build-support/rust {
    git = buildPackages.gitMinimal;
    inherit cargoBuildHook cargoCheckHook cargoInstallHook cargoSetupHook
      fetchCargoTarball rustc;
  };

  rustcSrc = callPackage ./rust-src.nix {
    inherit rustc;
  };

  rustLibSrc = callPackage ./rust-lib-src.nix {
    inherit rustc;
  };

  # Hooks
  inherit (callPackage ../../../build-support/rust/hooks {
    inherit cargo;
  }) cargoBuildHook cargoCheckHook cargoInstallHook cargoSetupHook maturinBuildHook;
}
