{ callPackage }:
let mkJava = spec: callPackage (import ./generic.nix spec) { };
in {
  zulu11 = mkJava {
    version = "11.62.17";
    openjdkVersion = "11.0.18";
    hashes.x86_64-linux = "sha256-b65oEbDzrrsUw+WaX94USBz/QS74yiMiGZPxqzMmmqs=";
    hashes.x86_64-darwin = "sha256-nRRWTWiog8bRblmmPIPE5YibA34St3ZrJpZN91qEDUg=";
    hashes.aarch64-darwin = "sha256-TBTrBxOfGo6MV+Md49P3sDfqVG1e+NraqfVbw9WTppk=";
  };
}
