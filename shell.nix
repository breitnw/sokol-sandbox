let
  pkgs = import <nixpkgs> { };
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
      rev = "339ff0314f19414c248cd540b7c72de1873f3a4b";
      hash = "sha256-VkDdHsEpTII75vstFATc505d8SJ6XuKPqd3hS3txuJY=";
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
    sokol
    alsa-lib.dev
    libGL.dev
    xorg.libX11.dev
    xorg.libXi.dev
    xorg.libXcursor.dev

    # sokol tools, for compiling shaders
    sokol-tools-bin
  ];
  LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath (buildInputs ++ nativeBuildInputs);
  CPATH = pkgs.lib.makeSearchPathOutput "dev" "include" buildInputs;
}
