//
//  FinalTests.swift
//  FinalTests
//
//  Created by Dev on 11/6/17.
//  Copyright © 2017 Dev. All rights reserved.
//

import XCTest
@testable import Final

class FinalTests: XCTestCase {

    
    func test_didLoad() {
        let instance = CardService.shared
        let sample_record = record("abandon", "")
        let results1 = instance.find_convenient(sample_record)
        XCTAssert(results1.first?.word == "abandon", "Find_convenient failed.")
        let result2 = instance.find(sample_record)
        XCTAssert(result2.fetchedObjects?.first?.word == "abandon", "Find failed.")
        
    }
    
    func test_add() {
        let instance = CardService.shared
        let sample_record = record("a_new_card", "just for test purpose")
        
        instance.add(sample_record)
        let results = instance.find_convenient(sample_record)
        XCTAssert(results.first?.word == sample_record.word, "Add failed.")
    }
    
    func test_delete() {
        let instance = CardService.shared
        let sample_record = record("a_new_card", "just for test purpose")
        
        instance.add(sample_record)
        instance.delete(sample_record)
        let results = instance.find_convenient(sample_record)
        XCTAssert(results.count == 0, "Delete failed.")
        
    }
    
    func test_modify() {
        let instance = CardService.shared
        let sample_record = record("a_new_card", "just for test purpose")
        instance.add(sample_record)
        var results = instance.find_convenient(sample_record)
        XCTAssert(results.count == 1, "Sample card did not add into the deck.")
        
        let a_new_record = record("Another new card", "Test for modification.")
        instance.modify(a_record: sample_record, with: a_new_record)
        results = instance.find_convenient(sample_record)
        XCTAssert(results.count == 0, "Sample card has not been modified.")
        results = instance.find_convenient(a_new_record)
        XCTAssert(results.count == 1, "Sample card has not been modified with a new card.")
    }
    
    func test_fetch_top() {
        let instance = CardService.shared
        let result = instance.fetch_top_convenient()
        XCTAssert(result.count == UserDefaults.standard.integer(forKey: "max_study"), "Fetch top failed.")
    }
    
}
