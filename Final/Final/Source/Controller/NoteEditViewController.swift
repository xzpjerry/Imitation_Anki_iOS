//
//  NoteEditViewController.swift
//  Final
//
//  Created by Dev on 11/19/17.
//  Copyright © 2017 Zippo Xie. All rights reserved.
//

import UIKit
import CoreData

class NoteEditViewController: UIViewController {
    
    @IBOutlet weak var note_text_view : UITextView!
    @IBOutlet weak var placeholder_label : UILabel!
    
    var selected_card : Card!
    var its_note : Note!
    var txtBody : NSAttributedString!
    
    private var picker = UIImagePickerController()
    
    @IBAction private func addImage() {
        self.navigationController?.present(self.picker, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "audiochecker" else {
            super.prepare(for: segue, sender: sender)
            return
        }
        let dst = segue.destination as! AudioCheckerViewController
        dst.mycard = selected_card
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        its_note = selected_card.note!
        txtBody = its_note.content as! NSAttributedString
        note_text_view.attributedText = txtBody
        placeholder_label.isHidden = txtBody.length == 0 ? false : true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        note_text_view.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(updateTextView(notification:)), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTextView(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        its_note.content = note_text_view.attributedText
        DispatchQueue.global().async {
            CardService.shared.saveContext(by: self.selected_card)
        }
    }
    
    // adjust keyboard when scrolling
    @objc
    func updateTextView(notification : Notification)
    {
        let userInfo = notification.userInfo!
        let keyboardEndFrameScreenCoordinates = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardEndFrame = self.view.convert(keyboardEndFrameScreenCoordinates, to: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide{
            note_text_view.contentInset = UIEdgeInsets.zero
        }
        else
        {
            note_text_view.contentInset = UIEdgeInsetsMake(0, 0, keyboardEndFrame.height, 0)
            note_text_view.scrollIndicatorInsets = note_text_view.contentInset
        }
        
        note_text_view.scrollRangeToVisible(note_text_view.selectedRange)
        
    }
}



// Image Picker Delegates
extension NoteEditViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var image = info[UIImagePickerControllerOriginalImage] as! UIImage
        image = fixOrientation(img: image)
        
        txtBody = note_text_view.attributedText
        var attributedString : NSMutableAttributedString!
        attributedString = NSMutableAttributedString(attributedString: txtBody)
        let textAttachment = NSTextAttachment()
        
        
        let oldWidth = image.size.width
        let newWidth = note_text_view.bounds.size.width - 20
        let scaleFactor = oldWidth / newWidth
        image = UIImage(cgImage: image.cgImage!, scale: scaleFactor, orientation: .up)
        textAttachment.image = image
        
        let attrStringWithImage = NSAttributedString.init(attachment: textAttachment)
        attributedString.append(attrStringWithImage)
        
        txtBody = (attributedString as NSAttributedString)
        its_note.content = txtBody
        
        picker.dismiss(animated: true, completion: nil)
    }
}

extension NoteEditViewController : UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholder_label.isHidden = true
    }
}
