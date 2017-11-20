//
//  CardEditTableViewController.swift
//  Final
//
//  Created by Zippo Xie on 11/18/17.
//  Copyright © 2017 Zippo Xie. All rights reserved.
//

import UIKit
import CoreData

class CardEditTableViewController: UITableViewController {
    
    var fetchRC : NSFetchedResultsController<Card>!
    var selectedIndexPath : IndexPath!
    var selectedCard : Card!
    
    private var picker = UIImagePickerController()
    
    @IBOutlet weak var title_cell: titleTableViewCell!
    var textfield : UITextField!
    
    private func load_title_field() {
        textfield = title_cell.textfield
        textfield.text = selectedCard.title
        textfield.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.isHidden = true
        DispatchQueue.global().async {
            self.selectedCard = self.fetchRC.object(at: self.selectedIndexPath)
            DispatchQueue.main.async {
                self.tableView.isHidden = false
                self.load_title_field()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 45
        picker.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "edit_note" {
            if let dst = segue.destination as? NoteEditViewController {
                dst.selected_card = selectedCard
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0: // change badge image
            self.navigationController?.present(self.picker, animated: true, completion: nil)
        case 1: // change title
            textfield.becomeFirstResponder()
        default:
            NSLog("Swith to default")
        }
    }

}

// Image Picker Delegates
extension CardEditTableViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        selectedCard.badge = UIImagePNGRepresentation(image)
        DispatchQueue.global().async {
            CardService.shared.saveContext(by: self.selectedCard)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

// textfield Delegates
extension CardEditTableViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let new_title = textField.text {
            if new_title.count > 0 {
                selectedCard.title = new_title
                selectedCard.first_letter = "\(new_title.first!)"
                DispatchQueue.global().async {
                    CardService.shared.saveContext(by: self.selectedCard)
                }
            }
        }
        return true
    }
}
