//
//  RegisterViewController.swift
//  POS
//
//  Created by Tayson Nguyen on 2019-04-23.
//  Copyright © 2019 TouchBistro. All rights reserved.
//

import UIKit
import BillKit
import Combine

class RegisterViewController: UIViewController, UINavigationControllerDelegate {
    let cellIdentifier = "Cell"
    
    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var orderTableView: UITableView!
    
    @IBOutlet weak var subtotalLabel: UILabel!
    @IBOutlet weak var discountsLabel: UILabel!
    @IBOutlet weak var taxLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    let viewModel = RegisterViewModel()
    let taxViewController = TaxViewController(style: .grouped)
    let discountViewController = DiscountViewController(style: .grouped)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuTableView.dataSource = self
        orderTableView.dataSource = self
        menuTableView.delegate = self
        orderTableView.delegate = self
        
        // Need to set self as the delegate for tax/discount VCs so the totals can be updated when dismissing the tax/discount modal
        taxViewController.delegate = self
        discountViewController.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction func showTaxes() {
        let vc = UINavigationController(rootViewController: taxViewController)
        vc.modalPresentationStyle = .formSheet
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func showDiscounts() {
        let vc = UINavigationController(rootViewController: discountViewController)
        vc.modalPresentationStyle = .formSheet
        present(vc, animated: true, completion: nil)
    }
    
    internal func calculateAndUpdateTotals() {
        let bill = BillModel(items: viewModel.orderItems, discounts: discounts.filter { $0.isEnabled }, taxes: taxes.filter { $0.isEnabled} )
        
        // Probably don't need to do this async but if you had a lot of items it might be slow enough to block UI
        DispatchQueue.global(qos: .userInitiated).async {
            let totals = BillTotalsCalculator.shared.calculateTotals(bill)
            DispatchQueue.main.async {
                self.subtotalLabel.text = NumberFormatter.localizedString(from: totals.subtotal, number: .currency)
                self.discountsLabel.text = NumberFormatter.localizedString(from: totals.discountsTotal, number: .currency)
                self.taxLabel.text = NumberFormatter.localizedString(from: totals.taxTotal, number: .currency)
                self.totalLabel.text = NumberFormatter.localizedString(from: totals.total, number: .currency)
            }
        }
    }
}

extension RegisterViewController: PresentedDelegate {
    func presentedDidDismiss() {
        calculateAndUpdateTotals()
    }
}

extension RegisterViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == menuTableView {
            return viewModel.menuCategoryTitle(in: section)
            
        } else if tableView == orderTableView {
            return viewModel.orderTitle(in: section)
        }
        
        fatalError()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == menuTableView {
            return viewModel.numberOfMenuCategories()
        } else if tableView == orderTableView {
            return 1
        }
        
        fatalError()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == menuTableView {
            return viewModel.numberOfMenuItems(in: section)
            
        } else if tableView == orderTableView {
            return viewModel.numberOfOrderItems(in: section)
        }
        
        fatalError()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ?? UITableViewCell(style: .value1, reuseIdentifier: cellIdentifier)
        
        if tableView == menuTableView {
            cell.textLabel?.text = viewModel.menuItemName(at: indexPath)
            cell.detailTextLabel?.text = viewModel.menuItemPrice(at: indexPath)
            
        } else if tableView == orderTableView {
            cell.textLabel?.text = viewModel.labelForOrderItem(at: indexPath)
            cell.detailTextLabel?.text = viewModel.orderItemPrice(at: indexPath)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == menuTableView {
            let indexPaths = [viewModel.addItemToOrder(at: indexPath)]
            orderTableView.insertRows(at: indexPaths, with: .automatic)
            calculateAndUpdateTotals()
        } else if tableView == orderTableView {
            viewModel.toggleTaxForOrderItem(at: indexPath)
            tableView.reloadRows(at: [indexPath], with: .automatic)
            calculateAndUpdateTotals()
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if tableView == menuTableView {
            return .none
        } else if tableView == orderTableView {
            return .delete
        }
        
        fatalError()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if tableView == orderTableView && editingStyle == .delete {
            viewModel.removeItemFromOrder(at: indexPath)
            orderTableView.deleteRows(at: [indexPath], with: .automatic)
            // calculate bill totals
            calculateAndUpdateTotals()
        }
    }
}


class RegisterViewModel: ObservableObject {
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()
    
    @Published var orderItems: [Item] = []
        
    func menuCategoryTitle(in section: Int) -> String? {
        return categories[section].name
    }
    
    func orderTitle(in section: Int) -> String? {
        return "Bill"
    }
    
    func numberOfMenuCategories() -> Int {
        return categories.count
    }
    
    func numberOfMenuItems(in section: Int) -> Int {
        return categories[section].items.count
    }
    
    func numberOfOrderItems(in section: Int) -> Int {
        return orderItems.count
    }
    
    func menuItemName(at indexPath: IndexPath) -> String? {
        return categories[indexPath.section].items[indexPath.row].name
    }
    
    func menuItemPrice(at indexPath: IndexPath) -> String? {
        let price = categories[indexPath.section].items[indexPath.row].price
        return formatter.string(from: price)
    }
    
    func labelForOrderItem(at indexPath: IndexPath) -> String? {
        let item = orderItems[indexPath.row]
       
        if item.isTaxExempt {
            return "\(item.name) (No Tax)"
        } else {
            return item.name
        }
    }
    
    func orderItemPrice(at indexPath: IndexPath) -> String? {
        let price = orderItems[indexPath.row].price
        return formatter.string(from: price)
    }
    
    func addItemToOrder(at indexPath: IndexPath) -> IndexPath {
        let item = categories[indexPath.section].items[indexPath.row]
        orderItems.append(item)
        return IndexPath(row: orderItems.count - 1, section: 0)
    }
    
    func removeItemFromOrder(at indexPath: IndexPath) {
        orderItems.remove(at: indexPath.row)
    }
    
    func toggleTaxForOrderItem(at indexPath: IndexPath) {
        orderItems[indexPath.row].isTaxExempt = !orderItems[indexPath.row].isTaxExempt
    }
}
