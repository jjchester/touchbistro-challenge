//
//  BillTotalsCalculator.swift
//  BillKit
//
//  Created by Justin Chester on 2023-07-17.
//

import Foundation

public class BillTotalsCalculator {
    
    public static let shared = BillTotalsCalculator()
    
    /**
    Returns an array of all taxes that apply to a given item
     - Parameter bill: A BillModel that contains the necessary bill items, taxes, and discounts for calculating the totals

     - Returns: A TotalsModel containing all of the calculated totals
     */
    public func calculateTotals(_ bill: BillModel) -> TotalsModel {
        let subtotal = calculateSubTotal(bill.items)
        let taxTotal = calculateTaxes(bill.taxes, items: bill.items)
        
        let postTaxSubtotal = subtotal.adding(taxTotal)
        let discountsTotal = calculateDiscountAmount(bill.discounts, subtotal: postTaxSubtotal)
        
        // If the discount amount is greater than the post-tax subtotal we most likely would not want to put
        // the total into negatives - set to 0 in this case
        let total = discountsTotal.compare(postTaxSubtotal) == .orderedDescending ? 0.00 : postTaxSubtotal.subtracting(discountsTotal)
        
        // We don't want to round anything inside the framework - different currencies have different decimal places
        // rounding, etc. which should be managed by whatever is using the framework. Framework should just return
        // totals with as much precision as possible
        let billTotal = TotalsModel(subtotal: subtotal, discountsTotal: discountsTotal, postTaxSubtotal: postTaxSubtotal, taxTotal: taxTotal, total: total)
        
        return billTotal
    }
    
    /**
    Calculates the sum of all taxes on the bill items
     - Parameter taxes: An array of all enabled taxes
     - Parameter items: An array of bill items
     
     - Returns: The total amount of taxes for the bill
     */
    internal func calculateTaxes(_ taxes: [BillItemTaxModel], items: [Item]) -> NSDecimalNumber {
        var taxTotal: NSDecimalNumber = 0.0
        for item in items {
            guard !item.isTaxExempt else { continue }
            let applicableTaxes = filterNonApplicableTaxes(item: item, taxes: taxes)
            for tax in applicableTaxes {
                // If tax is a percentage, perform tax/100*price, otherwise apply the tax as a flat amount
                let amount = tax.taxType == .percentage ? tax.amount.dividing(by: 100).multiplying(by: item.price) : tax.amount
                taxTotal = taxTotal.adding(amount)
            }
        }
        return taxTotal
    }
    
    /**
    Filters out taxes that do not apply to a provided item
     - Parameter item: The item that taxes are being calculated based on
     - Parameter taxes: An array of all enabled taxes
     
     - Returns: A filtered array of all taxes that apply to the provided item
     */
    internal func filterNonApplicableTaxes(item: Item, taxes: [BillItemTaxModel]) -> [BillItemTaxModel] {
        return taxes.filter {
            // If the taxs' appliedCategories is not set, we assume the tax applies to all items
            // if it is set, we check if the category applies to the current item
            guard $0.isEnabled else { return false }
            guard $0.appliedCategories != nil else { return true }
            return $0.appliedCategories!.contains(item.category)
        }
    }
    
    /**
    Calculates the subtotal from all item prices
     - Parameter items: An array of all items on the bill
     
     - Returns: The sum of all bill item prices
     */
    internal func calculateSubTotal(_ items: [Item]) -> NSDecimalNumber {
        var subtotal: NSDecimalNumber = 0.0
        for item in items {
            subtotal = subtotal.adding(item.price)
        }
        return subtotal
    }
    
    /**
    Calculates the total discount amount to be applied to the view
     - Parameter discounts: An array of discounts that are enabled
     - Parameter subtotal: The post-tax subtotal, necessary for properly applying discounts in order
     
     - Returns: The total discount amount to be subtracted from the order (and displayed on the bill)
     */
    internal func calculateDiscountAmount(_ discounts: [DiscountModel], subtotal: NSDecimalNumber) -> NSDecimalNumber {
        var currentTotal = subtotal
        var discountAmount: NSDecimalNumber = 0.0
        
        for discount in discounts {
            guard discount.isEnabled else { continue }
            // We need to track the current amount for each applied discount and subtract as each new discount is calculated
            // e.g. if we apply a 10% discount and then a 20% discount, the 20% discount should apply to the already discounted price
            let amount = discount.discountType == .percentage ? discount.amount.dividing(by: 100).multiplying(by: currentTotal) : discount.amount
            discountAmount = discountAmount.adding(amount)
            currentTotal = currentTotal.subtracting(amount)
        }
        
        return discountAmount
    }
}
