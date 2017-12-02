//
//  Card_place_holder.swift
//  Final
//
//  Created by Zippo Xie on 11/18/17.
//  Copyright © 2017 Zippo Xie. All rights reserved.
//

import Foundation
import CoreData

class CardData {
    
    let created_time : Date!
    var due : Date?
    
    var interval : Double!
    var success_study_times : Double!
    var total_study_times : Double!
    var learning_stage : Double!
    var ease : Double!
    
    let title : String!
    let first_letter : String!
    let stage : String!
    
    let unique : UUID!
    
    
    init (title : String = "New Card", created_time : Date = Calendar.current.date(byAdding: .nanosecond, value: 0, to: Date())!, stage : String = "Unseen", success_study_times : Double = 0, total_study_times : Double = 0, learning_stage : Double = 0, interval : Double = -1, ease : Double = -1, unique : UUID = UUID(), due : Date? = nil) {
        self.created_time = created_time
        self.title = title
        self.stage = stage
        self.success_study_times = success_study_times
        self.total_study_times = total_study_times
        self.learning_stage = learning_stage
        self.interval = interval
        self.ease = ease
        self.unique = unique
        first_letter = "\(title.first!).".uppercased()
        
        if due != nil {
            self.due = due
        }
    }
    
    func Card_gen(in context : NSManagedObjectContext) -> Card {
        let tmp_card = Card(context: context)
        if due != nil {
            tmp_card.due = due
        } else {
            tmp_card.due = Date.distantFuture
        }

        tmp_card.interval = interval
        tmp_card.ease = ease
        tmp_card.learning_stage = learning_stage
        tmp_card.title = title
        tmp_card.created_time = created_time
        tmp_card.total_study_times = total_study_times
        tmp_card.success_study_times = success_study_times
        tmp_card.stage = stage
        tmp_card.unique = unique
        tmp_card.first_letter = first_letter
        return tmp_card
    }
}
