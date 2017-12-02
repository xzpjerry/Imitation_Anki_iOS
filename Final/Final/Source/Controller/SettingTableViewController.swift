//
//  SettingTableViewController.swift
//  Final
//
//  Created by Zippo Xie on 11/20/17.
//  Copyright © 2017 Zippo Xie. All rights reserved.
//

import UIKit

class SettingTableViewController: UITableViewController {
    
    @IBOutlet private weak var max_card_cell: UITableViewCell! {didSet{max_card_field = max_card_cell.viewWithTag(998) as! UITextField }}
    private weak var max_card_field : UITextField!{didSet{max_card_field.text = "\(UserDefaults.standard.integer(forKey: "max_study"))"; max_card_field.delegate = self}}
    
    @IBOutlet private weak var new_card_steps_cell: UITableViewCell! {didSet{new_cards_step_field = new_card_steps_cell.viewWithTag(998) as! UITextField}}
    private weak var new_cards_step_field : UITextField!{didSet{new_cards_step_field.text = "\((UserDefaults.standard.object(forKey: "study_steps") as! Array<Int>).toPrint)"; new_cards_step_field.delegate = self}}
    
    @IBOutlet private weak var Learn_ahead_time_cell: UITableViewCell! {didSet{learn_ahead_field = Learn_ahead_time_cell.viewWithTag(998) as! UITextField }}
    private weak var learn_ahead_field : UITextField!{didSet{learn_ahead_field.text = "\(Int(UserDefaults.standard.double(forKey: "learn_ahead")))"; learn_ahead_field.delegate = self}}
    
    @IBOutlet private weak var failure_penalty_cell: UITableViewCell! {didSet{failure_penalty_field = failure_penalty_cell.viewWithTag(998) as! UITextField }}
    private weak var failure_penalty_field : UITextField!{didSet{failure_penalty_field.text = "\(Int(UserDefaults.standard.double(forKey: "Interval_deduction_after_failure") * 100))"; failure_penalty_field.delegate = self}}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.cancelsTouchesInView = false
        tapRecognizer.addTarget(self, action: #selector(didTapView))
        self.view.addGestureRecognizer(tapRecognizer)
    }

}

// tableview delegate
extension SettingTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row{
        case 0:
            max_card_field.becomeFirstResponder()
        case 1:
            new_cards_step_field.becomeFirstResponder()
        case 2:
            learn_ahead_field.becomeFirstResponder()
        case 3:
            failure_penalty_field.becomeFirstResponder()
        default:
            NSLog("select at somewhere has not been implemented yet.")
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

// didTapView for numberpad dismiss
extension SettingTableViewController {
    @objc
    func didTapView(){
        self.view.endEditing(true)
    }
}

// textfield Delegates
extension SettingTableViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case max_card_field:
            if let new_number = Int(max_card_field.text ?? "0") {
                UserDefaults.standard.set(new_number, forKey: "max_study")
            }
        case new_cards_step_field:
            UserDefaults.standard.set(new_cards_step_field.text?.toNumArray, forKey: "study_steps")
        case learn_ahead_field:
            if let new_number = Int(learn_ahead_field.text ?? "0") {
                UserDefaults.standard.set(new_number, forKey: "learn_ahead")
            }
        case failure_penalty_field:
            if let new_number = Int(failure_penalty_field.text ?? "0") {
                UserDefaults.standard.set(Double(new_number)/100, forKey: "Interval_deduction_after_failure")
            }
        default:
            NSLog("Textfielddidendediting reaches to default")
        }
    }
}

// for learn steps
extension Array {
    var toPrint: String  {
        var str = ""
        for element in self {
            str += "\(element) "
        }
        return str
    }
}
extension String {
    var toNumArray : Array<Int> {
        let numbersArray = self.components(separatedBy: " ").flatMap { Int($0) }
        guard numbersArray != [] else {
            return [1, 10, 1440]
        }
        return numbersArray
    }
}

