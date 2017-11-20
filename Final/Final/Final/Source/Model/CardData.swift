//
//  Card_place_holder.swift
//  Final
//
//  Created by Zippo Xie on 11/18/17.
//  Copyright © 2017 Zippo Xie. All rights reserved.
//

import Foundation

class CardData {
    
    let created_time : Date!
    
    var interval : Double?
    var due : Date?
    var success_study_times : Double?
    var total_study_times : Double?
    
    let title : String!
    let first_letter : String!
    let stage : String!
    
    let unique : UUID!
    
    
    init () {
        created_time = Calendar.current.date(byAdding: .nanosecond, value: 0, to: Date())
        title = "New Card"
        stage = "Unseen"
        unique = UUID()
        first_letter = "N"
    }
}
