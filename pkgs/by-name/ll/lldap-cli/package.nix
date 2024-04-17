{ lib
, stdenvNoCC
, fetchFromGitHub

, curl
, jq
, makeWrapper
, lldap
, util-linux
}:

stdenvNoCC.mkDerivation (finalAttrs: rec {
  name = "lldap-cli";

  src = fetchFromGitHub {
    owner = "ibizaman";
    repo = finalAttrs.name;
    rev = "422f67fbd9d52466591f7260592bbcd8fc09a210";
    hash = "sha256-LX1g2OKrNI9XityQMW7Ag0O+rrFxWw5jczjDTkDLS+k=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    curl
    jq
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/lldap-cli
    mkdir -p $out/bin

    cp lldap-cli $out/bin
    chmod +x $out/bin/lldap-cli

    substituteInPlace $out/bin/lldap-cli --replace "curl" "${curl}/bin/curl"
    substituteInPlace $out/bin/lldap-cli --replace "jq" "${jq}/bin/jq"
    substituteInPlace $out/bin/lldap-cli --replace "column" "${util-linux}/bin/column"
    substituteInPlace $out/bin/lldap-cli --replace "lldap_set_password" "${lldap}/bin/lldap_set_password"

    runHook postInstall
  '';

  meta = {
    description = "LLDAP-CLI is a command line interface for LLDAP.";
    homepage = "https://github.com/Zepmann/lldap-cli";
    license = lib.licenses.gpl3;
    mainProgram = "lldap-cli";
    maintainers = with lib.maintainers; [ ibizaman ];
    platforms = lib.platforms.all;
  };
})
