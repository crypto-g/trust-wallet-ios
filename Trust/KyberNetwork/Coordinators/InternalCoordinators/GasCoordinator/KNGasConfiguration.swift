// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import BigInt

public struct KNGasConfiguration {
  static let exchangeTokensGasLimitDefault = BigInt(330_000)
  static let transferTokenGasLimitDefault = BigInt(60_000)
  static let transferETHGasLimitDefault = BigInt(21_000)
  static let transferETHBuyTokenSaleGasLimitDefault = BigInt(120_000)

  static let gasPriceDefault: BigInt = EtherNumberFormatter.full.number(from: "12", units: UnitConfiguration.gasPriceUnit)!
  static let gasPriceMin: BigInt = EtherNumberFormatter.full.number(from: "2", units: UnitConfiguration.gasPriceUnit)!
  static let gasPriceMax: BigInt = EtherNumberFormatter.full.number(from: "20", units: UnitConfiguration.gasPriceUnit)!
}