//
//  TaxViewController.swift
//  POS
//
//  Created by Tayson Nguyen on 2019-04-29.
//  Copyright © 2019 TouchBistro. All rights reserved.
//

import Foundation
import UIKit
import BillKit

class TaxViewController: UITableViewController {
    let cellIdentifier = "Cell"
    let uuid: String = UUID().uuidString
    let viewModel = TaxViewModel()
    
    weak var delegate: PresentedDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Taxes"
        let button = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        navigationItem.rightBarButtonItem = button
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        delegate?.presentedDidDismiss()
    }
    
    @objc func done() {
        dismiss(animated: true, completion: nil)
    }
}

extension TaxViewController {
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.title(for: section)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ?? UITableViewCell(style: .value1, reuseIdentifier: cellIdentifier)
        
        cell.textLabel?.text = viewModel.labelForTax(at: indexPath)
        cell.accessoryType = viewModel.accessoryType(at: indexPath)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.toggleTax(at: indexPath)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

class TaxViewModel {
    
    var allTaxes: [BillItemTaxModel]
    
    init(allTaxes: [BillItemTaxModel]? = nil) {
        self.allTaxes = allTaxes ?? taxes
    }
    
    func title(for section: Int) -> String {
        return "Taxes"
    }
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfRows(in section: Int) -> Int {
        return allTaxes.count
    }
    
    func labelForTax(at indexPath: IndexPath) -> String {
        let tax = allTaxes[indexPath.row]
        return tax.label
    }
    
    func accessoryType(at indexPath: IndexPath) -> UITableViewCell.AccessoryType {
        let tax = allTaxes[indexPath.row]
        if tax.isEnabled {
            return .checkmark
        } else {
            return .none
        }
    }
    
    func toggleTax(at indexPath: IndexPath) {
        allTaxes[indexPath.row].isEnabled = !allTaxes[indexPath.row].isEnabled
    }
}
