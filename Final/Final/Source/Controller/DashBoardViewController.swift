//
//  ViewController.swift
//  Final
//
//  Created by Zippo Xie on 11/18/17.
//  Copyright © 2017 Zippo Xie. All rights reserved.
//

import UIKit

class DashBoardViewController: UIViewController {
    @IBOutlet weak var total_amaount_label : UILabel!
    @IBOutlet weak var review_amount_label : UILabel!
    @IBOutlet weak var relearn_amount_label : UILabel!
    @IBOutlet weak var new_today_amount_label : UILabel!
    @IBOutlet weak var navi_item : UINavigationItem!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        set_default_setting()
        DispatchQueue.global().async {
            let total = CardService.shared.total_amount
            let available_now = CardService.shared.available_now_amount
            let today_review = CardService.shared.review_totday_amount
            let today_new = CardService.shared.new_totday_amount
            let today_relearn = CardService.shared.relearn_totday_amount
            DispatchQueue.main.async {
                self.navi_item.title = "To do:\(available_now)"
                self.total_amaount_label.text = "Total card: \(total)"
                self.review_amount_label.text = "To review:\(today_review)"
                self.new_today_amount_label.text = "New today:\(today_new)"
                self.relearn_amount_label.text = "To relearn:\(today_relearn)"
            }
        }
    }
    
    private func set_default_setting() {
        if UserDefaults.standard.bool(forKey: "Not_First_time_running") == false {
            UserDefaults.standard.set(true, forKey: "Not_First_time_running")
            UserDefaults.standard.set(50, forKey: "max_study")
            UserDefaults.standard.set(30, forKey: "learn_ahead")
            UserDefaults.standard.set(0.6, forKey: "Interval_deduction_after_failure")
            UserDefaults.standard.set([1, 10, 1440], forKey: "study_steps")
        }
    }
}

