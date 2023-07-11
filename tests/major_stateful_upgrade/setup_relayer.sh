#!/bin/bash
# Set up a relayer and IBC channels

PROVIDER_CLIENT=$1

# Clear existing installation
rm -rf ~/.hermes
rm hermes
rm hermes*gz

echo "Downloading Hermes..."
wget -nv https://github.com/informalsystems/hermes/releases/download/v1.4.0/hermes-v1.4.0-x86_64-unknown-linux-gnu.tar.gz -O hermes-v1.4.0.tar.gz
tar -xzvf hermes-v1.4.0.tar.gz
mkdir -p ~/.hermes
cp hermes ~/.hermes/hermes
export PATH="$PATH:~/.hermes"

echo "Setting up Hermes config..."
cp tests/patch_upgrade/hermes-config.toml ~/.hermes/config.toml

echo "Adding relayer keys..."
echo $MNEMONIC_1 > mnemonic.txt
hermes keys add --chain $CHAIN_ID --mnemonic-file mnemonic.txt
hermes keys add --chain consumera --mnemonic-file mnemonic.txt
hermes keys add --chain consumerb --mnemonic-file mnemonic.txt
hermes keys add --chain consumerc --mnemonic-file mnemonic.txt
hermes keys add --chain consumerf --mnemonic-file mnemonic.txt

# echo "Creating connection..."
# hermes create connection --a-chain $CONSUMER_CHAIN_ID --a-client 07-tendermint-0 --b-client $PROVIDER_CLIENT

# echo "Creating channel..."
# hermes create channel --a-chain $CONSUMER_CHAIN_ID --a-port consumer --b-port provider --order ordered --a-connection connection-0 --channel-version 1

echo "Setting up services..."
echo "Creating script for Hermes"
echo "while true; do $HOME/.hermes/hermes --config $HOME/.hermes/config.toml start; sleep 1; done" > $HOME/hermes.service.sh
chmod +x $HOME/hermes.service.sh

# Run service in screen session
if [ ! -d $HOME/artifact ]
then
    mkdir $HOME/artifact
fi

echo "Starting Hermes"
screen -L -Logfile $HOME/artifact/hermes.service.log -S hermes.service -d -m bash $HOME/hermes.service.sh
# set screen to flush log to 0
screen -r hermes.service -p0 -X logfile flush 0

# echo "Waiting for channels to be opened..."
# sleep 30
