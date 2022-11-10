import { BCS, AptosAccount, TxnBuilderTypes, AptosClient } from "aptos";

class MintProofChallenge {
  moduleAddress: string;
  moduleName: string;
  structName: string;
  sequenceNumber: number;
  address: string;
  identifier: Uint8Array;

  constructor(sequenceNumber: number, address: string, identifier: Uint8Array) {
    this.moduleAddress = "e678abebea551c752030dfe6c78147e62b393b74163a4f167ab3444e0eda55a9";
    this.moduleName = "minting";
    this.structName = "MintProofChallenge";
    this.sequenceNumber = sequenceNumber;
    this.address = address;
    this.identifier = identifier;
  }

  serialize(serializer: BCS.Serializer) {
    TxnBuilderTypes.AccountAddress.fromHex(this.moduleAddress).serialize(serializer);
    serializer.serializeStr(this.moduleName);
    serializer.serializeStr(this.structName);
    serializer.serializeU64(this.sequenceNumber);
    TxnBuilderTypes.AccountAddress.fromHex(this.address).serialize(serializer);
    serializer.serializeBytes(this.identifier);
  };
}

const generateProofSignature = async (userId: string, address: string): Promise<string> => {
  const claimKey = "C4E98CDCFF38D8DD9BD5F5456B489212ED2965BA8789CD70612EBE20C26E4873";
  const client = new AptosClient(process.env.APTOS_NODE_URL || "http://127.0.0.1:8080");
  const account = await client.getAccount(address);

  const identifier = Buffer.from(userId);
  console.log("identitifer:", identifier.toString("hex"));
  
  const proof = new MintProofChallenge(
    parseInt(account.sequence_number),
    address,
    Uint8Array.from(identifier),
  );
  
  const proofMsg = BCS.bcsToBytes(proof);
  const signAccount = new AptosAccount(Uint8Array.from(Buffer.from(claimKey, "hex")));
  const signature = signAccount.signBuffer(proofMsg);
  return signature.noPrefix();
}

generateProofSignature("2333333", "35a18f9201d2d6a9e3c86c4b9a00cb4444129cd2dc2fff72719240f8cb394016").then(console.log);