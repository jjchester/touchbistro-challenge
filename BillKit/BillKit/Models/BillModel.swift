//
//  Bill.swift
//  POS
//
//  Created by Justin Chester on 2023-07-17.
//  Copyright © 2023 TouchBistro. All rights reserved.
//

import Foundation

public struct BillModel {
    let items: [Item]
    let discounts: [DiscountModel]
    let taxes: [BillItemTaxModel]
    
    public init(items: [Item], discounts: [DiscountModel], taxes: [BillItemTaxModel]) {
        self.items = items
        self.discounts = discounts
        self.taxes = taxes
    }
}
