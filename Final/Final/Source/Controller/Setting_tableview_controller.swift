//
//  Setting_tableview_controller.swift
//  Final
//
//  Created by Dev on 11/10/17.
//  Copyright © 2017 Dev. All rights reserved.
//

import UIKit

class Setting_tableview_controller : UITableViewController {
    
    @IBOutlet weak var max_study : UILabel!
    
    weak var delegate : navi_back_delegate?
    
    
    var actionMap: [[(_ selectedIndexPath: IndexPath) -> Void]] {
        return [
            // Alert style alerts.
            [
                showTextEntryAlert
            ]
        ]
    }
    
    // Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        update_label()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let delegate = self.delegate {
            delegate.pushed_view_will_disappera(a_view: self)
        }
    }
    
    // update label
    func update_label() {
        max_study.text = "\(UserDefaults.standard.integer(forKey: "max_study"))"
    }
    
    /// Show a text entry alert with two custom buttons.
    func showTextEntryAlert(_: IndexPath) {
        let title = NSLocalizedString("Maximum card per day", comment: "")
        let message = NSLocalizedString("The more is not always the better.", comment: "")
        let cancelButtonTitle = NSLocalizedString("Cancel", comment: "")
        let otherButtonTitle = NSLocalizedString("OK", comment: "")
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Add the text field for text entry.
        alertController.addTextField { textField in
            // If you need to customize the text field, you can do so here.
            textField.keyboardType = UIKeyboardType.numberPad
        }
        
        // Create the actions.
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel) { _ in
            NSLog("The \"Text Entry\" alert's cancel action occured.")
        }
        
        let otherAction = UIAlertAction(title: otherButtonTitle, style: .default) { _ in
            if let value = alertController.textFields![0].text {
                if let setting_num = Int(value) {
                    UserDefaults.standard.set(setting_num, forKey: "max_study")
                    self.update_label()
                }
            }
            NSLog("The \"Text Entry\" alert's other action occured.")
            
        }
        
        // Add the actions.
        alertController.addAction(cancelAction)
        alertController.addAction(otherAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let action = actionMap[indexPath.section][indexPath.row]
        
        action(indexPath)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
