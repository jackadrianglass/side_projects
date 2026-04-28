{ pkgs, lib, config, inputs, ... }:

{
  packages = [ pkgs.git ];

  languages.gleam.enable = true;

  tasks = {
    "basic:build".exec = "gleam run";
    "basic:dev".exec = "gleam dev";
  };

  # https://devenv.sh/tests/
  enterTest = ''
    echo "Running tests"
    git --version | grep --color=auto "${pkgs.git.version}"
  '';

  # https://devenv.sh/git-hooks/
  # git-hooks.hooks.shellcheck.enable = true;
}
