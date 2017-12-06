	//
//  CardService.swift
//  Final
//
//  Created by Zippo Xie on 11/18/17.
//  Copyright © 2017 Zippo Xie. All rights reserved.
//

import UIKit
import CoreData

class CardService {
    
    static var shared : CardService {
        return CardService()
    }
    static var endoftoday : Date {
        let now = Date()
        let startofday = Calendar.current.startOfDay(for: now)
        return Calendar.current.date(byAdding: .day, value: 1, to: startofday)!
    }
    static var allowed_foreseen_end_point : Date {
        let now = Date()
        let allowed_foreseen_period = UserDefaults.standard.integer(forKey: "allowed_foreseen_period")
        return Calendar.current.date(byAdding: .minute, value: allowed_foreseen_period, to: now)!
    }
    var remaing_today : Int {
        let learned = UserDefaults.standard.integer(forKey: "learned_today")
        let max = UserDefaults.standard.integer(forKey: "max_study")
        return (max - learned) < 0 ? 0 : (max - learned)
    }
    
    // Dashboard value
    var total_amount : Int {
        let request : NSFetchRequest<Card> = NSFetchRequest(entityName: "Card")
        return try! CardService.context.count(for: request)
    }
    var total_learning_amount : Int {
        let request : NSFetchRequest<Card> = NSFetchRequest(entityName: "Card")
        request.predicate = NSPredicate(format: "stage = 'Learning'")
        return try! CardService.context.count(for: request)
    }
    var total_learned_amount : Int {
        let request : NSFetchRequest<Card> = NSFetchRequest(entityName: "Card")
        request.predicate = NSPredicate(format: "stage = 'Learned'")
        return try! CardService.context.count(for: request)
    }
    
    var new_totday_amount : Int {
        let request : NSFetchRequest<Card> = NSFetchRequest(entityName: "Card")
        request.fetchLimit = CardService.shared.remaing_today
        request.predicate = NSPredicate(format: "stage = 'Unseen'")
        return try! CardService.context.count(for: request)
    }
    var review_totday_amount : Int {
        let request : NSFetchRequest<Card> = NSFetchRequest(entityName: "Card")
        request.fetchLimit = CardService.shared.remaing_today
        request.predicate = NSPredicate(format: "due <= %@ AND stage = 'Reviewing'", argumentArray: [CardService.endoftoday])
        return try! CardService.context.count(for: request)
    }
    var relearn_totday_amount : Int {
        let request : NSFetchRequest<Card> = NSFetchRequest(entityName: "Card")
        request.fetchLimit = CardService.shared.remaing_today
        request.predicate = NSPredicate(format: "due <= %@ AND stage = 'Relearning'", argumentArray: [CardService.endoftoday])
        return try! CardService.context.count(for: request)
    }
    var available_now_amount : Int {
        let request : NSFetchRequest<Card> = NSFetchRequest(entityName: "Card")
        request.fetchLimit = CardService.shared.remaing_today
        request.predicate = NSPredicate(format: "due <= %@ OR stage = 'Unseen'", argumentArray: [CardService.allowed_foreseen_end_point])
        return try! CardService.context.count(for: request)
    }
    
    // service prologue
    private init() {
    }
    
    // core data stack
    static let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Final")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    static let context : NSManagedObjectContext = persistentContainer.newBackgroundContext()
    
    // Basic service
    func saveContext(with fetchedresultcontroller : NSFetchedResultsController<Card>? = nil, by a_card : Card? = nil) {
        let context : NSManagedObjectContext!
        if a_card != nil {
            context = a_card!.managedObjectContext!
        } else {
            context = fetchedresultcontroller == nil ? CardService.context : fetchedresultcontroller!.managedObjectContext
        }
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let err = error as NSError
                fatalError("Unresolved errror \(err), \(err.userInfo)")
            }
            NSLog("Change saved")
            return
        }
        NSLog("Nothing changes, context did not save.")
    }
    
    func addCard(with tmp_card : CardData = CardData()) {
        let new_card = tmp_card.Card_gen(in: CardService.context)
        let new_note = Note(context: CardService.context)
        
        new_note.content = NSAttributedString.init(string: "")
        new_note.unique = UUID()
        new_card.note = new_note
        
        do {
            try CardService.context.save()
        } catch let err {
            fatalError("Add new card failed, \(err.localizedDescription)")
        }
        //NSLog("Succeed add a card UUid \(tmp_card.unique!), with note uuid \(new_note.unique!).")
    }
    
    func del_card(with card : Card) {
        NSLog("About to delete a card UUid \(card.unique!), with note uuid \(card.note!.unique!).")
        CardService.context.delete(card)
        do {
            try CardService.context.save()
        } catch let err {
            fatalError("Deletion failed, \(err.localizedDescription)")
        }
    }
    
    func wipe_out() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Card")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try CardService.context.execute(batchDeleteRequest)
            try CardService.context.save()
        } catch let err {
            fatalError("Wipe-out failed \(err.localizedDescription)")
        }
        NSLog("Succeed wipe-out.")
    }
    
    func find(title : String? = nil, before : Date? = nil, within limit : Int? = nil, sender : NSFetchedResultsControllerDelegate? = nil) -> NSFetchedResultsController<Card> {
        
        let request : NSFetchRequest<Card> = NSFetchRequest(entityName: "Card")
        request.sortDescriptors = [NSSortDescriptor.init(key: "first_letter", ascending: true), NSSortDescriptor.init(key: "due", ascending: true), NSSortDescriptor.init(key: "created_time", ascending: false)]
        //NSSortDescriptor.init(key: "title", ascending: false, selector: #selector(NSString.caseInsensitiveCompare(_:)))]
        
        if limit != nil {
            request.fetchLimit = limit!
        }
        
        var predicate : Array<NSPredicate> = []
        if title != nil && title != "" {
            predicate.append(NSPredicate(format: "title CONTAINS[cd] %@", argumentArray: [title!]))
        }
        if before != nil {
            NSLog("Get a find before request before \(before!)")
            predicate.append(NSPredicate(format: "(due <= %@) OR (stage = 'Unseen')", argumentArray: [before!]))
        }
        if predicate.count > 0 {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicate)
        }
        
        let rslt : NSFetchedResultsController<Card> = NSFetchedResultsController(fetchRequest: request, managedObjectContext: CardService.context, sectionNameKeyPath: #keyPath(Card.first_letter), cacheName: nil)
        if (sender != nil) {rslt.delegate = sender}
        do {
            try rslt.performFetch()
        } catch let err {
            fatalError("Finding failed. \(err.localizedDescription)")
        }
        
        return rslt
    }
}

// Loading cards from a plist (will be URL from the internet in the future)
extension CardService {
    func load(from URL : String) {
        let wordDataPath = Bundle.main.path(forResource: URL, ofType: "plist")!
        let wordData = NSArray(contentsOfFile: wordDataPath) as! Array<Dictionary<String, String>>
        wipe_out()
        for word_dict in wordData {
            if let word = word_dict["Word"] {
                CardService.shared.addCard(with: CardData(title:word))
                // if I load all at once and save at the end, it will cause memory leak for some strange reason
            }
        }
    }
}

