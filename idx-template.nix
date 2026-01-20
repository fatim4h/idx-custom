{ pkgs, initScript ? "", onCreateScript ? "", extraPackages ? "", extraEnv ? ""
, ... }: {
  packages = [ pkgs.coreutils ];
  bootstrap = ''
    mkdir -p "$WS_NAME/.idx"

    cat > "$WS_NAME/.idx/dev.nix" << 'DEVNIX'
    { pkgs, ... }: {
      channel = "unstable";
      packages = [
        pkgs.coreutils
        ${extraPackages}
      ];
      env = {
        ${extraEnv}
      };
      idx = {
        extensions = [];
        workspace = {
          onCreate = {
            ${
              if onCreateScript != "" then ''
                custom = "echo '${onCreateScript}' | base64 -d | bash";
              '' else
                ""
            }
          };
          onStart = {
            ${
              if initScript != "" then ''
                custom = "echo '${initScript}' | base64 -d | bash";
              '' else
                ""
            }
          };
        };
      };
    }
    DEVNIX

    chmod -R +w "$WS_NAME"
    mv "$WS_NAME" "$out"
  '';
}
