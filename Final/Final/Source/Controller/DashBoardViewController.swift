//
//  ViewController.swift
//  Final
//
//  Created by Dev on 11/6/17.
//  Copyright © 2017 Dev. All rights reserved.
//

import UIKit
import CoreData

class DashBoardViewController: UIViewController {
    
    @IBOutlet private weak var due_today : UILabel!
    @IBOutlet private weak var indicator : UIActivityIndicatorView!
    @IBOutlet var setting_button : UIBarButtonItem!
    @IBOutlet weak var study : UIButton!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "dash2study" else{
            super.prepare(for: segue, sender: sender)
            return
        }
        
        if let target = segue.destination as? Study_view_controller {
            let todays_words = CardService.shared.fetch_top_convenient()
            if (todays_words.count > 0) {
                target.all_clear = false
                target.buffer_card = todays_words.first
            } else {
                target.all_clear = true
            }
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
                self.due_today.text = "To study today: \(CardService.shared.fetch_top_convenient().count) cards."
                self.indicator.stopAnimating()
                self.navigationItem.rightBarButtonItem = self.setting_button
                self.study.isHidden = false
            }
        }
 
    }
    
    

}

