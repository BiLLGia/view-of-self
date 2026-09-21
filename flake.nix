{
  description = "Build you resume with markdown";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let

        pkgs = import nixpkgs {
          inherit system;
        };

        buildInputs = with pkgs; [
          pandoc
          python3Packages.weasyprint
        ];

        buildPhase = ''
          pandoc resume.md \
          -t html -f markdown \
          -c resume-stylesheet.css --embed-resources --standalone \
          -o resume.html

          pandoc resume.md \
          -t pdf -f markdown \
          --pdf-engine=weasyprint \
          -c resume-stylesheet.css \
          -o resume.pdf
        '';

      in with pkgs; {

        packages = {
          default = stdenvNoCC.mkDerivation {
            inherit buildInputs buildPhase;
            name = "resume_md";
            src = ./.;
            installPhase = ''
              mkdir -p $out/resume
              cp resume.* $out/resume/
            '';
          };
        };

        checks = {
          default = stdenvNoCC.mkDerivation {
            inherit buildInputs buildPhase;
            name = "resume-md checks";
            src = ./.;
            installPhase = ''
              mkdir -p $out
            '';
          };
        };

        devShell = mkShell {
          inherit buildInputs;
        };
      });
}
