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
    var total_card : Int? {
        get {
            return total_amount()
        }
    }
    var todays_card : Int? {
        get {
            return today_amount()
        }
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
    private var cached_context : NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private func Record2Card(record : record, card : Card) {
        card.due = record.due
        card.ease = record.ease!
        card.interval = Int64(record.interval!)
        card.learning_stage = NSDecimalNumber.init(value: record.learning_stage)
        card.note = record.note
        card.stage = record.stage
        card.success_answer = record.total_answer!
        card.total_answer = record.success_answer!
        card.word = record.word
    }
    
    private init()
    {
        persistentContainer.performBackgroundTask{ context in
            
            let first_time_launch = UserDefaults.standard.bool(forKey: "I_am_not_first_time_launching_this_app")
            guard first_time_launch == false else {
                return
            }
            NSLog("Fist time launch loading begins.")
            
            let init_plist_path = Bundle.main.path(forResource: "words", ofType: "plist")!
            let init_data = NSArray(contentsOfFile: init_plist_path) as! Array<Dictionary<String, String>>
            let init_date = Date()
            var buffer : Array<String> = []
            NSLog("Init date is \(init_date)")
            for data in init_data {
                if buffer.count == 32 {
                    context.reset()
                    for Word in buffer {
                        let word = Card(context: context)
                        word.word = Word
                        word.stage = "New"
                        word.note = ""
                        word.due = init_date
                        word.learning_stage = 0
                    }
                    buffer = []
                    do {
                        try context.save()
                    } catch let error {
                        fatalError("\(error)")
                    }
                    context.reset()
                }
                buffer.append(data["Word"]!)
            }
            UserDefaults.standard.set(200, forKey: "max_study")
            UserDefaults.standard.set([1, 10], forKey: "new_card_step")
            UserDefaults.standard.set(true, forKey: "I_am_not_first_time_launching_this_app")
            NSLog("Plist loaded; defaults settings set.")
        }
    }
        
    func total_amount() -> Int {
        NSLog("Counting all the card.")
        while(UserDefaults.standard.bool(forKey: "I_am_not_first_time_launching_this_app") != true){
            sleep(1)
        }
        let request : NSFetchRequest<Card> = Card.fetchRequest()
        let result : Int!
        do {
            try result = cached_context.count(for: request)
        } catch let error {
            fatalError(error.localizedDescription)
        }
        return result
    }
    
    func today_amount() -> Int {
        NSLog("Counting today's cards.")
        while(UserDefaults.standard.bool(forKey: "I_am_not_first_time_launching_this_app") != true){
            sleep(1)
        }
        let request : NSFetchRequest<Card> = Card.fetchRequest()
        request.fetchLimit = UserDefaults.standard.integer(forKey: "max_study")
        request.sortDescriptors = [NSSortDescriptor(key: "due", ascending: true), NSSortDescriptor(key: "word", ascending: true)]
        
        let start_of_day = Calendar.current.startOfDay(for: Date())
        let end_of_day = Calendar.current.date(byAdding: .day, value: 1, to: start_of_day)!
        request.predicate = NSPredicate(format: "due < %@", argumentArray: [end_of_day])
        
        let count_result : Int!
        do {
            try count_result = cached_context.count(for: request)
        } catch let error {
            fatalError(error.localizedDescription)
        }
        return count_result > UserDefaults.standard.integer(forKey: "max_study") ? UserDefaults.standard.integer(forKey: "max_study") : count_result
    }
    
    func find() -> NSFetchedResultsController<Card> {
        NSLog("Getting a find_all request.")
        while(UserDefaults.standard.bool(forKey: "I_am_not_first_time_launching_this_app") != true){
            sleep(1)
        }
        
        let request : NSFetchRequest<Card> = Card.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "due", ascending: true)]
        let context = cached_context
        context.reset()

        let results = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try results.performFetch()
        } catch let error {
            fatalError(error.localizedDescription)
        }
        return results
    }
    
    func find(_ a_record : record, context : NSManagedObjectContext) -> NSFetchedResultsController<Card> {
        NSLog("Getting a find request.")
        while(UserDefaults.standard.bool(forKey: "I_am_not_first_time_launching_this_app") != true){
            sleep(1)
        }
        context.reset()
        let request : NSFetchRequest<Card> = Card.fetchRequest()
        request.fetchLimit = 1
        let predicate = NSPredicate(format: "(word = %@) AND (due = %@)", argumentArray: [a_record.word, a_record.due])
        request.predicate = predicate
        
        let results = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try results.performFetch()
        } catch let error {
            fatalError(error.localizedDescription)
        }
        return results
    }
    
    func find_convenient(_ a_record : record, context : NSManagedObjectContext) -> record? {
        NSLog("Getting a find_convenient request")
        while(UserDefaults.standard.bool(forKey: "I_am_not_first_time_launching_this_app") != true){
            sleep(1)
        }
        context.reset()
        let dummy_results = find(a_record, context: context)
        var result : record?
        if let object = dummy_results.fetchedObjects?.first {
            var temp_card = record(object.word!, object.note!)
            temp_card.due = object.due
            temp_card.stage = object.stage
            temp_card.ease = object.ease
            temp_card.learning_stage = Int.init(truncating: object.learning_stage!)
            temp_card.success_answer = object.success_answer
            temp_card.total_answer = object.total_answer
            result = temp_card
        }
        return result
    }
    
    func find_convenient(_ a_record : record) -> record? {
        NSLog("Getting a find_convenient request")
        while(UserDefaults.standard.bool(forKey: "I_am_not_first_time_launching_this_app") != true){
            sleep(1)
        }
        let context = cached_context
        let dummy_results = find(a_record, context: context)
        var result : record?
        if let object = dummy_results.fetchedObjects?.first {
            var temp_card = record(object.word!, object.note!)
            temp_card.due = object.due
            temp_card.stage = object.stage
            temp_card.ease = object.ease
            temp_card.learning_stage = Int.init(truncating: object.learning_stage!)
            temp_card.success_answer = object.success_answer
            temp_card.total_answer = object.total_answer
            result = temp_card
        }
        return result
    }
    
    func add(_ new_record : record) {
        NSLog("Getting an add request")
        while(UserDefaults.standard.bool(forKey: "I_am_not_first_time_launching_this_app") != true){
            sleep(1)
        }
        let context = cached_context
        context.reset()
        guard find_convenient(new_record, context: context) == nil else {
            return
        }
        let new_card = Card(context: context)
        Record2Card(record: new_record, card: new_card)
        
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
        
        let context = cached_context
        context.reset()
        let fetch_attempt = find(a_record, context: context)
        guard fetch_attempt.fetchedObjects?.count == 1 else {
            return
        }
        
        let target_object = fetch_attempt.fetchedObjects!.first!
        Record2Card(record: new_record, card: target_object)
        
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
        
        let context = cached_context
        context.reset()
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
    
    func fetch_top(context : NSManagedObjectContext) -> NSFetchedResultsController<Card> {
        NSLog("Fetching the top card.")
        while(UserDefaults.standard.bool(forKey: "I_am_not_first_time_launching_this_app") != true){
            sleep(1)
        }
        context.reset()
        let request : NSFetchRequest<Card> = Card.fetchRequest()
        request.fetchLimit = 1 // to fetch the card has closest due day
        request.sortDescriptors = [NSSortDescriptor(key: "due", ascending: true)]
        
        let start_of_day = Calendar.current.startOfDay(for: Date())
        let end_of_day = Calendar.current.date(byAdding: .day, value: 1, to: start_of_day)!
        request.predicate = NSPredicate(format: "due < %@", argumentArray: [end_of_day])
        
        let results = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try results.performFetch()
        } catch let error {
            fatalError(error.localizedDescription)
        }
        return results
    }
    
    func fetch_top_convenient() -> record {
        NSLog("Getting a fetch request")
        while(UserDefaults.standard.bool(forKey: "I_am_not_first_time_launching_this_app") != true){
            sleep(1)
        }
        
        let context = cached_context
        context.reset()
        let dummy_results = fetch_top(context: context)
        var result : record!
        
        if let objects = dummy_results.fetchedObjects {
            for object in objects {
                var temp_card = record(object.word!, object.note!)
                temp_card.due = object.due
                temp_card.stage = object.stage
                temp_card.ease = object.ease
                temp_card.learning_stage = Int.init(truncating: object.learning_stage!)
                temp_card.success_answer = object.success_answer
                temp_card.total_answer = object.total_answer
                result = temp_card
            }
        }
        context.reset()
        return result
    }
}

