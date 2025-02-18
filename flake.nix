{
  description = "CMake utility toolbox";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = inputs.nixpkgs.lib.systems.flakeExposed;
      perSystem =
        { pkgs, self', ... }:
        {
          packages = {
            default = self'.packages.jrl-cmakemodules;
            jrl-cmakemodules = pkgs.jrl-cmakemodules.overrideAttrs (super: {
              src = pkgs.lib.fileset.toSource {
                root = ./.;
                fileset = pkgs.lib.fileset.gitTracked ./.;
              };

              # TODO: remove all this once it is in nixpkgs
              postPatch = ''
                patchShebangs _unittests/run_unit_tests.sh
              '';

              outputs = [ "out" "doc" ];
              nativeBuildInputs = super.nativeBuildInputs ++ [
                pkgs.sphinxHook
              ];
              sphinxRoot = "../.docs";

              doCheck = true;
              checkInputs = [
                pkgs.python3
              ];
              checkPhase = ''
                runHook preCheck

                pushd ../_unittests
                ./run_unit_tests.sh
                cmake -P test_pkg-config.cmake

                rm -rf build install
                popd

                runHook postCheck
              '';
            });
          };
        };
    };
}
