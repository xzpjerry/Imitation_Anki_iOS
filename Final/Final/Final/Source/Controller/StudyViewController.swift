//
//  StudyViewController.swift
//  Final
//
//  Created by Dev on 11/19/17.
//  Copyright © 2017 Zippo Xie. All rights reserved.
//

import UIKit

class StudyViewController: UIViewController {
    
    @IBOutlet weak var buttonView : UIView!
    @IBOutlet weak var title_label : UILabel!
    @IBOutlet weak var note_text_view : UITextView!
    var current_card : Card?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
//    private func loadnotes() {
//        if let card = current_card {
//
//            var attributedString :NSMutableAttributedString!
//            attributedString = NSMutableAttributedString(attributedString:note_text_view.attributedText)
//            let textAttachment = NSTextAttachment()
//            textAttachment.im
//
//            let oldWidth = textAttachment.image!.size.width;
//
//            //I'm subtracting 10px to make the image display nicely, accounting
//            //for the padding inside the textView
//
//            let scaleFactor = oldWidth / (txtBody.frame.size.width - 10);
//            textAttachment.image = UIImage(cgImage: textAttachment.image!.cgImage!, scale: scaleFactor, orientation: .up)
//            let attrStringWithImage = NSAttributedString(attachment: textAttachment)
//            attributedString.append(attrStringWithImage)
//            txtBody.attributedText = attributedString;
//        }
//    }

}
