{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.prometheus.exporters.immich;
  inherit (lib) mkOption types concatStringsSep;
in
{
  port = 9142;

  extraOpts = {
    apiKeyFile = mkOption {
      type = types.externalPath;
      description = ''
        Path to ApiKey used to access Immich.

        ApiKey permissions are listed in
        https://git.h.oluflorenzen.de/finkregh/immich-prometheus-exporter/src/tag/3.0.2#api-key-setup
      '';
    };

    url = mkOption {
      type = types.str;
      description = ''
        URL of the Immich server.
      '';
    };
  };

  serviceOpts = {
    serviceConfig = {
      User = cfg.user;
      LoadCredential = [ "api-key:${cfg.apiKeyFile}" ];
      ExecStart = ''
        IMMICHEXPORTER_EXPORT_API_KEY=$(cat $CREDENTIALS_DIRECTORY/api-key)
        export IMMICHEXPORTER_EXPORT_API_KEY
        ${lib.getExe pkgs.prometheus-immich-exporter} server \
          --listen ${toString cfg.listenAddress}:${toString cfg.port} \
          --url ${cfg.url} \
          ${concatStringsSep " \\\n  " cfg.extraFlags}
      '';
    };
  };
}
