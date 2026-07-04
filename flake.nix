{
  description = "CMake utility toolbox";

  inputs.gepetto.url = "github:gepetto/nix";

  outputs =
    inputs:
    inputs.gepetto.lib.mkFlakoboros inputs (
      { lib, ... }:
      {
        pyPackages.cmake-parser =
          {
            buildPythonPackage,
            setuptools,
            setuptools-scm,
            fetchPypi,
            attrs,
            ...
          }:
          buildPythonPackage rec {
            pname = "cmake_parser";
            version = "0.9.2";
            pyproject = true;

            build-system = [
              setuptools
              setuptools-scm
            ];
            dependencies = [ attrs ];

            src = fetchPypi {
              inherit pname version;
              hash = "sha256-t6MT0/QeWMCeCIbyyY8/zuKxiX/n+HRJgjpT5RqyOj0=";
            };
          };

        pyPackages.jrl-release =
          {
            buildPythonPackage,
            cmake-parser,
            uv-build,
            setuptools,
            tomlkit,
            ruamel-yaml,
            rich,
            packaging,
            ...
          }:
          buildPythonPackage {
            inherit ((lib.importTOML ./v2/scripts/pyproject.toml).project) name version;
            pyproject = true;

            src = lib.cleanSource ./v2/scripts;

            build-system = [
              uv-build
              setuptools
            ];

            dependencies = [
              tomlkit
              ruamel-yaml
              rich
              packaging
              cmake-parser
            ];
            meta = {
              mainProgram = "jrl-release";
            };
          };

        overrideAttrs.jrl-cmakemodules =
          { pkgs-final, ... }:
          {
            patches = [ ];
            cmakeFlags = [
              (lib.cmakeBool "JRL_CMAKEMODULES_GENERATE_API_DOC" true)
              (lib.cmakeBool "JRL_CMAKEMODULES_BUILD_TESTS" true)
            ];
            doCheck = true;
            checkInputs = [
              pkgs-final.catch2_3
              pkgs-final.matio
              pkgs-final.python3Packages.boost
              pkgs-final.python3Packages.nanobind
              pkgs-final.python3Packages.numpy
              pkgs-final.python3Packages.pytest
              pkgs-final.simde
              pkgs-final.suitesparse
            ];
            src = lib.fileset.toSource {
              root = ./.;
              fileset = lib.fileset.gitTracked ./.;
            };
          };
      }
    );
}
