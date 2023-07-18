//
//  BillKitTests.swift
//  BillKitTests
//
//  Created by Justin Chester on 2023-07-17.
//

import XCTest
@testable import BillKit

final class BillKitTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCalculateTaxesWithMultipleTaxesAppliesCorrectly() throws {
        let taxes: [BillItemTaxModel] = [
            BillItemTaxModel(label: "Test Tax", amount: 10, isEnabled: true),
            BillItemTaxModel(label: "Test Tax 2", amount: 20, isEnabled: true)
        ]
        let items: [Item] = [
            Item(name: "Test Item 1", category: "Test Category", price: 12.99, isTaxExempt: false)
        ]
        
        let expectedTaxes: NSDecimalNumber = (NSDecimalNumber(12.99).multiplying(by: 0.1))
            .adding(NSDecimalNumber(12.99).multiplying(by: 0.2))
        
        let taxTotal = BillTotalsCalculator.shared.calculateTaxes(taxes, items: items)
        
        XCTAssertEqual(taxTotal, expectedTaxes)
    }
    
    func testCalculateTaxesWithTaxExemptItemDoesNotApplyTaxes() throws {
        let taxes: [BillItemTaxModel] = [
            BillItemTaxModel(label: "Test Tax", amount: 10, isEnabled: true),
            BillItemTaxModel(label: "Test Tax 2", amount: 20, isEnabled: true)
        ]
        let items: [Item] = [
            Item(name: "Test Item 1", category: "Test Category", price: 12.99, isTaxExempt: true)
        ]
        
        let expectedTaxes: NSDecimalNumber = 0.0
        
        let taxTotal = BillTotalsCalculator.shared.calculateTaxes(taxes, items: items)
        
        XCTAssertEqual(taxTotal, expectedTaxes)
    }
    
    func testCalculateTaxesDoesNotApplyDisabledTaxes() throws {
        let taxes: [BillItemTaxModel] = [
            BillItemTaxModel(label: "Test Tax", amount: 10, isEnabled: true),
            BillItemTaxModel(label: "Test Tax 2", amount: 20, isEnabled: false)
        ]
        let items: [Item] = [
            Item(name: "Test Item 1", category: "Test Category", price: 12.99, isTaxExempt: false)
        ]
        
        let expectedTaxes = NSDecimalNumber(12.99).multiplying(by: 0.1)
        
        let taxTotal = BillTotalsCalculator.shared.calculateTaxes(taxes, items: items)
        
        XCTAssertEqual(taxTotal, expectedTaxes)
    }
    
    func testCalculateTaxesWithMixedTaxExemptStatusItemsAppliesTaxesCorrectly() throws {
        let taxes: [BillItemTaxModel] = [
            BillItemTaxModel(label: "Test Tax", amount: 10, isEnabled: true),
            BillItemTaxModel(label: "Test Tax 2", amount: 20, isEnabled: true)
        ]
        let items: [Item] = [
            Item(name: "Test Item 1", category: "Test Category", price: 12.99, isTaxExempt: true),
            Item(name: "Test Item 2", category: "Test Category", price: 22.99, isTaxExempt: false)
        ]
        
        let expectedTaxes: NSDecimalNumber = (NSDecimalNumber(22.99).multiplying(by: 0.1))
            .adding(NSDecimalNumber(22.99).multiplying(by: 0.2))
        
        let taxTotal = BillTotalsCalculator.shared.calculateTaxes(taxes, items: items)
        
        XCTAssertEqual(taxTotal, expectedTaxes)
    }
    
    func testCalculateTaxesWithTaxCategoryOnlyAppliesToMatchingItems() throws {
        let taxes: [BillItemTaxModel] = [
            BillItemTaxModel(label: "Test Tax", amount: 10, isEnabled: true, appliedCategories: ["Alcohol"]),
            BillItemTaxModel(label: "Test Tax 2", amount: 20, isEnabled: true)
        ]
        let items: [Item] = [
            Item(name: "Test Item 1", category: "Test Category", price: 12.99, isTaxExempt: true),
            Item(name: "Test Item 2", category: "Alcohol", price: 22.99, isTaxExempt: false)
        ]
            
        let expectedTaxes: NSDecimalNumber = (NSDecimalNumber(22.99).multiplying(by: 0.1))
            .adding(NSDecimalNumber(22.99).multiplying(by: 0.2))
        
        let taxTotal = BillTotalsCalculator.shared.calculateTaxes(taxes, items: items)
        
        XCTAssertEqual(taxTotal, expectedTaxes)
    }
    
    func testFilterNonApplicableTaxesFiltersNonApplicableTaxes() throws {
        let taxes: [BillItemTaxModel] = [
            BillItemTaxModel(label: "Test Tax", amount: 10, isEnabled: true, appliedCategories: ["Alcohol"]),
            BillItemTaxModel(label: "Test Tax", amount: 15, isEnabled: true, appliedCategories: ["Mains"]),
            BillItemTaxModel(label: "Test Tax 2", amount: 20, isEnabled: true)
        ]
        let item = Item(name: "Test Item 2", category: "Alcohol", price: 22.99, isTaxExempt: false)
        
        let filteredTaxes = BillTotalsCalculator.shared.filterNonApplicableTaxes(item: item, taxes: taxes)
        
        XCTAssertEqual(filteredTaxes.count, 2)
        XCTAssert(!filteredTaxes.contains(where: { tax in
            tax.appliedCategories == ["Mains"]
        }))
        XCTAssert(filteredTaxes.contains(where: { tax in
            tax.appliedCategories == ["Alcohol"]
        }))
    }
    
    func testCalculateSubtotal() throws {
        let items: [Item] = [
            Item(name: "Test Item 1", category: "Test Category 1", price: 12.99, isTaxExempt: false),
            Item(name: "Test Item 2", category: "Test Category 1", price: 22.99, isTaxExempt: false),
            Item(name: "Test Item 2", category: "Test Category 1", price: 3.98, isTaxExempt: false)
        ]
        
        let subtotal = BillTotalsCalculator.shared.calculateSubTotal(items)
        
        XCTAssertEqual(subtotal, NSDecimalNumber(39.96))
    }
    
    func testCalculateDiscountAmountWithMixedDiscountTypesCalculatesInCorrectOrder() throws {
        let discounts: [DiscountModel] = [
            DiscountModel(discountType: .amount, amount: 5, label: "$5 Discount", isEnabled: true),
            DiscountModel(discountType: .percentage, amount: 10, label: "10% Discount", isEnabled: true),
            DiscountModel(discountType: .amount, amount: 2, label: "$2 Discount", isEnabled: true)
        ]
        
        let subTotal = NSDecimalNumber(20.99)
        let expectedDiscount = NSDecimalNumber(0)
            .adding(5)
            .adding(subTotal.subtracting(5).multiplying(by: 0.1))
            .adding(2)
        
        let discountTotal = BillTotalsCalculator.shared.calculateDiscountAmount(discounts, subtotal: subTotal)
        
        XCTAssertEqual(expectedDiscount, discountTotal)
    }
    
    func testCalculateDiscountAmountWithDiscountsInDifferentOrderGivesDifferentResult() throws {
        var discounts: [DiscountModel] = [
            DiscountModel(discountType: .amount, amount: 5, label: "$5 Discount", isEnabled: true),
            DiscountModel(discountType: .percentage, amount: 10, label: "10% Discount", isEnabled: true),
            DiscountModel(discountType: .amount, amount: 2, label: "$2 Discount", isEnabled: true)
        ]
        
        var subTotal = NSDecimalNumber(20.99)
        let expectedDiscount1 = NSDecimalNumber(0)
            .adding(5)
            .adding(subTotal.subtracting(5).multiplying(by: 0.1))
            .adding(2)
        
        let discountTotal1 = BillTotalsCalculator.shared.calculateDiscountAmount(discounts, subtotal: subTotal)
        
        discounts = [
            DiscountModel(discountType: .percentage, amount: 10, label: "10% Discount", isEnabled: true),
            DiscountModel(discountType: .amount, amount: 5, label: "$5 Discount", isEnabled: true),
            DiscountModel(discountType: .amount, amount: 2, label: "$2 Discount", isEnabled: true)
        ]
        
        subTotal = NSDecimalNumber(20.99)
        let expectedDiscount2 = NSDecimalNumber(0)
            .adding(subTotal.multiplying(by: 0.1))
            .adding(5)
            .adding(2)
        
        let discountTotal2 = BillTotalsCalculator.shared.calculateDiscountAmount(discounts, subtotal: subTotal)
        
        XCTAssertNotEqual(discountTotal1, discountTotal2)
        XCTAssertEqual(discountTotal1, expectedDiscount1)
        XCTAssertEqual(discountTotal2, expectedDiscount2)
    }
    
    func testCalculateDiscountAmountDoesNotApplyDisabledDiscounts() throws {
        let discounts: [DiscountModel] = [
            DiscountModel(discountType: .amount, amount: 5, label: "$5 Discount", isEnabled: true),
            DiscountModel(discountType: .percentage, amount: 10, label: "10% Discount", isEnabled: false),
            DiscountModel(discountType: .amount, amount: 2, label: "$2 Discount", isEnabled: true)
        ]
        
        let subTotal = NSDecimalNumber(20.99)
        let expectedDiscount = NSDecimalNumber(0)
            .adding(5)
            .adding(2)
        
        let discountTotal = BillTotalsCalculator.shared.calculateDiscountAmount(discounts, subtotal: subTotal)
        
        XCTAssertEqual(expectedDiscount, discountTotal)
    }
    
    func testCalculateTotals() throws {
        let items: [Item] = [
            Item(name: "Test Item 1", category: "Test Category 1", price: 12.99, isTaxExempt: false),
            Item(name: "Test Item 2", category: "Alcohol", price: 22.99, isTaxExempt: false),
            Item(name: "Test Item 2", category: "Test Category 1", price: 3.98, isTaxExempt: false)
        ]
        let taxes: [BillItemTaxModel] = [
            BillItemTaxModel(label: "Test Tax", amount: 10, isEnabled: true, appliedCategories: ["Alcohol"]),
            BillItemTaxModel(label: "Test Tax 2", amount: 20, isEnabled: true)
        ]
        let discounts: [DiscountModel] = [
            DiscountModel(discountType: .amount, amount: 5, label: "$5 Discount", isEnabled: true),
            DiscountModel(discountType: .percentage, amount: 10, label: "10% Discount", isEnabled: true),
            DiscountModel(discountType: .amount, amount: 2, label: "$2 Discount", isEnabled: true)
        ]
        
        let bill = BillModel(items: items, discounts: discounts, taxes: taxes)
        
        let totals = BillTotalsCalculator.shared.calculateTotals(bill)
        
        let expectedTaxTotal = NSDecimalNumber(39.96)
            .multiplying(by: 0.2)
            .adding(NSDecimalNumber(22.99)
            .multiplying(by: 0.1))
        
        let expectedSubtotal = NSDecimalNumber(39.96)
        let expectedPostTaxSubtotal = expectedSubtotal.adding(expectedTaxTotal)
        
        let expectedDiscountTotal = NSDecimalNumber(0)
            .adding(5)
            .adding(expectedPostTaxSubtotal.subtracting(5).multiplying(by: 0.1))
            .adding(2)
        
        let expectedTotal = expectedPostTaxSubtotal.subtracting(expectedDiscountTotal)
        
        XCTAssertEqual(totals.taxTotal, expectedTaxTotal)
        XCTAssertEqual(totals.discountsTotal, expectedDiscountTotal)
        XCTAssertEqual(totals.subtotal, expectedSubtotal)
        XCTAssertEqual(totals.postTaxSubtotal, expectedPostTaxSubtotal)
        XCTAssertEqual(totals.total, expectedTotal)
    }
}
