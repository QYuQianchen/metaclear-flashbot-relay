# Metaclear MEV Relay

(Code forked from `flashbots/mev-boost-relay`)

This code is used in the research work on the metadata privacy of MEV Relay.

- Collects metadata information of HTTP calls and store them in a DB table.
- Add table to collect data from local beacon node
- Add prometheus metrics

## Build
```bash
nix-shell
export mev_relay_img=$(git rev-parse --short HEAD) 
docker build -f Dockerfile -t "hoprnet/metaclear-mev-relayer:$mev_relay_img" .

# Load the local image to minikube
minikube image load "hoprnet/metaclear-mev-relayer:$mev_relay_img" 
echo $mev_relay_img
```