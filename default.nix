{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/057f9aecfb71c4437d2b27d3323df7f93c010b7e.tar.gz") {} }:

let
  go = pkgs.go_1_21;
in
pkgs.mkShell {
  buildInputs = [ go ];
  shellHook = ''
    function local_launch_full { 
      echo "Building the modified MEV relayer..."
      docker build -f Dockerfile -t "hoprnet/modified-mev-relayer:$(git rev-parse --short HEAD)" .
      echo "Launching testnet with the modified MEV relayer with Kurtosis..."
      kurtosis clean -a && kurtosis --enclave local-eth-testnet run /Users/qyu/Documents/ethereum-package --args-file /Users/qyu/Documents/mev-privacy-research/ethereum-package-params.yaml
    }

    function run_housekeeper {
      echo "Exporting env variables..."
      set -o allexport && source .env && set +o allexport
      echo "Spawning housekeeper..."
      go run . housekeeper --network custom --db postgres://postgres:postgres@localhost:5432/postgres?sslmode=disable
    }

    function run_api {
      echo "Exporting env variables..."
      set -o allexport && source .env && set +o allexport
      echo "Spawning API..."
      go run . api --network custom --secret-key 0x607a11b45a7219cc61a3d9c5fd08c7eebd602a6a19a977f8d3771d5711a550f2 --db postgres://postgres:postgres@localhost:5432/postgres?sslmode=disable
    }

    function run_website {
      echo "Exporting env variables..."
      set -o allexport && source .env && set +o allexport
      echo "Spawning website..."
      go run . website --network custom --db postgres://postgres:postgres@localhost:5432/postgres?sslmode=disable
    }

    function launch_full { 
      echo "Launching testnet with Kurtosis..."
      kurtosis clean -a && kurtosis --enclave local-eth-testnet run github.com/kurtosis-tech/ethereum-package --args-file ./ethereum-package-params.yaml
    }

    function open_service_url() {
      local service_name=$1
      local url=$(kurtosis enclave inspect local-eth-testnet | grep "$service_name" | awk -F ' -> ' '{split($2, a, " "); print a[1]}')
      if [ -n "$url" ]; then
          echo "Opening $service_name at $url"
          open "$url"
      else
          echo "URL for $service_name not found."
      fi
    }
  '';
}