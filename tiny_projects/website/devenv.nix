{ pkgs, lib, config, inputs, ... }:

{
  packages = [
    pkgs.git
    pkgs.elmPackages.elm-format
    pkgs.elmPackages.elm-review
    pkgs.elmPackages.lamdera
    pkgs.nodejs
  ];

  languages.elm.enable = true;
  languages.elm.lsp.enable = true;

  tasks = {
    "verify:format" = {
      exec = "elm-format src app --yes";
    };

    "verify:lint" = {
      exec = "elm-format --validate src app";
    };

    "verify:review" = {
      exec = "elm-review";
    };

    "verify:build" = {
      exec = "npm run build";
    };
  };
}
