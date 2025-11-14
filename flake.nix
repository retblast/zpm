{
	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs";
		flake-utils.url = "github:numtide/flake-utils";

	};
	outputs = { self, nixpkgs, flake-utils }:
		flake-utils.lib.eachDefaultSystem (system: 
			let
				pkgs = nixpkgs.legacyPackages.${system};
			in {
				devShell = pkgs.mkShell {
					buildInputs = with pkgs; [
						zig
						zls
					];
				};
				#packages.default = pkgs.stdenv.mkDerivation {
				#	name = "glTest";
				#	src = ./test.cpp;
				#	buildInputs = with pkgs; [
				#		(rust.override (old: { extensions = ["rust-src" "rust-analysis"];}))
				#	];
				#	dontUnpack = true;
				#	buildPhase = ''
				#	'';
				#};


			}
		);
}
