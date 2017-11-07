//
//  CardService.swift
//  Final
//
//  Created by Dev on 11/6/17.
//  Copyright © 2017 Dev. All rights reserved.
//

import Foundation
import CoreData

class CardService {
    static var shared = CardService()
    private var loaded = false
    
    private init()
    {
        let context = AppDelegate.persistentcontainer.newBackgroundContext()
        AppDelegate.viewcontext.automaticallyMergesChangesFromParent = true
        context.perform {
            let dummy_request : NSFetchRequest<Card> = Card.fetchRequest()
            let existed_count : Int?
            
            do {
                try existed_count = context.count(for: dummy_request)
            } catch let error {
                fatalError("\(error)")
            }
            
            guard existed_count == 0 else {
                self.loaded = true
                return
            }
            
            let init_plist_path = Bundle.main.path(forResource: "words", ofType: "plist")!
            let init_data = NSArray(contentsOfFile: init_plist_path) as! Array<Dictionary<String, String>>
            
            for data in init_data {
                let word = Card(context: context)
                word.word = data["Word"]
                word.note = ""
                word.ease = -1
                word.due = Date().timeIntervalSince1970
            }
            
            if context.hasChanges {
                do {
                    try context.save()
                } catch let error {
                    fatalError("\(error)")
                }
            }
            self.loaded = true
            print("Plist loaded.")
        }
    }
    
    func find(_ a_record : record, context : NSManagedObjectContext = AppDelegate.persistentcontainer.newBackgroundContext()) -> NSFetchedResultsController<Card> {
        print("Getting a fetch request")
        while(loaded != true){
            sleep(1)
        }
        
        let request : NSFetchRequest<Card> = Card.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "due", ascending: false), NSSortDescriptor(key: "word", ascending: true)]
        request.predicate = NSPredicate(format: "(word = %@) AND (note = %@)", a_record.word, a_record.note)
        
        let results = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try results.performFetch()
        } catch let error {
            fatalError(error.localizedDescription)
        }
        return results
    }
    
    func find_convenient(_ a_record : record, context : NSManagedObjectContext = AppDelegate.persistentcontainer.newBackgroundContext()) -> Array<record> {
        print("Getting a fetch request")
        while(loaded != true){
            sleep(1)
        }
        
        let dummy_results = self.find(a_record, context: context)
        var results : Array<record> = []
        if let objects = dummy_results.fetchedObjects {
            for object in objects {
                let temp_card = record(object.word!, object.note!)
                temp_card.due = Date.init(timeIntervalSince1970: object.due)
                temp_card.ease = object.ease
                results.append(temp_card)
            }
        }
        return results
    }
    
    func add(_ new_record : record) {
        print("Getting an add request")
        while(loaded != true){
            sleep(1)
        }
        guard self.find_convenient(new_record).count == 0 else {
            return
        }
        let context = AppDelegate.persistentcontainer.newBackgroundContext()
        let new_card = Card(context: context)
        new_card.due = Date().timeIntervalSince1970
        new_card.ease = -1
        new_card.note = new_record.note
        new_card.word = new_record.word
        
        do {
            try context.save()
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
    
    func delete(_ a_record : record) {
        print("Getting an delete request")
        while(loaded != true){
            sleep(1)
        }
        
        let context = AppDelegate.persistentcontainer.newBackgroundContext()
        let fetch_attempt = self.find(a_record, context: context)
        guard fetch_attempt.fetchedObjects?.count == 1 else {
            return
        }
        
        let target_object = fetch_attempt.fetchedObjects!.first!
        context.delete(target_object)
        
        do {
            try context.save()
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
    
    
    
}
