module imcoding_nft::minting {
  use std::string::{Self, String};
  use std::vector;
  use std::signer::{address_of};
  use std::error;

  use aptos_token::token;
  use aptos_framework::resource_account;
  use aptos_framework::account;

  use aptos_std::ed25519;

  struct NFTMinter has key {
    signer_cap: account::SignerCapability,
    collection: String,
    public_key: ed25519::ValidatedPublicKey,
  }

  struct MintProofChallenge has drop {
    receiver_account_sequence_number: u64,
    receiver_account_address: address,
  }

  /// error code specifies the proof is invalid
  const EINVALID_PROOF: u64 = 1;

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

    let hardcoed_pk: vector<u8> = x"4092DAED9CCD916BB1E9814E5C2D0660262C4ED62F1750AF4B38110FC73D4D53";
    let public_key = std::option::extract(&mut ed25519::new_validated_public_key_from_bytes(hardcoed_pk));
    move_to(resource_account, NFTMinter {
      signer_cap: resource_signer_cap,
      collection: collection_name,
      public_key: public_key,
    });
  }

  public entry fun mint_nft(receiver: &signer, proof_signature: vector<u8>) acquires NFTMinter {
    let nft_minter = borrow_global_mut<NFTMinter>(@imcoding_nft);
    let receiver_addr = address_of(receiver);
    verify_proof(receiver_addr, proof_signature, nft_minter.public_key);

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

  fun verify_proof(receiver_addr: address, proof_signature: vector<u8>, public_key: ed25519::ValidatedPublicKey) {
    let sequence_number = account::get_sequence_number(receiver_addr);

    let proof_challenge = MintProofChallenge {
      receiver_account_sequence_number: sequence_number,
      receiver_account_address: receiver_addr,
    };

    let signature = ed25519::new_signature_from_bytes(proof_signature);
    let unvalidated_public_key = ed25519::public_key_to_unvalidated(&public_key);
    assert!(ed25519::signature_verify_strict_t(&signature, &unvalidated_public_key, proof_challenge), error::invalid_argument(EINVALID_PROOF));
  }
}