//
//  CardService.swift
//  Final
//
//  Created by Zippo Xie on 11/18/17.
//  Copyright © 2017 Zippo Xie. All rights reserved.
//

import Foundation
import CoreData

class CardService {
    
    static var shared : CardService {
        return CardService()
    }
    var total_amount : Int {
        let request : NSFetchRequest<Card> = NSFetchRequest(entityName: "Card")
        return try! persistentContainer.viewContext.count(for: request)
    }
    var new_totday_amount : Int {
        let request : NSFetchRequest<Card> = NSFetchRequest(entityName: "Card")
        request.predicate = NSPredicate(format: "stage = 'Unseen'")
        return try! persistentContainer.viewContext.count(for: request)
    }
    var review_totday_amount : Int {
        let request : NSFetchRequest<Card> = NSFetchRequest(entityName: "Card")
        let now = Date()
        let startofday = Calendar.current.startOfDay(for: now)
        let midnight_next = Calendar.current.date(byAdding: .day, value: 1, to: startofday)
        request.predicate = NSPredicate(format: "due <= %@ AND stage = 'Review'", argumentArray: [midnight_next!])
        return try! persistentContainer.viewContext.count(for: request)
    }
    var relearn_totday_amount : Int {
        let request : NSFetchRequest<Card> = NSFetchRequest(entityName: "Card")
        let now = Date()
        let startofday = Calendar.current.startOfDay(for: now)
        let midnight_next = Calendar.current.date(byAdding: .day, value: 1, to: startofday)
        request.predicate = NSPredicate(format: "due <= %@ AND stage = 'Relearn'", argumentArray: [midnight_next!])
        return try! persistentContainer.viewContext.count(for: request)
    }
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Final")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    private var context : NSManagedObjectContext!
    
    private init() {
        context = persistentContainer.newBackgroundContext()
    }
    
    func saveContext(with fetchedresultcontroller : NSFetchedResultsController<Card>? = nil, by a_card : Card? = nil) {
        let context : NSManagedObjectContext!
        if a_card != nil {
            context = a_card!.managedObjectContext!
        } else {
            context = fetchedresultcontroller == nil ? self.context : fetchedresultcontroller!.managedObjectContext
        }
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let err = error as NSError
                fatalError("Unresolved errror \(err), \(err.userInfo)")
            }
        }
    }
    
    func addCard(newCard card : CardData) {
        let tmp_card = Card(context: context)
        tmp_card.title = card.title
        tmp_card.created_time = card.created_time
        tmp_card.stage = card.stage
        tmp_card.unique = card.unique
        tmp_card.first_letter = card.first_letter
        do {
            try context.save()
        } catch let err {
            fatalError("Add new card failed, \(err.localizedDescription)")
        }
    }
    
    func addNote(image : Data? = nil, sound : Data? = nil, txt : String? = nil, to card : Card) {
        let context = card.managedObjectContext ?? self.context
        let tmp_note = Note(context: context!)
        tmp_note.card = card
        if image != nil {
            tmp_note.photo = image!
        }
        if sound != nil {
            tmp_note.sound = sound!
        }
        if txt != nil {
            tmp_note.text = txt!
        }
        tmp_note.unique = UUID()
        do {
            try context!.save()
        } catch let err {
            fatalError("Add new card failed, \(err.localizedDescription)")
        }
    }
    
    func find(with acard : Card) -> NSFetchedResultsController<Note> {
        let request : NSFetchRequest<Note> = NSFetchRequest(entityName: "Note")
        request.predicate = NSPredicate(format: "card = %@", argumentArray: [acard])
        request.sortDescriptors = [NSSortDescriptor.init(key: "UUID", ascending: true)]
        
        let rslt : NSFetchedResultsController<Note> = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try rslt.performFetch()
        } catch let err {
            fatalError("Find \(acard.title!), \(acard.unique!)'s notes failed, \(err.localizedDescription)")
        }
        return rslt
    }
    
    func find(title : String? = nil, before : Date? = nil) -> NSFetchedResultsController<Card> {
        
        let request : NSFetchRequest<Card> = NSFetchRequest(entityName: "Card")
        request.sortDescriptors = [NSSortDescriptor.init(key: "due", ascending: true), NSSortDescriptor.init(key: "created_time", ascending: false), NSSortDescriptor.init(key: "title", ascending: false, selector: #selector(NSString.caseInsensitiveCompare(_:)))]
        
        var predicate : Array<NSPredicate> = []
        if title != nil && title != "" {
            predicate.append(NSPredicate(format: "title CONTAINS[cd] %@", argumentArray: [title!]))
        }
        if before != nil {
            predicate.append(NSPredicate(format: "due <= %@", argumentArray: [before!]))
        }
        if predicate.count > 0 {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicate)
        }
        
        let rslt : NSFetchedResultsController<Card> = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: #keyPath(Card.first_letter), cacheName: nil)
        do {
            try rslt.performFetch()
        } catch let err {
            fatalError("Finding failed. \(err.localizedDescription)")
        }
        
        return rslt
    }
    
}
