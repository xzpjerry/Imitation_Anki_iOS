//
//  performance.swift
//  Final
//
//  Created by Dev on 11/11/17.
//  Copyright © 2017 Dev. All rights reserved.
//

import Foundation

enum performance : Int {
    case good = 2
    case hard = 1
    case bad = 0
    
    func new_ease(avg_ease : Double, avg_success : Double) -> Double {
        let adjustment_constent : Double!
        switch self {
        case .bad:
            adjustment_constent = 0.6
        case .hard:
            adjustment_constent = 0.85
        case .good:
            adjustment_constent = 1
        }
        return avg_ease * (log(adjustment_constent)/log(avg_success))
    }
    
}
