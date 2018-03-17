// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import TrustKeystore
import BigInt

struct KNDraftExchangeTransaction {
  let from: KNToken
  let to: KNToken
  let amount: BigInt
  let maxDestAmount: BigInt
  let expectedRate: BigInt
  let minRate: BigInt?
  let gasPrice: BigInt?
  let gasLimit: BigInt?
}

extension KNDraftExchangeTransaction {
  func toTransaction(hash: String, fromAddr: Address, toAddr: Address, nounce: Int) -> Transaction {
    let localObject = LocalizedOperationObject(
      from: self.from.address,
      to: self.to.address,
      contract: nil,
      type: "",
      value: self.expectedRate.fullString(decimals: self.to.decimal),
      symbol: nil,
      name: nil,
      decimals: self.to.decimal
    )
    return Transaction(
      id: hash,
      blockNumber: 0,
      from: fromAddr.description,
      to: toAddr.description,
      value: self.amount.fullString(decimals: self.from.decimal),
      gas: self.gasLimit?.fullString(units: UnitConfiguration.gasPriceUnit) ?? "",
      gasPrice: self.gasPrice?.fullString(units: UnitConfiguration.gasPriceUnit) ?? "",
      gasUsed: self.gasLimit?.fullString(units: UnitConfiguration.gasPriceUnit) ?? "",
      nonce: "\(nounce)",
      date: Date(),
      localizedOperations: [localObject],
      state: .pending
    )
  }
}