//
//  StudyViewController.swift
//  Final
//
//  Created by Dev on 11/19/17.
//  Copyright © 2017 Zippo Xie. All rights reserved.
//

import UIKit
import CoreData

class StudyViewController: UIViewController {
    
    @IBOutlet weak var easy: UIButton!
    @IBOutlet weak var hard: UIButton!
    @IBOutlet weak var bad: UIButton!
    @IBOutlet weak var good: UIButton!
    @IBOutlet weak var buttonView : UIView!
    @IBOutlet weak var title_label : UILabel!
    @IBOutlet weak var note_text_view : UITextView!
    var current_card : Card?
    private var fetchedRC : NSFetchedResultsController<Card>!
    private var hard_is_hidden = false
    
    @IBAction func attest(_ sender: UIButton) {
        let level : performance!
        switch sender {
        case good:
            level = performance.good
        case bad:
            level = performance.bad
        case easy:
            level = performance.easy
        case hard:
            level = performance.hard
        default:
            level = performance.bad
            NSLog("function attest reached default switch, which should never happen.")
        }
        StudyCardService.shared.study(current_card!, with: level)
        featch_next()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        featch_next()
        super.viewWillAppear(animated)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapRecognizer = UITapGestureRecognizer()
        //tapRecognizer.cancelsTouchesInView = false
        tapRecognizer.addTarget(self, action: #selector(didTapView))
        self.view.addGestureRecognizer(tapRecognizer)
        // Do any additional setup after loading the view.
    }
    
    private func featch_next() {
        note_text_view.isHidden = true
        title_label.isHidden = true
        buttonView.isHidden = true
        if hard_is_hidden != true {
            hard.removeFromSuperview()
            hard_is_hidden = true
        }
        DispatchQueue.global().async {
            CardService.shared.saveContext(with: nil, by: self.current_card)
            self.fetchedRC = CardService.shared.find(before: CardService.allowed_foreseen_end_point, within: 1)
            DispatchQueue.main.async {
                self.current_card = self.fetchedRC.fetchedObjects?.first
                self.loadnotes()
            }
        }
    }
    
    private func loadnotes() {
        if let card = current_card {
            title_label.text = current_card?.title
            note_text_view.attributedText = card.note?.content as! NSAttributedString
            title_label.isHidden = false
            DispatchQueue.global().async {
                let good_time = StudyCardService.shared.humanized_interval(card: card, level: .good)
                let easy_time = StudyCardService.shared.humanized_interval(card: card, level: .easy)
                let bad_time = StudyCardService.shared.humanized_interval(card: card, level: .bad)
                DispatchQueue.main.async {
                    
                    self.bad.setAttributedTitle(NSAttributedString.init(string:"Bad\n\(bad_time)"), for: .normal)
                    
                    self.good.setAttributedTitle(NSAttributedString.init(string:"Good\n\(good_time)"), for: .normal)
                    
                    self.easy.setAttributedTitle(NSAttributedString.init(string: "Easy\n\(easy_time)") , for: .normal)
                    
                }
            }
            if card.stage == "Learned" && hard_is_hidden {
                buttonView.addSubview(hard)
                hard_is_hidden = false
                DispatchQueue.global().async {
                    let hard_time = StudyCardService.shared.humanized_interval(card: card, level: .hard)
                    DispatchQueue.main.async {
                        self.hard.setAttributedTitle(NSAttributedString.init(string: "Hard\n\(hard_time)") , for: .normal)
                    }
                }
            }
        } else {
            title_label.text = "Congratulations! You are all set for now!"
            title_label.isHidden = false
        }
    }

}

// didTapView for show the detail view of a card
extension StudyViewController {
    @objc
    func didTapView(){
        if current_card != nil {
            note_text_view.isHidden = false
            buttonView.isHidden = false
        }
    }
}
