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
    
}
