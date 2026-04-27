{ pkgs, lib, config, inputs, ... }:

{
  packages = [
    pkgs.git
    pkgs.elmPackages.elm-format
    pkgs.elmPackages.elm-review
    pkgs.elmPackages.lamdera
    pkgs.nodejs
  ];

  enterShell = ''
    export PATH="$PWD/node_modules/.bin:$PATH"
  '';

  languages.elm.enable = true;
  languages.elm.lsp.enable = true;

  tasks = {
    "format" = {
      exec = "elm-format src app --yes";
    };

    "format:check" = {
      exec = "elm-format --validate src app";
    };

    "build" = {
      exec = "elm-pages build";
    };
  };
}
