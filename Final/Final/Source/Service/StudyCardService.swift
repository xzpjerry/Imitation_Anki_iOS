//
//  StudyCardService.swift
//  Final
//
//  Created by Dev on 11/20/17.
//  Copyright © 2017 Zippo Xie. All rights reserved.
//

import Foundation
import DateToolsSwift

enum performance {
    case bad
    case hard
    case good
    case easy
}

class StudyCardService {
    
    static var shared : StudyCardService {
        return StudyCardService()
    }
    
    func study(_ card : Card, with level : performance) {
        guard card.stage == "Learned" else {
            learn_new_or_relearn(card, level)
            return
        }
        
        review(card, level)
    }
    
    func humanized_interval(card : Card, level : performance) -> String {
        guard level != .bad else {
            return "1 min"
        }
        let raw_intervel = Int(get_interval(card: card, level: level))
        guard raw_intervel >= 1440 else {
            return "\(raw_intervel) min"
        }
        guard raw_intervel >= 43200 else {
            return "\(Int(raw_intervel/1440)) d"
        }
        return "\(Int(raw_intervel/43200)) m"
    }
    
    
    func get_interval(card : Card, level : performance) -> Double {
        guard card.stage == "Learned" else {
            let steps = UserDefaults.standard.object(forKey: "study_steps") as! Array<Int>
            let final_steps = steps.count - 1
            var next_step = Int(card.learning_stage)
            guard level != .easy && final_steps != 0 else {
                return Double(steps.last!)
            }
            if next_step > final_steps {
                // when user changed study steps and the current next_step is overflowed, he would have to go back to the first place
                next_step = 0
                card.learning_stage = 0
            }
            return Double(steps[next_step])
        }
        
        let interval = card.interval
        let ease = card.ease
        let d = abs(Date().timeIntervalSince(card.due!) / 60)
        
        let hard_i = max(interval + 1440, (interval + d/4))
        if level == .hard {
            return hard_i
        }
        
        let rease = ease / 1000
        let good_i = max(hard_i + 1440, (interval + d/2) * rease)
        if level == .good {
            return good_i
        }
        let easy_i = max(good_i + 1440, (interval + d) * rease)
        return easy_i
    }
    
    private func learn_new_or_relearn(_ card : Card, _ level : performance) {
        if card.stage == "Unseen"  {
            card.learning_stage = 0
            card.stage = "Learning"
        } else if card.stage == "Learned" {
            card.learning_stage = 0
            card.stage = "Relearning"
        }
        
        if level != .bad {
            card.success_study_times = card.success_study_times + 1
            card.total_study_times = card.total_study_times + 1
            card.interval = get_interval(card: card, level: level)
            
            if (Int(card.learning_stage) != ((UserDefaults.standard.object(forKey: "study_steps") as! Array<Int>).count-1)) {
                card.learning_stage = card.learning_stage + 1
                card.due = Calendar.current.date(byAdding: .minute, value: Int(card.interval), to: Date())
            }
            else {
                // learning stage will over after this time study
                // card's stage will graduate
                if card.stage == "Learning" {
                    card.stage = "Learned"
                    card.ease = 1000 // unit that measures user's command on this card, init at 1000
                    
                    let learned = UserDefaults.standard.integer(forKey: "learned_today")
                    UserDefaults.standard.set(learned + 1, forKey: "learned_today")
                    
                } else {
                    let m = UserDefaults.standard.double(forKey: "Interval_deduction_after_failure")
                    card.interval *= m
                    card.stage = "Learned"
                }
            card.due = Calendar.current.date(byAdding: .minute, value: Int(card.interval), to: Date())
            }
        } else {
            card.learning_stage = 0
            card.due = Calendar.current.date(byAdding: .minute, value: 5, to: Date())
            card.total_study_times = card.total_study_times + 1
        }
        
    }
    
    private func review(_ card : Card, _ level : performance) {
        guard level != .bad else {
            card.ease -= 200
            learn_new_or_relearn(card, level)
            return
        }
        
        let learned = UserDefaults.standard.integer(forKey: "learned_today")
        UserDefaults.standard.set(learned + 1, forKey: "learned_today")
        
        switch level {
        case .hard:
            card.ease -= 150
            card.interval = get_interval(card: card, level: .hard)
        case .good:
            card.interval = get_interval(card: card, level: .good)
        case .easy:
            card.ease = min(1300, card.ease + 150)
            card.interval = get_interval(card: card, level: .easy)
        default:
            NSLog("review function reaches at the bottom")
        }
        card.total_study_times += 1
        card.success_study_times += 1
        card.due = Calendar.current.date(byAdding: .minute, value: Int(card.interval), to: Date())
        card.due = Calendar.current.startOfDay(for: card.due!) // When reviewing a card, we don't need to be too strict about its time, but date matters.
    }
    
    
    
    
    private init() {
    }
}
