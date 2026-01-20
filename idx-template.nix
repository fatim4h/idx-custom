{ pkgs, initScript ? "", onCreateScript ? "", extraPackages ? "", extraEnv ? ""
, ... }: {
  packages = [ pkgs.coreutils ];
  bootstrap = ''
    mkdir -p "$WS_NAME/.idx"

    cat > "$WS_NAME/.idx/dev.nix" << 'DEVNIX'
    { pkgs, ... }: {
      channel = "unstable";
      packages = with pkgs; [
        coreutils
        ${extraPackages}
      ];
      env = {
        ${extraEnv}
      };
      idx = {
        extensions = [];
        previews = {
          enable = true;
          previews = {
            init = {
              command = ["bash" "-c" "export PATH=$HOME/.local/bin:$PATH; exec &>/tmp/init.log; set -x; for cmd in $(echo $MONOSPACE_ON_CREATE_COMMANDS | jq -r '.[]'); do $cmd; done; for cmd in $(echo $MONOSPACE_ON_START_COMMANDS | jq -r '.[]'); do $cmd; done"];
              manager = "web";
            };
          };
        };
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
