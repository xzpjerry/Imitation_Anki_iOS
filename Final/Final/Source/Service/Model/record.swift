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
    var stage : String!
    var learning_stage : Int!
    var due : Date!
    var success_answer : Double!
    var total_answer : Double!
    
    var interval : Int?
    var ease : Double?
    
    
    
    
    init(_ word : String, _ note : String) {
        self.word = word
        self.note = note
    }
    
    func study(performance_level : performance) {
        total_answer = total_answer + 1
        let learning_steps = (UserDefaults.standard.object(forKey: "new_card_step") as? Array<Int>) ?? [1, 10]
        
        if (stage == "New" || stage == "Relearning") {
            // new card or relearning a card
            if (performance_level == .bad) {
                learning_stage = 0
                due = Calendar.current.date(byAdding: .minute, value: 5, to: Date())
            } else {
                learning_stage = learning_stage + 1
                success_answer = success_answer + 1
                if (learning_stage == learning_steps.count) { // see it next day, learning process ended
                    interval = 1440 // 1 day
                    stage = "Learned"
                    due = Calendar.current.date(byAdding: .minute, value: interval!, to: Date())
                } else { // follow the interval user set
                    due = Calendar.current.date(byAdding: .minute, value: learning_steps[learning_stage], to: Date())
                }
            }
            
        } else {
            if (performance_level == .bad) {
                stage = "Relearning"
                learning_stage = 0
                due = Calendar.current.date(byAdding: .minute, value: 5, to: Date())
            } else {
                success_answer = success_answer + 1
                let success_rate = success_answer / total_answer
                ease = performance_level.new_ease(avg_ease: ease ?? 1.0, avg_success: success_rate)
                interval = Int(Double(interval!) * ease!)
                due = Calendar.current.date(byAdding: .minute, value: interval!, to: Date())
            }
        }
    }
}
