// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Result
import Moya
import JSONRPCKit
import APIKit
import BigInt
import QRCodeReaderViewController
import TrustKeystore

class KNGasCoordinator {

  enum KNGasNotificationKeys: String {
    case knGasPriceDidUpdateKey
    case knMaxGasPriceDidUpdateKey
  }

  static let shared: KNGasCoordinator = KNGasCoordinator()
  fileprivate let provider = MoyaProvider<KyberNetworkService>()

  lazy var numberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.minimumFractionDigits = 0
    formatter.maximumFractionDigits = 1
    return formatter
  }()

  var defaultKNGas: Double = 0.0
  var standardKNGas: Double = 0.0
  var lowKNGas: Double = 0.0
  var fastKNGas: Double = 0.0
  var maxKNGas: Double = 0.0

  fileprivate var maxKNGasPriceFetchTimer: Timer?
  fileprivate var isLoadingMaxKNGasPrice: Bool = false

  fileprivate var knGasPriceFetchTimer: Timer?
  fileprivate var isLoadingGasPrice: Bool = false

  init() {}

  func resume() {
    knGasPriceFetchTimer?.invalidate()
    isLoadingGasPrice = false
    fetchKNGasPrice(nil)

    knGasPriceFetchTimer = Timer.scheduledTimer(
      timeInterval: KNLoadingInterval.defaultLoadingInterval,
      target: self,
      selector: #selector(fetchKNGasPrice(_:)),
      userInfo: nil,
      repeats: true
    )

    maxKNGasPriceFetchTimer?.invalidate()
    isLoadingMaxKNGasPrice = false
    fetchKNMaxGasPrice(nil)

    maxKNGasPriceFetchTimer = Timer.scheduledTimer(
      timeInterval: KNLoadingInterval.defaultLoadingInterval,
      target: self,
      selector: #selector(fetchKNMaxGasPrice(_:)),
      userInfo: nil,
      repeats: true
    )
  }

  func pause() {
    knGasPriceFetchTimer?.invalidate()
    knGasPriceFetchTimer = nil
    isLoadingGasPrice = true

    maxKNGasPriceFetchTimer?.invalidate()
    maxKNGasPriceFetchTimer = nil
    isLoadingMaxKNGasPrice = true
  }

  @objc func fetchKNMaxGasPrice(_ sender: Timer?) {
    if isLoadingMaxKNGasPrice { return }
    isLoadingMaxKNGasPrice = true
    KNInternalProvider.shared.getKNCachedMaxGasPrice { [weak self] (result) in
      guard let `self` = self else { return }
      self.isLoadingMaxKNGasPrice = false
      if case .success(let data) = result {
        do {
          let dataString: String = try kn_cast(data["data"])
          self.maxKNGas = Double(dataString) ?? self.maxKNGas
          KNNotificationUtil.postNotification(for: KNGasNotificationKeys.knMaxGasPriceDidUpdateKey.rawValue)
        } catch {}
      }
    }
  }

  @objc func fetchKNGasPrice(_ sender: Timer?) {
    if isLoadingGasPrice { return }
    isLoadingGasPrice = true
    KNInternalProvider.shared.getKNCachedGasPrice { [weak self] (result) in
      guard let `self` = self else { return }
      self.isLoadingGasPrice = false
      if case .success(let data) = result {
        try? self.updateGasPrice(dataJSON: data)
      }
    }
  }

  fileprivate func updateGasPrice(dataJSON: JSONDictionary) throws {
    do {
      let stringDefault: String = try kn_cast(dataJSON["default"])
      self.defaultKNGas = Double(stringDefault) ?? self.defaultKNGas
      let stringLow: String = try kn_cast(dataJSON["low"])
      self.lowKNGas = Double(stringLow) ?? self.lowKNGas
      let stringStandard: String = try kn_cast(dataJSON["standard"])
      self.standardKNGas = Double(stringStandard) ?? self.standardKNGas
      let stringFast: String = try kn_cast(dataJSON["fast"])
      self.fastKNGas = Double(stringFast) ?? self.fastKNGas
    } catch {
      throw CastError(actualValue: String.self, expectedType: Double.self)
    }
    KNNotificationUtil.postNotification(for: KNGasNotificationKeys.knGasPriceDidUpdateKey.rawValue)
  }
}