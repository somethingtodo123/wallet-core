// Copyright © 2017-2020 Trust Wallet.
//
// This file is part of Trust. The full Trust copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import XCTest
import TrustWalletCore

class EOSTests: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
    }

    func testValidAddresses() {
        XCTAssertTrue(CoinType.eos.validate(address: "EOS6Vm7RWMS1KKAM9kDXgggpu4sJkFMEpARhmsWA84tk4P22m29AV"))
        XCTAssertTrue(CoinType.eos.validate(address: "PUB_R1_6pQRUVU5vdneRnmjSiZPsvu3zBqcptvg6iK2Vz4vKo4ugnzow3"))
    }

    func testInvalidAddresses() {
        for addr in [
            "abc",
            "65QzSGJ579GPNKtZoZkChTzsxR4B48RCfiS82m2ymJR6VZCjTF",
            "EOS65QzSGJ579GPNKtZoZkChTzsxR4B48RCfiS82m2ymJR6VZCjT",
            "PUB_5hieQEFWh68h6bjaYAY25Ptd2bmqLCaFsunaneh9gZsmSgUBUe",
            "PUB_K1_5hieQEFWh68h6bjaYAY25Ptd2bmqLCaFsunaneh9gZsmSgUBUe",
            "PUB_K1_65QzSGJ579GPNKtZoZkChTzsxR4B48RCfiS82m2ymJR6VZCjTF",
            ] {
                XCTAssertFalse(CoinType.eos.validate(address: addr))
        }
    }

    let signingInput: EOSSigningInput = {
        let asset = EOSAsset.with {
            $0.amount = 300000
            $0.decimals = 4
            $0.symbol = "TKN"
        }

        return EOSSigningInput.with {
            $0.chainID = Data(hexString: "cf057bbfb72640471fd910bcb67639c22df9f92470936cddc1ade0e2f2e7dc4f")!
            $0.referenceBlockID = Data(hexString: "000067d6f6a7e7799a1f3d487439a679f8cf95f1c986f35c0d2fa320f51a7144")!
            $0.referenceBlockTime = 1554209118
            $0.currency = "token"
            $0.sender = "token"
            $0.recipient = "eosio"
            $0.memo = "my second transfer"
            $0.asset = asset
            $0.privateKey = Hash.sha256(data: "A".data(using: .utf8)!)
            $0.privateKeyType = .modernk1
        }
    }()


    func testSigning() throws {
        let ouptut: EOSSigningOutput = AnySigner.sign(input: signingInput, coin: .eos)

        let expectedJSON = """
        {
            "compression": "none",
            "packed_context_free_data": "",
            "packed_trx": "7c59a35cd6679a1f3d4800000000010000000080a920cd000000572d3ccdcd010000000080a920cd00000000a8ed3232330000000080a920cd0000000000ea3055e09304000000000004544b4e00000000126d79207365636f6e64207472616e7366657200",
            "signatures": ["SIG_K1_KfCdjsrTnx5cBpbA5cUdHZAsRYsnC9uKzuS1shFeqfMCfdZwX4PBm9pfHwGRT6ffz3eavhtkyNci5GoFozQAx8P8PBnDmj"]
        }
        """
        XCTAssertTrue(ouptut.error.isEmpty)
        XCTAssertJSONEqual(ouptut.jsonEncoded, expectedJSON)
    }

    func testSigningFailures() throws {
        var badInput = signingInput
        badInput.asset.decimals = 19
        var signingOutput: EOSSigningOutput = AnySigner.sign(input: badInput, coin: .eos)
        XCTAssertFalse(signingOutput.error.isEmpty, "Expected error but signing suceeded!")

        badInput = signingInput
        badInput.asset.symbol = "xyz"
        signingOutput = AnySigner.sign(input: badInput, coin: .eos)
        XCTAssertFalse(signingOutput.error.isEmpty, "Expected error but signing suceeded!")

        badInput = signingInput
        badInput.recipient = String(repeating: "A", count: 15)
        signingOutput = AnySigner.sign(input: badInput, coin: .eos)
        XCTAssertFalse(signingOutput.error.isEmpty, "Expected error but signing suceeded!")

        badInput = signingInput
        badInput.referenceBlockID = Data(hexString: "0000086bf9e7704509aa41311a66fa0a1b479c")!
        signingOutput = AnySigner.sign(input: badInput, coin: .eos)
        XCTAssertFalse(signingOutput.error.isEmpty, "Expected error but signing suceeded!")
    }
}
