let
  pkgs = import <nixpkgs> { };

  sokol-new = (pkgs.sokol.overrideAttrs {
    src = pkgs.fetchFromGitHub {
      owner = "floooh";
      repo = "sokol";
      rev = "bcdf25ae58c4fe82cd444ea1ce3f1b8f2532c7ed";
      sha256 = "sha256-UxwDs5VOAP2smbPjpopGTcFWblqOixwZ0owayWWUDko=";
    };
  });

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

in pkgs.mkShell rec {
  nativeBuildInputs = with pkgs; [ pkg-config ];
  buildInputs = with pkgs; [
    # clangd and other tools
    llvmPackages.clang-tools

    # libraries
    sokol-new
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
