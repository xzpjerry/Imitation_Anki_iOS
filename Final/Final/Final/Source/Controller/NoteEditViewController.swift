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
    var selected_card : Card!
    private var fetRC : NSFetchedResultsController<Note>!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.global().async {
            self.fetRC = CardService.shared.find(with: self.selected_card)
            DispatchQueue.main.async {
                self.load_notes()
            }
        }
    }
    
    private func load_notes() {
        if fetRC.fetchedObjects?.count ?? -1 > 0 {
            note_text_view.text = ""
            for note in fetRC.fetchedObjects! {
                note_text_view.text = note_text_view.text + (note.text ?? "")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        CardService.shared.addNote(image: nil, sound: nil, txt: note_text_view.text, to: selected_card)
        super.viewWillDisappear(animated)
    }
}

extension NoteEditViewController : UITextViewDelegate {
    
}
