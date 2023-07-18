//
//  TotalsModel.swift
//  BillKit
//
//  Created by Justin Chester on 2023-07-17.
//

import Foundation

public struct TotalsModel {
    public let subtotal: NSDecimalNumber
    public let discountsTotal: NSDecimalNumber
    public let taxTotal: NSDecimalNumber
    public let total: NSDecimalNumber
    public let postTaxSubtotal: NSDecimalNumber
    
    init(subtotal: NSDecimalNumber, discountsTotal: NSDecimalNumber, postTaxSubtotal: NSDecimalNumber, taxTotal: NSDecimalNumber, total: NSDecimalNumber) {
        self.subtotal = subtotal
        self.discountsTotal = discountsTotal
        self.postTaxSubtotal = postTaxSubtotal
        self.taxTotal = taxTotal
        self.total = total
    }
}
