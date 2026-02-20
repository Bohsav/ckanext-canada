# See full reference at https://devenv.sh/
{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

let
  # stable for 2 years. Today is 2026
  pkgs-stable = import inputs.nixpkgs-stable { system = pkgs.stdenv.system; };

  # pkgs are unstable / devenv rolling release.
  # Although they are usually pretty stable
  unstable-pkgs = with pkgs; [
    git
    postgresql.pg_config
    file
    libpq
    jetty
    jdk25_headless
  ];

  stable-pkgs = with pkgs-stable; [ ];

  ckan-config = {
    ckan-username = "ckan_default";
    ckan-defaultdb = "ckan_default";
    ckan-defaultdir = "./";
  };
in
{
  packages = unstable-pkgs ++ stable-pkgs;

  env.SRC_CKAN = ".devenv/state/venv/src/ckan";

  languages.python = {
    version = "3.10.19";
    enable = true;
    venv = {
      enable = true;
      requirements = "ckan[requirements,dev] @ git+https://github.com/Bohsav/ckan.git@9240-fix-cookiecutter-extension";
    };
  };

  services.postgres = {
    enable = true;
    listen_addresses = "localhost";
    port = 5432;
  };

  # Shell scripts
  scripts = {
    ckan-setup-postgress = {
      exec = ''
        echo "Creating user"
        createuser -S -D -R -P ${ckan-config.ckan-username}
        echo "Creating db"
        createde -O ${ckan-config.ckan-username} ${ckan-config.ckan-defaultdb} -E utf-8
      '';
      description = "(first time) Setup PostgreSQL for CKAN for initial installation";
    };
    run-ckan = {
      exec = ''
        echo "ckan -c ${ckan-config.ckan-defaultdir}/ckan.ini run"
      '';
      description = "Run CKAN";
    };
    ckan-run-services = {
      exec = ''
        docker run --name ckan-solr -p 8983:8983 -d ckan/ckan-solr:2.11-solr9
        docker run --name ckan-redis -p 6379:6379 -d redis
      '';
      description = "(first time) Setup CKAN services (ckan-redis and ckan-solr)";
    };
    ckan-init-db = {
      exec = ''
        ckan -c "./ckan.ini" db init
      '';
      description = "(first time) Setup postgresql databases with ckan";
    };
    ckan-start-services = {
      exec = ''
        docker start ckan-solr 
        docker start ckan-redis
      '';
      description = "Start docker ckan-solr and ckan-redis";
    };
    ckan-stop-services = {
      exec = ''
        docker stop ckan-solr ckan-redis
      '';
      description = "Stop docker ckan-solr and ckan-redis";
    };
  };

  # https://devenv.sh/basics/
  enterShell = ''
    echo "Available commands:"
    ${pkgs.gnused}/bin/sed -e 's| |••|g' -e 's|=| |' <<EOF | ${pkgs.util-linuxMinimal}/bin/column -t | ${pkgs.gnused}/bin/sed -e 's|^| |' -e 's|••| |g'
    ${lib.generators.toKeyValue { } (lib.mapAttrs (name: value: value.description) config.scripts)}

  '';

}
