#!/bin/bash

cd contracts/circuits

mkdir Multipler3

if [ -f ./powersOfTau28_hez_final_10.ptau ]; then
    echo "powersOfTau28_hez_final_10.ptau already exists. Skipping."
else
    echo 'Downloading powersOfTau28_hez_final_10.ptau'
    wget https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_10.ptau
fi

echo "Compiling Multipler3.circom..."

# compile circuit

circom Multipler3.circom --r1cs --wasm --sym -o Multipler3
snarkjs r1cs info Multipler3/Multipler3.r1cs

# Start a new zkey and make a contribution

snarkjs groth16 setup Multipler3/Multipler3.r1cs powersOfTau28_hez_final_10.ptau Multipler3/circuit_0000.zkey
snarkjs zkey contribute Multipler3/circuit_0000.zkey Multipler3/circuit_final.zkey --name="1st Contributor Name" -v -e="random text"
snarkjs zkey export verificationkey Multipler3/circuit_final.zkey Multipler3/verification_key.json

# generate solidity contract
snarkjs zkey export solidityverifier Multipler3/circuit_final.zkey ../Multipler3Verifier.sol

cd ../..
