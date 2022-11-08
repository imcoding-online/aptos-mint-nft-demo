module imcoding_nft::minting {
  use std::string::{Self, String};
  use std::vector;
  use std::signer::{address_of};

  use aptos_token::token;
  use aptos_framework::resource_account;
  use aptos_framework::account;

  struct NFTMinter has key {
    signer_cap: account::SignerCapability,
    collection: String,
  }

  fun init_module(resource_account: &signer) {
    // the collection name
    let collection_name = string::utf8(b"IMCODING NFT Collection");
    // the collection description
    let description = string::utf8(b"NFT issued by imcoding.online");
    // the collection properity uri
    let collection_uri = string::utf8(b"https://imcoding.online/properity/collection.svg");
    
    // defined as 0 if there is no limit to the supply
    let maximum_supply = 1024;
    // https://github.com/aptos-labs/aptos-core/blob/main/aptos-move/framework/aptos-token/sources/token.move#L263
    let mutate_setting = vector<bool>[ false, false, false ];

    let resource_signer_cap = resource_account::retrieve_resource_account_cap(resource_account, @deployer);
    let resource_signer = account::create_signer_with_capability(&resource_signer_cap);
    
    token::create_collection(&resource_signer, collection_name, description, collection_uri, maximum_supply, mutate_setting);

    move_to(resource_account, NFTMinter {
      signer_cap: resource_signer_cap,
      collection: collection_name,
    });
  }

  public entry fun mint_nft(receiver: &signer) acquires NFTMinter {
    let nft_minter = borrow_global_mut<NFTMinter>(@imcoding_nft);

    let resource_signer = account::create_signer_with_capability(&nft_minter.signer_cap);
    let resource_account_address = address_of(&resource_signer);

    let token_name = string::utf8(b"IMCODING NFT");
    let token_description = string::utf8(b"");
    let token_uri = string::utf8(b"https://imcoding.online/properity/nft.svg");

    let token_data_id = token::create_tokendata(
      &resource_signer,
      nft_minter.collection,
      token_name,
      token_description,
      1,
      token_uri,
      resource_account_address,
      1,
      0,
      token::create_token_mutability_config(
        &vector<bool>[ false, false, false, false, true ]
      ),
      vector::empty<String>(),
      vector::empty<vector<u8>>(),
      vector::empty<String>(),
    );

    let token_id = token::mint_token(&resource_signer, token_data_id, 1);
    token::direct_transfer(&resource_signer, receiver, token_id, 1);
  }
}