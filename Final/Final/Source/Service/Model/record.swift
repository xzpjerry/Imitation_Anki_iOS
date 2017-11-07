//
//  record.swift
//  Final
//
//  Created by Dev on 11/6/17.
//  Copyright © 2017 Dev. All rights reserved.
//

import Foundation

class record {
    var word : String!
    var note : String!
    var ease : Double?
    var due : Date?
    
    init(_ word : String, _ note : String) {
        self.word = word
        self.note = note
    }
}
