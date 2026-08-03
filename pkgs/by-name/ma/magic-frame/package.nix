{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_24,
  openssl,
  makeWrapper,
  prisma-engines,
}:

# mkdir -p .tmp/pg
# nix shell nixpkgs#postgresql --command initdb   -D .tmp/pg   --auth=trust
# nix shell nixpkgs#postgresql --command postgres   -D .tmp/pg   -k "$PWD/.tmp"   -p 5433

# ./result/bin/magic-frame-prisma db push
# ./result/bin/magic-frame-bootstrap
# ./result/bin/magic-frame

buildNpmPackage (finalAttrs: {
  pname = "magic-frame";
  version = "1.5.5";

  src = fetchFromGitHub {
    owner = "jeremiaa";
    repo = "magic-frame";
    rev = "v${finalAttrs.version}";
    hash = "sha256-7qvL9PN3FRm/wJxtrdqkE/BSEEvBER4wCD+ly0CdTjg=";
  };

  nodejs = nodejs_24;

  npmDepsHash = "sha256-x/xiXZmsxlLDF6arZ4xp6/tI/0TtmMQuCuk7p1EOG9Y=";

  nativeBuildInputs = [
    openssl
    makeWrapper
    prisma-engines
  ];

  env = {
    PRISMA_CLI_QUERY_ENGINE_TYPE = "binary";
    PRISMA_SKIP_POSTINSTALL_GENERATE = "true";
    PRISMA_QUERY_ENGINE_BINARY = "${prisma-engines}/bin/query-engine";
    PRISMA_SCHEMA_ENGINE_BINARY = "${prisma-engines}/bin/schema-engine";
  };

  # Needed because the Docker build creates this before prisma generate
  preBuild = ''
    echo "DATABASE_URL=postgresql://dummy:dummy@localhost:5432/dummy" > .env
    npx prisma generate
  '';

  npmBuildScript = "build";
  npmBuildFlags = [ "--webpack" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/magic-frame

    cp -r \
      .next \
      next.config.* \
      node_modules \
      package.json \
      prisma \
      prisma.config.ts \
      public \
      scripts \
      server.js \
      src \
      $out/lib/magic-frame/

    makeWrapper ${finalAttrs.nodejs}/bin/node \
      $out/bin/magic-frame \
      --chdir $out/lib/magic-frame \
      --set NODE_ENV production \
      --add-flags server.js

    makeWrapper ${finalAttrs.nodejs}/bin/node \
      $out/bin/magic-frame-prisma \
      --chdir $out/lib/magic-frame \
      --set NODE_ENV production \
      --set OPENSSL_DIR ${openssl.dev} \
      --set PRISMA_SCHEMA_ENGINE_BINARY "${prisma-engines}/bin/schema-engine" \
      --set PRISMA_QUERY_ENGINE_BINARY "${prisma-engines}/bin/query-engine" \
      --add-flags node_modules/prisma/build/index.js

    makeWrapper ${finalAttrs.nodejs}/bin/node \
      $out/bin/magic-frame-bootstrap \
      --chdir $out/lib/magic-frame \
      --set NODE_ENV production \
      --add-flags scripts/bootstrap.mjs

    runHook postInstall
  '';

  meta = {
    description = "Magic Frame self-hosted family dashboard and picture frame";
    homepage = "https://github.com/jeremiaa/magic-frame";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
})
