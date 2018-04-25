// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import Eureka
import StoreKit

protocol KNSettingsViewControllerDelegate: class {
  func settingsViewControllerDidClickExit()
  func settingsViewControllerBackUpButtonPressed()
  func settingsViewControllerWalletsButtonPressed()
  func settingsViewControllerPasscodeDidChange(_ isOn: Bool)
}

class KNSettingsViewController: FormViewController {

  fileprivate weak var delegate: KNSettingsViewControllerDelegate?
  fileprivate let address: String

  fileprivate var passcodeRow: SwitchRow!

  init(address: String, delegate: KNSettingsViewControllerDelegate?) {
    self.address = address
    self.delegate = delegate
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.setupUI()
  }

  fileprivate func setupUI() {
    self.setupNavigationBar()

    form = Form()
    +++ Section("Account")
    <<< AppFormAppearance.button { button in
      button.cellStyle = .value1
    }.onCellSelection { [unowned self] _, _ in
      self.delegate?.settingsViewControllerWalletsButtonPressed()
    }.cellUpdate { cell, _ in
      cell.textLabel?.textColor = .black
      cell.imageView?.image = UIImage(named: "settings_wallet")
      cell.textLabel?.text = "Wallets".toBeLocalised()
      cell.detailTextLabel?.text = String(self.address.prefix(16)) + "..."
      cell.accessoryType = .disclosureIndicator
    }
    <<< AppFormAppearance.button { button in
      button.cellStyle = .value1
    }.onCellSelection { [unowned self] _, _ in
      self.delegate?.settingsViewControllerBackUpButtonPressed()
    }.cellUpdate { cell, _ in
      cell.textLabel?.textColor = .black
      cell.imageView?.image = UIImage(named: "settings_export")
      cell.textLabel?.text = "Backup".toBeLocalised()
      cell.accessoryType = .disclosureIndicator
    }
    var securitySection = Section("Security")
    form += [securitySection]
    self.passcodeRow = SwitchRow("SwitchRow") {
      $0.title = "TouchID/FaceID/Passcode".toBeLocalised()
      $0.value = KNPasscodeUtil.shared.currentPasscode() != nil
    }.onChange { [unowned self] row in
      self.delegate?.settingsViewControllerPasscodeDidChange(row.value == true)
    }.cellSetup { cell, _ in
      cell.imageView?.image = UIImage(named: "settings_lock")
    }
    securitySection += [self.passcodeRow]

    form +++ Section()
    <<< TextRow {
      $0.title = "Version".toBeLocalised()
      $0.value = Bundle.main.fullVersion
      $0.disabled = true
    }
  }

  fileprivate func setupNavigationBar() {
    self.navigationItem.title = "History".toBeLocalised()
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Exit", style: .plain, target: self, action: #selector(self.exitButtonPressed(_:)))
    self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
  }

  @objc func exitButtonPressed(_ sender: Any) {
    self.delegate?.settingsViewControllerDidClickExit()
  }

  func userDidCancelCreatePasscode() {
    self.passcodeRow.value = false
    self.passcodeRow.updateCell()
  }
}