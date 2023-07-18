//
//  BillItemTaxModel.swift
//  POS
//
//  Created by Justin Chester on 2023-07-17.
//  Copyright © 2023 TouchBistro. All rights reserved.
//

import Foundation

public class BillItemTaxModel {
    
    // This will almost always be a percentage but there are rare cases where a tax can be a flat rate amount (e.g. Chicago Bag Tax)
    public enum TaxType {
        case amount
        case percentage
    }
    
    let uid: String = UUID().uuidString
    public let label: String
    public let amount: NSDecimalNumber
    public var isEnabled: Bool
    public let taxType: TaxType
    public let appliedCategories: [String]?
    
    public init(label: String, amount: NSDecimalNumber, isEnabled: Bool, taxType: TaxType = .percentage, appliedCategories: [String]? = nil) {
        self.label = label
        self.amount = amount
        self.isEnabled = isEnabled
        self.taxType = taxType
        self.appliedCategories = appliedCategories
    }
}
