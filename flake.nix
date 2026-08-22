{
  description = "A Nix-flake-based Elixir development environment";

  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1"; # unstable Nixpkgs

  outputs = {self, ...} @ inputs: let
    inherit (inputs.nixpkgs) lib;

    supportedSystems = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    forEachSupportedSystem = f:
      lib.genAttrs supportedSystems (
        system:
          f {
            inherit system;
            pkgs = import inputs.nixpkgs {
              inherit system;
              overlays = [inputs.self.overlays.default];
            };
          }
      );
  in {
    overlays.default = final: prev: let
      # documentation
      # https://nixos.org/manual/nixpkgs/stable/#sec-beam
      # ==== ERLANG ====
      # use whatever version is currently defined in nixpkgs
      # erlang = pkgs.beam.interpreters.erlang;
      # use latest version of Erlang 28
      erlang = final.beam.interpreters.erlang_28;

      # specify exact version of Erlang OTP
      # erlang = pkgs.beam.interpreters.erlang.override {
      #   version = "26.2.2";
      #   sha256 = "sha256-7S+mC4pDcbXyhW2r5y8+VcX9JQXq5iEUJZiFmgVMPZ0=";
      # }

      # ==== BEAM packages ====

      # all BEAM packages will be compile with your preferred erlang version
      pkgs-beam = final.beam.packagesWith erlang;
    in {
      # ==== Elixir ====

      # use whatever version is currently defined in nixpkgs
      # elixir = pkgs-beam.elixir;

      # use latest version of Elixir 1.19
      elixir = pkgs-beam.elixir_1_19;

      # specify exact version of Elixir
      # elixir = pkgs-beam.elixir.override {
      #   version = "1.17.1";
      #   sha256 = "sha256-a7A+426uuo3bUjggkglY1lqHmSbZNpjPaFpQUXYtW9k=";
      # };
    };

    devShells = forEachSupportedSystem (
      {
        pkgs,
        system,
      }: {
        default = pkgs.mkShellNoCC {
          packages = with pkgs;
            [
              # use the Elixr/OTP versions defined above; will also install OTP, mix, hex, rebar3
              elixir

              # mix needs it for downloading dependencies
              git

              # probably needed for Phoenix assets
              nodejs_latest

            # database for the pastebin app
            postgresql

            # containers
            podman
            podman-compose

              self.formatter.${system}
            ]
            ++
            # Linux only
            pkgs.lib.optionals pkgs.stdenv.isLinux (
              with pkgs; [
                gigalixir
                inotify-tools
                libnotify
              ]
            )
            ++
            # macOS only
            pkgs.lib.optionals pkgs.stdenv.isDarwin (
              with pkgs; [
                terminal-notifier
              ]
            );
        };
      }
    );

    formatter = forEachSupportedSystem ({pkgs, ...}: pkgs.nixfmt);

    # one-command container deploys, e.g.:  nix run .#up
    apps = forEachSupportedSystem ({
      pkgs,
      system,
    }: let
      ensureEnv =
        pkgs.writeShellScript "frontier-ensure-env" # bash
        ''
          cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
          if [ ! -f .env ]; then
            echo "Generating .env with a fresh SECRET_KEY_BASE..."
            {
              echo "SECRET_KEY_BASE=$(${pkgs.openssl}/bin/openssl rand -hex 64)"
              echo "# PHX_HOST=yourdomain.com"
            } > .env
          fi
        '';

      compose =
        pkgs.writeShellScript "frontier-compose" # bash
        ''
          export PATH=${pkgs.podman}/bin:$PATH
          export PODMAN_COMPOSE_PROVIDER=${pkgs.podman-compose}/bin/podman-compose

          # rootless podman outside NixOS needs these to exist
          confdir="''${XDG_CONFIG_HOME:-$HOME/.config}/containers"
          mkdir -p "$confdir"
          [ -f "$confdir/policy.json" ] || printf '%s\n' \
            '{"default":[{"type":"insecureAcceptAnything"}]}' > "$confdir/policy.json"

          exec ${pkgs.podman}/bin/podman compose "$@"
        '';
    in rec {
      default = up;

      up = {
        type = "app";
        program = toString (pkgs.writeShellScript "frontier-up" # bash
          ''
            set -e
            ${ensureEnv}
            echo "Building + starting Frontier (podman)..."
            exec ${compose} up -d --build "$@"
          '');
      };

      down = {
        type = "app";
        program = toString (pkgs.writeShellScript "frontier-down" # bash
          ''exec ${compose} down "$@"'');
      };

      logs = {
        type = "app";
        program = toString (pkgs.writeShellScript "frontier-logs" # bash
          ''exec ${compose} logs -f app "$@"'');
      };

      migrate = {
        type = "app";
        program = toString (pkgs.writeShellScript "frontier-migrate" # bash
          ''
            set -e
            ${ensureEnv}
            exec ${compose} run --rm --entrypoint "" \
              frontier sh -c "/app/bin/frontier eval Frontier.Release.migrate"
          '');
      };
    });
  };
}
