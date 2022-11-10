# NFT minting demo on Aptos network

More detailed guide [here](https://imcoding.online/tutorials/how-to-set-token-index-on-aptos).

## publish the module

```shell
$ cd deploy
$ export DEPLOYER_ADDRESS=59d8469fa18f5613f72f1b2daa2b9227b2a7229c55b102cfcf86e685b38d9515
$ export DEPLOYER_PRIVATE_KEY=b05f9b88c0a50e56a54df017aaa5e864e232d1d4eba99210f62331c8d99440ce
$ export APTOS_NODE_URL=http://127.0.0.1:8080
$ cargo run
```

If all goes well, the console will output the resource account and transaction hash.

```shell
resource account: "e678abebea551c752030dfe6c78147e62b393b74163a4f167ab3444e0eda55a9"
tx: "0x1233ab41de4c5b8346b7110b3f163ab835c24265bd93c7e2c99cd0b287af9ed2"!
```

## generate proof signature

```shell
$ cd example/proof-signature-generate
$ npm run generate
```

The console will output the proof signature for account `35a18f9201d2d6a9e3c86c4b9a00cb4444129cd2dc2fff72719240f8cb394016` with off-chain user id `2333333`.

```shell
identitifer: 32333333333333
977cf82a1f86879a0be90e33d72ec68b9c787a47ccfdd979d4735c25faf3ff8a469f3f40bbdb09eb7cb21bfcff79c4401d779d3172cb52fa9996c11b2366810b
```

## mint an NFT

```shell
$ aptos move run --function-id 0xe678abebea551c752030dfe6c78147e62b393b74163a4f167ab3444e0eda55a9::minting::mint_nft --args hex:32333333333333 --args hex:f094a82ec993a1dab09ce249d6e859afd3f2255103cfb3c47867af329bfd494980a7693dc104bc23b320dfa406e66818c160f50dfedf881bdd31e55fa86a9402
```