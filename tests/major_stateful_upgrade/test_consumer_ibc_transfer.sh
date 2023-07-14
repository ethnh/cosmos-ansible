#!/bin/bash
# Test IBC transfer

echo "Running with $CONSUMER_CHAIN_BINARY."

PROVIDER_CHANNEL=$1
EXPECTED_DENOMS=$2
# Transfer provider token to consumer chain
echo "Sending $DENOM to $CONSUMER_CHAIN_ID..."
$CHAIN_BINARY --home $HOME_1 tx ibc-transfer transfer transfer $PROVIDER_CHANNEL $WALLET_1 1000$DENOM --from $WALLET_1 --keyring-backend test --gas 500000 --fees 5000$DENOM -b block -y --chain-id $CHAIN_ID
echo "Waiting for the transfer to reach the consumer chain..."
sleep 30
DENOM_AMOUNT=$($CONSUMER_CHAIN_BINARY --home $CONSUMER_HOME_1 q bank balances $WALLET_1 -o json | jq -r '.balances | length')
if [ $DENOM_AMOUNT -lt 2 ]; then
    echo "Only one denom found in consumer wallet."
    exit 1
fi
echo "Found at least two denoms in the consumer wallet."

# Transfer consumer token to provider chain
echo "Sending $CONSUMER_DENOM to $CHAIN_ID..."
$CONSUMER_CHAIN_BINARY --home $CONSUMER_HOME_1 tx ibc-transfer transfer transfer channel-1 $WALLET_1 1000$CONSUMER_DENOM --from $WALLET_1 --keyring-backend test -b block -y
echo "Waiting for the transfer to reach the provider chain..."
sleep 60
$CHAIN_BINARY --home $HOME_1 q bank balances $WALLET_1 -o json
DENOM_AMOUNT=$($CHAIN_BINARY --home $HOME_1 q bank balances $WALLET_1 -o json | jq -r '.balances | length')
if [ $DENOM_AMOUNT -lt $EXPECTED_DENOMS ]; then
    echo "Found less than expected denoms in provider wallet."
    exit 1
fi
echo "Found the right amount of denoms in the provider wallet."
