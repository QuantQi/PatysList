//
//  ItemModel.swift
//  PatysList
//
//  Created by So C on 10/09/2024.
//

import Foundation


struct ItemType: Identifiable {
    var id = UUID()
    var timestamp:Date
    var name: String
    var quantity: String
    var checked: Bool = false
    var indexVal:Int
}
