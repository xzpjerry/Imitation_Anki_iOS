//
//  Study_view_controller.swift
//  Final
//
//  Created by Dev on 11/12/17.
//  Copyright © 2017 Dev. All rights reserved.
//

import UIKit

class Study_view_controller : UIViewController{
    var all_clear : Bool!
    var buffer_card : record!
    @IBOutlet weak var good : UIButton!
    @IBOutlet weak var hard : UIButton!
    @IBOutlet weak var bad : UIButton!
    @IBOutlet weak var turn_over : UIButton!
    @IBOutlet weak var word : UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard all_clear == false else {
            good.isHidden = true
            bad.isHidden = true
            turn_over.isHidden = true
            word.text = "Congratulation! You are all clear for now."
            return
        }
        word.text = buffer_card.word
        
    }
    
    @IBAction func perform_tap(_ sender: Any) {
        guard let button = sender as? UIButton else {
            return
        }
        
        let current_card = buffer_card
        switch button {
        case good:
            NSLog("good")
            current_card?.study(performance_level: .good)
        case hard:
            NSLog("hard")
            buffer_card.study(performance_level: .hard)
            
        case bad:
            NSLog("bad")
            buffer_card.study(performance_level: .bad)
        case turn_over:
            NSLog("turn over")
            // make notes visable or hidden
        default:
            NSLog("THis line should never excute")
        }
        CardService.shared.modify(a_record: buffer_card, with: current_card!)
        let todays_cards = CardService.shared.fetch_top_convenient()
        if todays_cards.count > 0 {
            // assign new card
        } else {
            // hide buttons and give info "All clear"
        }
    }
}
