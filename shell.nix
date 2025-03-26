let
  pkgs = import <nixpkgs> { };

  # SOKOL-OVERRIDE: Up-to-date override for sokol headers.
  sokol-override = (pkgs.sokol.overrideAttrs {
    src = pkgs.fetchFromGitHub {
      owner = "floooh";
      repo = "sokol";
      rev = "bcdf25ae58c4fe82cd444ea1ce3f1b8f2532c7ed";
      sha256 = "sha256-UxwDs5VOAP2smbPjpopGTcFWblqOixwZ0owayWWUDko=";
    };
  });

  # DCIMGUI: All in one Dear ImGui source distro for C++ and C.
  dcimgui = pkgs.stdenv.mkDerivation {
    pname = "dcimgui";
    version = "1.91.9";
    src = pkgs.fetchFromGitHub {
      owner = "floooh";
      repo = "dcimgui";
      rev = "3969c14f7c7abda0e4b59d2616b17b7fb9eb0827";
      sha256 = "sha256-6raw9CEwTFoo9QF72aQsnGQCL3IF76WRkECZdqKBjfQ=";
    };
    buildInputs = with pkgs; [ cmake ];
    buildPhase = ''
      cmake .
      make
    '';
    installPhase = ''
      mkdir $out
      mkdir $out/lib
      mkdir $out/include
      cp ../src/cimgui.h $out/include
      cp ../src/imconfig.h $out/include
      cp libimgui.a $out/lib
      cp libimgui-docking.a $out/lib
    '';
  };

  # HANDMADEMATH: A simple math library for games and computer graphics.
  HandmadeMath = pkgs.stdenv.mkDerivation {
    pname = "HandmadeMath";
    version = "2.0.0";
    src = pkgs.fetchFromGitHub {
      owner = "HandmadeMath";
      repo = "HandmadeMath";
      rev = "422bc588e9e8ae580f472f05e47c01a646acff38";
      sha256 = "sha256-hmQXZRqgJOztvqmekRRnuF8bjPF3ZczKDfCVZv4aDvY=";
    };
    installPhase = ''
      mkdir $out
      mkdir $out/include
      cp HandmadeMath.h $out/include/
    '';
  };

  # SOKOL-TOOLS-BIN: Binaries for https://github.com/floooh/sokol-tools
  sokol-tools-bin = let
    directory = let
      directories = {
        aarch64-darwin = "osx_arm64";
        aarch64-linux = "linux_arm64";
        x86_64-darwin = "osx";
        x86_64-linux = "linux";
      };
    in directories.${pkgs.system};

  in pkgs.stdenv.mkDerivation {
    pname = "sokol-tools-bin";
    version = "1.0.0";
    src = pkgs.fetchFromGitHub {
      owner = "floooh";
      repo = "sokol-tools-bin";
      rev = "9b5a3e2b57fe9783ba4d1f3249059bc4720b592f";
      hash = "sha256-E9riz9zpkdpIejwWgAsLFP/u40U5kb1WohIDOPE7ycw";
    };
    nativeBuildInputs = [ pkgs.autoPatchelfHook ];

    installPhase = ''
      runHook preInstall
      mkdir $out
      mkdir $out/bin
      cp bin/${directory}/sokol-shdc $out/bin/sokol-shdc
      runHook postInstall
    '';
  };

  # Development shell with sokol and other dependencies
in pkgs.mkShell rec {
  nativeBuildInputs = with pkgs; [ pkg-config ];
  buildInputs = with pkgs; [
    # clangd and other tools
    llvmPackages.clang-tools

    # libraries
    sokol-override
    dcimgui
    HandmadeMath
    libGL.dev
    alsa-lib.dev
    xorg.libX11.dev
    xorg.libXi.dev
    xorg.libXcursor.dev

    # sokol tools, for compiling shaders
    sokol-tools-bin
  ];
  LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath (buildInputs ++ nativeBuildInputs);
}
