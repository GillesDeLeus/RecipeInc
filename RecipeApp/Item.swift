//
//  Item.swift
//  RecipeApp
//
//  Created by Gilles De Leus on 20/05/2026.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
