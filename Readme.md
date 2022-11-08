# NFT minting demo on Aptos network

More detailed guide [here](https://imcoding.online/tutorials/how-to-publish-and-mint-nft-on-aptos).

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

## mint an NFT

```shell
$ aptos move run --function-id 0xe678abebea551c752030dfe6c78147e62b393b74163a4f167ab3444e0eda55a9::minting::mint_nft
```