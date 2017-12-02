//
//  CardCollectionViewController.swift
//  Final
//
//  Created by Zippo Xie on 11/18/17.
//  Copyright © 2017 Zippo Xie. All rights reserved.
//

import UIKit
import CoreData

class CardCollectionViewController: UIViewController {
    @IBOutlet weak var collectionView : UICollectionView!
    @IBOutlet weak var spiner : UIActivityIndicatorView!
    
    private var fetchedRC:NSFetchedResultsController<Card>!
    private var selected:IndexPath = IndexPath()
    private let dateFormatter = DateFormatter()
    private var query = ""
    
    @IBAction func addCard() {
        DispatchQueue.global().async {
            CardService.shared.addCard()
            self.refresh()
        }
    }

    private func refresh() {
        DispatchQueue.global().async {
            self.fetchedRC = CardService.shared.find(title: self.query, sender: self)
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())
        DispatchQueue.global().async {
            self.refresh()
        }
        super.viewWillAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        spiner.startAnimating()
        if (segue.identifier == "edit_selected_card") {
            let cell = sender as! UICollectionViewCell
            let indexPath = collectionView.indexPath(for: cell)
            if let dst = segue.destination as? CardEditTableViewController {
                dst.selectedIndexPath = indexPath
                dst.fetchRC = fetchedRC
            }
            
        } else {
            super.prepare(for: segue, sender: sender)
        }
        spiner.stopAnimating()
    }
}

// Collection View Delegates
extension CardCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "card_header", for: indexPath)
        if let alabel = view.viewWithTag(1000) as? UILabel {
            if let cards = fetchedRC?.sections?[indexPath.section].objects as? [Card], let card = cards.first{
                alabel.text = "\(card.first_letter!.first!)".uppercased()
            }
        }
        return view
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedRC?.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sections = fetchedRC?.sections, let objs = sections[section].objects else {
            return 0
        }
        return objs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Card_Cell", for: indexPath) as! CardCollectionViewCell
        
        if let card = fetchedRC?.object(at: indexPath){
            cell.titleLabel.text = card.title
            cell.createdDateLabel.text = "Created:" + card.created_time!.timeAgoSinceNow
            if let due = card.due, due != Date.distantFuture {
                cell.nextDueDateLabel.text = "Next due:" + dateFormatter.string(from: due)
            } else {
                cell.nextDueDateLabel.text = "Waiting for learning."
            }
            
            if let badge = card.badge as Data? {
                cell.cardBadge.image = UIImage(data: badge)
            } else {
                cell.cardBadge.image = UIImage(named: "Card_image_place_holder")
            }
        }
        
        return cell
    }
    
}


// Search Bar Delegate
extension CardCollectionViewController:UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text else {
            return
        }
        self.query = query
        DispatchQueue.main.async {
            self.refresh()
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        query = searchText
        DispatchQueue.main.async {
            self.refresh()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        query = ""
        DispatchQueue.main.async {
            self.refresh()
            searchBar.text = nil
            searchBar.resignFirstResponder()
        }
    }
}

// fetched result delegate
extension CardCollectionViewController : NSFetchedResultsControllerDelegate {
}


