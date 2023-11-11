#!/bin/bash
set -euo pipefail

if [ $# -ge 1 ]; then
    LOOP_COUNT=$1
else
    LOOP_COUNT=10
fi

ZERO=0

# export RPC=http://0.0.0.0:5050
export RPC=https://api.cartridge.gg/x/bench/katana

ACCOUNTS=("0x517ececd29116499f4a1b64b094da79ba08dfd54a3edaa316134c41f8160973")
ACCOUNTS+=("0x5686a647a9cdd63ade617e0baf3b364856b813b508f03903eb58a7e622d5855")
ACCOUNTS+=("0x765149d6bc63271df7b0316537888b81aa021523f9516a05306f10fd36914da")
ACCOUNTS+=("0x5006399928dad095cc39818cae15dc022592d47d883701e7814c9db19e96efc")
ACCOUNTS+=("0x586364c42cf7f6c968172ba0806b7403c567544266821c8cd28c292a08b2346")

PKS=("0x1800000000300000180000000000030000000000003006001800006600")
PKS+=("0x33003003001800009900180300d206308b0070db00121318d17b5e6262150b")
PKS+=("0x1c9053c053edf324aec366a34c6901b1095b07af69495bffec7d7fe21effb1b")
PKS+=("0x736adbbcdac7cc600f89051db1abbc16b9996b46f6b58a9752a11c1028a8ec8")
PKS+=("0x2bbf4f9fd0bbb2e60b0316c1fe0b76cf7a4d0198bd493ced9b8df2a3a24d68a")

export WORLD_ADDRESS=$(cat ./target/dev/manifest.json | jq -r '.world.address')
export CHARGE_ADDRESS=$(cat ./target/dev/manifest.json | jq -r '.contracts[] | select(.name == "charge" ).address')


### uncomment first run 

# echo "set auth"
# sozo auth writer Store $CHARGE_ADDRESS --world $WORLD_ADDRESS --rpc-url $RPC

# echo "get katana accounts"
# # rm -rf katana_account_*

# counter=0
# for account in ${ACCOUNTS[@]}; do
#     echo "fetching account $counter"
#     starkli account fetch $account --rpc $RPC --output ./katana_account_$counter.json
#     ((counter = counter + 1))
# done

echo "sending txs"
for ((i = 0; i <= $LOOP_COUNT; i++)); do
    echo "BATCH $i"

    counter=0
    for account in ${ACCOUNTS[@]}; do
        starkli invoke $CHARGE_ADDRESS emit_contract_event 50 --account ./katana_account_$counter.json --private-key ${PKS[$counter]} --rpc $RPC
        sleep 0.1
        ((counter = counter + 1))
    done

    sleep 1
done

