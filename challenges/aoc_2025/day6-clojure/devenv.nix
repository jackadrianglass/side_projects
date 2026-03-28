{ pkgs, lib, config, inputs, ... }:

{
  packages = [ pkgs.git ];

  # https://devenv.sh/languages/
  languages.clojure.enable = true;
  languages.clojure.lsp.enable = true;
}
