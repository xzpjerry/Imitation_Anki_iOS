//
//  ViewController.swift
//  Final
//
//  Created by Zippo Xie on 11/18/17.
//  Copyright © 2017 Zippo Xie. All rights reserved.
//

import UIKit

class DashBoardViewController: UIViewController {
    @IBOutlet weak var review_amount_label : UILabel!
    @IBOutlet weak var relearn_amount_label : UILabel!
    @IBOutlet weak var new_today_amount_label : UILabel!
    @IBOutlet weak var navi_item : UINavigationItem!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.global().async {
            let total = CardService.shared.total_amount
            let today_review = CardService.shared.review_totday_amount
            let today_new = CardService.shared.new_totday_amount
            let today_relearn = CardService.shared.relearn_totday_amount
            DispatchQueue.main.async {
                self.navi_item.title = "Total cards:\(total)"
                self.review_amount_label.text = "To review:\(today_review)"
                self.new_today_amount_label.text = "New today:\(today_new)"
                self.relearn_amount_label.text = "To relearn:\(today_relearn)"
            }
        }
        
        
    }
}

