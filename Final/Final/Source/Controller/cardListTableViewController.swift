//
//  cardListTableViewController.swift
//  Final
//
//  Created by Dev on 11/13/17.
//  Copyright © 2017 Dev. All rights reserved.
//

import UIKit
import CoreData

class cardListTableViewController : UITableViewController {
    @IBOutlet weak var loading_view : UIView!
    @IBOutlet weak var spinner : UIActivityIndicatorView!
    var fetched_result : NSFetchedResultsController<Card>!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        spinner.startAnimating()
        loading_view.isHidden = false
        DispatchQueue.global().async {
            self.fetched_result = CardService.shared.find()
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                self.loading_view.isHidden = true
                self.tableView.tableHeaderView = nil
                self.tableView.reloadData()
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard fetched_result != nil else {
            return 1
        }
        return fetched_result.sections!.count
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard fetched_result != nil else {
            return 0
        }
        let sections = fetched_result.sections!
        let section_info = sections[section]
        return section_info.numberOfObjects
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "card_cell", for: indexPath)
        guard fetched_result != nil else {
            return cell
        }
        let card = fetched_result.object(at: indexPath)
        cell.textLabel?.text = card.word
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy HH:mm"
        cell.detailTextLabel?.text = "Due:\(formatter.string(from: card.due!)); ease:\(card.ease); interval:\(card.learning_stage!)"
        return cell
    }
    
}
