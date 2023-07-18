//
//  Menu.swift
//  POS
//
//  Created by Tayson Nguyen on 2019-04-23.
//  Copyright © 2019 TouchBistro. All rights reserved.
//

import Foundation
import BillKit

func category(_ category: String) -> (String, NSDecimalNumber) -> Item {
    return { name, price in
        return Item(name: name, category: category, price: price, isTaxExempt: false)
    }
}

let appetizers = category("Appetizers")
let mains = category("Mains")
let drinks = category("Drinks")
let alcohol = category("Alcohol")

let appetizersCategory = [
    appetizers("Nachos", 13.99),
    appetizers("Calamari", 11.99),
    appetizers("Caesar Salad", 10.99),
]

let mainsCategory = [
    mains("Burger", 9.99),
    mains("Hotdog", 3.99),
    mains("Pizza", 12.99),
]

let drinksCategory = [
    drinks("Water", 0),
    drinks("Pop", 2.00),
    drinks("Orange Juice", 3.00),
]

let alcoholCategory = [
    alcohol("Beer", 5.00),
    alcohol("Cider", 6.00),
    alcohol("Wine", 7.00),
]

let tax1 = BillItemTaxModel(label: "Tax 1 (5%)", amount: 5, isEnabled: true)
let tax2 = BillItemTaxModel(label: "Tax 2 (8%)", amount: 8, isEnabled: true)
let alcoholTax = BillItemTaxModel(label: "Alcohol Tax (10%)", amount: 10, isEnabled: true, appliedCategories: ["Alcohol"])

let discount5Dollars = DiscountModel(discountType: .amount, amount: 5, label: "$5.00", isEneabled: false)
let discount10Percent = DiscountModel(discountType: .percentage, amount: 10, label: "10%", isEneabled: false)
let discount20Percent = DiscountModel(discountType: .percentage, amount: 20, label: "20%", isEneabled: false)

var taxes: [BillItemTaxModel] = [
    tax1,
    tax2,
    alcoholTax,
]

var discounts: [DiscountModel] = [
    discount5Dollars,
    discount10Percent,
    discount20Percent,
]

var categories = [
    (name: "Appetizers", items: appetizersCategory),
    (name: "Mains", items: mainsCategory),
    (name: "Drinks", items: drinksCategory),
    (name: "Alcohol", items: alcoholCategory),
]
