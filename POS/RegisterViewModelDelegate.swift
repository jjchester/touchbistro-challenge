//
//  RegisterViewModelDelegate.swift
//  POS
//
//  Created by Justin Chester on 2023-07-17.
//  Copyright © 2023 TouchBistro. All rights reserved.
//

import Foundation

protocol RegisterViewModelDelegate: AnyObject {
    func calculateAndUpdateTotals()
}
