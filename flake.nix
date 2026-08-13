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
        # https://github.com/NixOS/nixpkgs/pull/390728
        packages.cppadcodegen =
          {
            stdenv,
            fetchFromGitHub,
            cmake,
            cppad,
            eigen,
          }:
          stdenv.mkDerivation (finalAttrs: {
            pname = "cppadcodegen";
            version = "2.5.0";

            src = fetchFromGitHub {
              owner = "joaoleal";
              repo = "CppADCodeGen";
              tag = "v${finalAttrs.version}";
              hash = "sha256-na8o+bqzign2nSk5AQdkIVQm3CIb0oFqEneGnYKQDyg=";
            };

            postPatch = ''
              substituteInPlace CMakeLists.txt --replace-fail \
                "ADD_SUBDIRECTORY(test EXCLUDE_FROM_ALL)" ""
            '';

            nativeBuildInputs = [
              cmake
            ];
            buildInputs = [
              cppad
              eigen
            ];
          });
      }
    );
}
