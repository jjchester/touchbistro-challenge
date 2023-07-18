//
//  DiscountModel.swift
//  POS
//
//  Created by Justin Chester on 2023-07-17.
//  Copyright © 2023 TouchBistro. All rights reserved.
//

import Foundation

public class DiscountModel {
    
    public enum DiscountType {
        case amount
        case percentage
    }
    
    let uid: String = UUID().uuidString
    public let discountType: DiscountType
    public let amount: NSDecimalNumber
    public let label: String
    public var isEnabled: Bool
    
    public init(discountType: DiscountType, amount: NSDecimalNumber, label: String, isEnabled: Bool) {
        self.discountType = discountType
        self.amount = amount
        self.label = label
        self.isEnabled = isEnabled
    }
}
