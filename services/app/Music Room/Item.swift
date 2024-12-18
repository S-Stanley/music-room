//
//  Item.swift
//  Music Room
//
//  Created by Nathan Bechon on 12/12/2024.
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
