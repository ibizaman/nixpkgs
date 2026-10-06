{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "immich-exporter";
  version = "3.0.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Finkregh";
    repo = "immich-prometheus-exporter";
    tag = "${finalAttrs.version}";
    hash = "sha256-1GXlQ0CZGvwCw4N/9vnwbsVnSuXtuqL5RBr/a7z+iHo=";
  };

  build-system = [
    python3Packages.uv-build
  ];

  dependencies = with python3Packages; [
    typer
    prometheus-client
    requests
    rich
  ];

  pythonImportsCheck = [
    "immich_prometheus_exporter"
  ];

  doCheck = false; # no tests because it would require declarative user and api key creation

  meta = {
    description = "Prometheus exporter for Immich";
    homepage = "https://git.h.oluflorenzen.de/finkregh/immich-prometheus-exporter";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      ibizaman
    ];
    mainProgram = "immich-exporter";
  };
})
