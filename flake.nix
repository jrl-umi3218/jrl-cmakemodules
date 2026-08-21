{
  description = "CMake utility toolbox";

  inputs.gepetto.url = "github:gepetto/nix";

  outputs =
    inputs:
    inputs.gepetto.lib.mkFlakoboros inputs (
      { lib, ... }:
      {
        overrideAttrs = {
          jrl-cmakemodules = { pkgs-final, drv-prev, ... }: {
            src = lib.fileset.toSource {
              root = ./.;
              fileset = lib.fileset.gitTracked ./.;
            };
            cmakeFlags = drv-prev.cmakeFlags ++ [
              (lib.cmakeBool "JRL_CMAKEMODULES_ENABLE_TEST_CPPAD" true)
              (lib.cmakeBool "JRL_CMAKEMODULES_ENABLE_TEST_CPPADCG" true)
              (lib.cmakeBool "JRL_CMAKEMODULES_ENABLE_TEST_GMP" true)
              (lib.cmakeBool "JRL_CMAKEMODULES_ENABLE_TEST_MPFR" true)
            ];
            checkInputs = drv-prev.checkInputs ++ [
              pkgs-final.cppad
              pkgs-final.cppadcodegen
              pkgs-final.gmp
              pkgs-final.mpfr
            ];
          };
          jrl-cmakemodules-scripts = { pkgs-final, drv-prev, ... }: {
            nativeBuildInputs = drv-prev.nativeBuildInputs ++ [
              pkgs-final.git
            ];
          };
        };
      }
    );
}
