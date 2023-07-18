//
//  POSTests.swift
//  POSTests
//
//  Created by Tayson Nguyen on 2019-04-23.
//  Copyright © 2019 TouchBistro. All rights reserved.
//

import XCTest
import BillKit

@testable import POS

class POSTests: XCTestCase {
    
    var taxVM: TaxViewModel = TaxViewModel()
    let taxArray: [BillItemTaxModel] = [
        BillItemTaxModel(label: "Test Tax", amount: 10, isEnabled: true),
        BillItemTaxModel(label: "Test Tax 2", amount: 15, isEnabled: false),
        BillItemTaxModel(label: "Test Tax 3", amount: 20, isEnabled: true)
    ]
    
    override func setUp() {
        taxVM = TaxViewModel(allTaxes: taxArray)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testTitleReturningCorrectString() throws {
        let title = taxVM.title(for: 0)
        XCTAssertEqual(title, "Taxes")
    }
    
    func testNumberOfSections() throws {
        let num = taxVM.numberOfSections()
        XCTAssertEqual(num, 1)
    }
    
    func testNumberOfRows() throws {
        let num = taxVM.numberOfRows(in: 0)
        XCTAssertEqual(num, taxes.count)
    }
    
    func testLabelForTax() throws {
        let indexPath = IndexPath(row: 1, section: 0)
        taxVM.allTaxes = taxArray
        
        let label = taxVM.labelForTax(at: indexPath)
        
        XCTAssertEqual("Test Tax 2", label)
    }
    
    func testAccessoryType() throws {
        var indexPath = IndexPath(row: 0, section: 0)
        var accessory = taxVM.accessoryType(at: indexPath)
        XCTAssertEqual(accessory, .checkmark)
        
        indexPath = IndexPath(row: 1, section: 0)
        accessory = taxVM.accessoryType(at: indexPath)
        XCTAssertEqual(accessory, .none)
    }
    
    func testToggleTax() throws {
        let indexPath = IndexPath(row: 0, section: 0)
        XCTAssertEqual(taxVM.allTaxes[indexPath.row].isEnabled, true)
        taxVM.toggleTax(at: indexPath)
        XCTAssertEqual(taxVM.allTaxes[indexPath.row].isEnabled, false)
    }
}
