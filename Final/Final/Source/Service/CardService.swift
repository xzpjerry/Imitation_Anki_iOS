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
    private(set) var total_card : Int?
    private(set) var todays_card : Int?
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Final")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private init()
    {
        //let context = AppDelegate.persistentcontainer.newBackgroundContext()
        //AppDelegate.viewcontext.automaticallyMergesChangesFromParent = true
        persistentContainer.performBackgroundTask{ context in
            
            let first_time_launch = UserDefaults.standard.bool(forKey: "I_am_not_first_time_launching_this_app")
            guard first_time_launch == false else {
                return
            }
            NSLog("Fist time launch loading begins.")
            
            let dummy_request : NSFetchRequest<Card> = Card.fetchRequest()
            
            do {
                try self.total_card = context.count(for: dummy_request)
            } catch let error {
                fatalError("\(error)")
            }
            
            guard self.total_card == 0 else {
                return
            }
            
            let init_plist_path = Bundle.main.path(forResource: "words", ofType: "plist")!
            let init_data = NSArray(contentsOfFile: init_plist_path) as! Array<Dictionary<String, String>>
            let init_date = Date()
            NSLog("Init date is \(init_date)")
            for data in init_data {
                let word = Card(context: context)
                word.word = data["Word"]
                word.stage = "New"
                word.note = ""
                word.due = init_date
                word.learning_stage = 0
                word.success_answer = 0
                word.total_answer = 0
            }
            
            if context.hasChanges {
                do {
                    try context.save()
                } catch let error {
                    fatalError("\(error)")
                }
            }
            
            UserDefaults.standard.set(200, forKey: "max_study")
            UserDefaults.standard.set([1, 10], forKey: "new_card_step")
            UserDefaults.standard.set(true, forKey: "I_am_not_first_time_launching_this_app")
            NSLog("Plist loaded.")
        }
    }
    
    func update_statics() {
        persistentContainer.performBackgroundTask{ context in
            
            let dummy_request : NSFetchRequest<Card> = Card.fetchRequest()
            
            do {
                try self.total_card = context.count(for: dummy_request)
            } catch let error {
                fatalError("\(error)")
            }
        }
    }
    
    func find(_ a_record : record, context : NSManagedObjectContext = AppDelegate.persistentcontainer.newBackgroundContext()) -> NSFetchedResultsController<Card> {
        NSLog("Getting a find request")
        while(UserDefaults.standard.bool(forKey: "I_am_not_first_time_launching_this_app") != true){
            sleep(1)
        }
        
        let request : NSFetchRequest<Card> = Card.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "due", ascending: false), NSSortDescriptor(key: "word", ascending: true)]
        let predicate = NSPredicate(format: "(word = %@) AND (note = %@)", argumentArray: [a_record.word, a_record.note])
        request.predicate = predicate
        
        let results = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try results.performFetch()
        } catch let error {
            fatalError(error.localizedDescription)
        }
        return results
    }
    
    func find_convenient(_ a_record : record, context : NSManagedObjectContext = AppDelegate.persistentcontainer.newBackgroundContext()) -> Array<record> {
        NSLog("Getting a find_convenient request")
        while(UserDefaults.standard.bool(forKey: "I_am_not_first_time_launching_this_app") != true){
            sleep(1)
        }
        
        let dummy_results = find(a_record, context: context)
        var results : Array<record> = []
        if let objects = dummy_results.fetchedObjects {
            for object in objects {
                let temp_card = record(object.word!, object.note!)
                temp_card.due = object.due
                temp_card.stage = object.stage
                temp_card.ease = object.ease
                temp_card.learning_stage = Int.init(truncating: object.learning_stage!)
                temp_card.success_answer = object.success_answer
                temp_card.total_answer = object.total_answer
                results.append(temp_card)
            }
        }
        return results
    }
    
    func add(_ new_record : record) {
        NSLog("Getting an add request")
        while(UserDefaults.standard.bool(forKey: "I_am_not_first_time_launching_this_app") != true){
            sleep(1)
        }
        guard find_convenient(new_record).count == 0 else {
            return
        }
        let context = AppDelegate.persistentcontainer.newBackgroundContext()
        let new_card = Card(context: context)
        new_card.due = Date()
        new_card.ease = -1
        new_card.note = new_record.note
        new_card.word = new_record.word
        
        do {
            try context.save()
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
    
    func modify(a_record : record, with new_record : record) {
        NSLog("Getting a modifying request")
        while(UserDefaults.standard.bool(forKey: "I_am_not_first_time_launching_this_app") != true){
            sleep(1)
        }
        
        let context = AppDelegate.persistentcontainer.newBackgroundContext()
        let fetch_attempt = find(a_record, context: context)
        guard fetch_attempt.fetchedObjects?.count == 1 else {
            return
        }
        
        let target_object = fetch_attempt.fetchedObjects!.first!
        target_object.word = new_record.word
        target_object.note = new_record.note
        
        do {
            try context.save()
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
    
    func delete(_ a_record : record) {
        NSLog("Getting an delete request")
        while(UserDefaults.standard.bool(forKey: "I_am_not_first_time_launching_this_app") != true){
            sleep(1)
        }
        
        let context = AppDelegate.persistentcontainer.newBackgroundContext()
        let fetch_attempt = find(a_record, context: context)
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
    
    func fetch_top(context : NSManagedObjectContext = AppDelegate.persistentcontainer.newBackgroundContext()) -> NSFetchedResultsController<Card> {
        NSLog("Getting a fetch request")
        while(UserDefaults.standard.bool(forKey: "I_am_not_first_time_launching_this_app") != true){
            sleep(1)
        }
        
        let request : NSFetchRequest<Card> = Card.fetchRequest()
        request.fetchLimit = UserDefaults.standard.integer(forKey: "max_study")
        request.sortDescriptors = [NSSortDescriptor(key: "due", ascending: false), NSSortDescriptor(key: "word", ascending: true)]
        
        let start_of_day = Calendar.current.startOfDay(for: Date()) 
        let end_of_day = Calendar.current.date(byAdding: .day, value: 1, to: start_of_day)!
        request.predicate = NSPredicate(format: "(due > %@) AND (due < %@)", argumentArray: [start_of_day, end_of_day])
        
        let results = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try results.performFetch()
        } catch let error {
            fatalError(error.localizedDescription)
        }
        return results
    }
    
    func fetch_top_convenient(context : NSManagedObjectContext = AppDelegate.persistentcontainer.newBackgroundContext()) -> Array<record> {
        NSLog("Getting a fetch request")
        while(UserDefaults.standard.bool(forKey: "I_am_not_first_time_launching_this_app") != true){
            sleep(1)
        }
        
        let dummy_results = fetch_top(context: context)
        var results : Array<record> = []
        
        if let objects = dummy_results.fetchedObjects {
            for object in objects {
                    let temp_card = record(object.word!, object.note!)
                    temp_card.due = object.due
                    temp_card.stage = object.stage
                    temp_card.ease = object.ease
                    temp_card.learning_stage = Int.init(truncating: object.learning_stage!)
                    temp_card.success_answer = object.success_answer
                    temp_card.total_answer = object.total_answer
                    results.append(temp_card)
            }
        }
        return results
    }
    
}

