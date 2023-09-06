{ callPackage }:
let mkJava = spec: callPackage (import ./generic.nix spec) { };
in {
  zulu11 = mkJava {
    version = "11.62.17";
    openjdkVersion = "11.0.18";
    hashes = {
      x86_64-linux = "sha256-b65oEbDzrrsUw+WaX94USBz/QS74yiMiGZPxqzMmmqs=";
      x86_64-darwin = "sha256-nRRWTWiog8bRblmmPIPE5YibA34St3ZrJpZN91qEDUg=";
      aarch64-darwin = "sha256-TBTrBxOfGo6MV+Md49P3sDfqVG1e+NraqfVbw9WTppk=";

    };
  };
  zulu17 = mkJava {
    version = "17.44.15";
    openjdkVersion = "17.0.8";
    hashes = {
      x86_64-linux = "sha256-Qj0fQODL6HPzV867lbGaWVA5SO48kWOey8jmTfam9fw=";
      x86_64-darwin = "";
      aarch64-darwin = "";
    };
  };
  zulu20 = mkJava {
    version = "20.32.11";
    openjdkVersion = "20.0.2";
    hashes = {
      x86_64-linux = "sha256-sq9EKhN6w6YyJ4vPXRSlIf6UbDU/Lfsyh15yvBbmMjo=";
      x86_64-darwin = "";
      aarch64-darwin = "";
    };
  };
}
