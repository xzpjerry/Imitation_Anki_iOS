//
//  ViewController.swift
//  Final
//
//  Created by Dev on 11/6/17.
//  Copyright © 2017 Dev. All rights reserved.
//

import UIKit
import CoreData

class DashBoardViewController: UIViewController, navi_back_delegate {
    
    @IBOutlet weak var due_today : UILabel!
    @IBOutlet weak var indicator : UIActivityIndicatorView!
    @IBOutlet var setting_button : UIBarButtonItem!
    @IBOutlet weak var study : UIButton!
    
    func pushed_view_will_disappera(a_view: Setting_tableview_controller) {
        let due_amount = CardService.shared.todays_card!
        due_today.text = "To study today: \(due_amount) cards."
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let target = segue.destination as? Setting_tableview_controller {
            target.delegate = self
        }
        else if let target = segue.destination as? Study_view_controller
        {
            if let todays_words = CardService.shared.todays_card
            {
                if (todays_words > 0)
                {
                    target.all_clear = false
                    target.buffer_card = CardService.shared.fetch_top_convenient()
                }
                else
                {
                    target.all_clear = true
                }
            }
        }
        else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicator.startAnimating()
        self.navigationItem.rightBarButtonItem = nil
        self.study.isHidden = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            _ = CardService.shared
            DispatchQueue.main.async {
                self.due_today.text = "To study today: \(CardService.shared.todays_card!) cards."
                self.indicator.stopAnimating()
                self.navigationItem.rightBarButtonItem = self.setting_button
                self.study.isHidden = false
            }
        }
 
    }
    
    

}

