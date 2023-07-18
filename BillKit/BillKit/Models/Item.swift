//
//  Item.swift
//  BillKit
//
//  Created by Justin Chester on 2023-07-17.
//

import Foundation

public class Item {
    let uuid: String = UUID().uuidString
    public let name: String
    public let category: String
    public let price: NSDecimalNumber
    public var isTaxExempt: Bool
    
    public init(name: String, category: String, price: NSDecimalNumber, isTaxExempt: Bool) {
        self.name = name
        self.category = category
        self.price = price
        self.isTaxExempt = isTaxExempt
    }
}
