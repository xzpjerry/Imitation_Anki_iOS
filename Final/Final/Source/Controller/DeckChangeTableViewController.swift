//
//  DeckChangeTableViewController.swift
//  Final
//
//  Created by Zippo Xie on 12/1/17.
//  Copyright © 2017 Zippo Xie. All rights reserved.
//

import UIKit

class DeckChangeTableViewController: UITableViewController {
 
    let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
    

}

// table view delegate
extension DeckChangeTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if let view = cell.viewWithTag(999) {
                if let label = view.viewWithTag(998) as? UILabel {
                    if let title_src = label.text?.components(separatedBy: "#").first {
                        
                        alert.view.tintColor = UIColor.black
                        present(alert, animated: true, completion: nil)
                        
                        let progress = UIProgressView(frame: alert.view.bounds)
                        progress.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                        progress.setProgress(0, animated: false)
                        alert.view.addSubview(progress)
                        alert.view.layoutIfNeeded()

                        DispatchQueue.global().async {
                            DispatchQueue.global().async { [weak self] in
                                while(self?.alert.isViewLoaded ?? false){
                                    sleep(1)
                                    DispatchQueue.main.async {
                                        progress.setProgress(Float(CardService.shared.total_amount)/8000.0, animated: true)
                                    }
                                }
                            }
                            CardService.shared.load(from: title_src)
                            DispatchQueue.main.async {
                                self.alert.dismiss(animated: true, completion: nil)
                            }
                        }
                       
                        
                    }
                }
            }
        }
    }
}




