//
//  FinalTests.swift
//  FinalTests
//
//  Created by Zippo Xie on 11/18/17.
//  Copyright © 2017 Zippo Xie. All rights reserved.
//

import XCTest
@testable import Final

class FinalTests: XCTestCase {
    func test_addCard() {
        DispatchQueue.global().async {
            CardService.shared.addCard()
            DispatchQueue.main.async {
                XCTAssert(CardService.shared.find(title: "New Card", within: 1).fetchedObjects?.count == 1, "AddCard() doesn't work properly.")
            }
        }
        DispatchQueue.global().async {
            let test_card = CardData(title: "testONLY")
            CardService.shared.addCard(with: test_card)
            DispatchQueue.main.async {
                XCTAssert(CardService.shared.find(title: "testONLY", within: 1).fetchedObjects?.count == 1, "AddCard() doesn't work properly.")
            }
        }
        DispatchQueue.global().async {
            let test_card2 = CardData(title: "YetAnotherTest", created_time: Calendar.current.date(byAdding: .day, value: -5, to: Date())!, stage: "Learned", success_study_times: 4, total_study_times: 6, interval: 1440, ease: 1000, due: Calendar.current.date(byAdding: .nanosecond, value: 0, to: Date()))
            CardService.shared.addCard(with: test_card2)
            DispatchQueue.main.async {
                XCTAssert(CardService.shared.find(title: "YetAnotherTest", within: 1).fetchedObjects?.count == 1, "AddCard() doesn't work properly.")
                let endofday = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))
                XCTAssert(CardService.shared.find(title: "YetAnotherTest", before: endofday, within: 1).fetchedObjects?.count == 1, "AddCard() doesn't work properly.")
            }
        }
        
    }
    
    func test_delete() {
        
        DispatchQueue.global().async {
            CardService.shared.wipe_out()
            let test_card = CardData(title: "testONLY")
            CardService.shared.addCard(with: test_card)
            
            let test_card2 = CardData(title: "YetAnotherTest", created_time: Calendar.current.date(byAdding: .day, value: -5, to: Date())!, stage: "Learned", success_study_times: 4, total_study_times: 6, interval: 1440, ease: 1000, due: Calendar.current.date(byAdding: .nanosecond, value: 0, to: Date()))
            CardService.shared.addCard(with: test_card2)
            
            let fetRC1 = CardService.shared.find(title: "testONLY", within: 1)
            let card1 = fetRC1.fetchedObjects!.first!
            CardService.shared.del_card(with: card1)
            
            let fetRC2 = CardService.shared.find(title: "YetAnotherTest", within: 1)
            let card2 = fetRC2.fetchedObjects!.first!
            CardService.shared.del_card(with: card2)
            DispatchQueue.main.async {
                XCTAssert(CardService.shared.total_amount == 0, "delete() doesn't work properly.")
            }
        }
    }
    
    func test_study_unseen() {
        DispatchQueue.global().async {
            CardService.shared.wipe_out()
            let new_card_steps = UserDefaults.standard.object(forKey: "study_steps") as! Array<Int>
            
            let card1 = CardData(title: "testONLY today bad")
            let card2 = CardData(title: "testONLY today good")
            let card3 = CardData(title: "testONLY today easy")
            CardService.shared.addCard(with: card1)
            CardService.shared.addCard(with: card2)
            CardService.shared.addCard(with: card3)
            
            let Card1 = CardService.shared.find(title: "testONLY today bad").fetchedObjects!.first!
            let Card2 = CardService.shared.find(title: "testONLY today good").fetchedObjects!.first!
            let Card3 = CardService.shared.find(title: "testONLY today easy").fetchedObjects!.first!
            
            
            StudyCardService.shared.study(Card1, with: .bad)
            StudyCardService.shared.study(Card2, with: .good)
            StudyCardService.shared.study(Card3, with: .easy)
            
            DispatchQueue.main.async {
                let fiveminutesfromnow = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!
                XCTAssert(Card1.due! <= fiveminutesfromnow, "New card failure condition wronged.")
                
                let nextstepminutesfromnow = Calendar.current.date(byAdding: .minute, value: new_card_steps[0], to: Date())!
                XCTAssert(Card2.due! > fiveminutesfromnow, "New card good condition wronged.")
                XCTAssert(Card2.due! <= nextstepminutesfromnow, "New card good condition wronged.")
                
                let laststepminutesfromnow = Calendar.current.date(byAdding: .minute, value: new_card_steps.last!, to: Date())!
                XCTAssert(Card3.due! >= nextstepminutesfromnow, "New card easy condition wronged.")
                XCTAssert(Card3.due! <= laststepminutesfromnow, "New card easy condition wronged.")
            }
        }
    }
    
    func test_study_review() {
        DispatchQueue.global().async {
            CardService.shared.wipe_out()
            let card1 = CardData(title: "testONLY review bad", stage: "Learned", success_study_times: 5, total_study_times: 10, learning_stage: 5, interval: 1440, ease: 1000, due: Date())
            let card2 = CardData(title: "testONLY review good", stage: "Learned", success_study_times: 5, total_study_times: 10, learning_stage: 5, interval: 1440, ease: 1000, due: Date())
            let card3 = CardData(title: "testONLY review easy", stage: "Learned", success_study_times: 5, total_study_times: 10, learning_stage: 5, interval: 1440, ease: 1000, due: Date())
            let card4 = CardData(title: "testONLY review hard", stage: "Learned", success_study_times: 5, total_study_times: 10, learning_stage: 5, interval: 1440, ease: 1000, due: Date())
            
            CardService.shared.addCard(with: card1)
            CardService.shared.addCard(with: card2)
            CardService.shared.addCard(with: card3)
            CardService.shared.addCard(with: card4)
            
            let Card1 = CardService.shared.find(title: "testONLY review bad").fetchedObjects!.first!
            let Card2 = CardService.shared.find(title: "testONLY review good").fetchedObjects!.first!
            let Card3 = CardService.shared.find(title: "testONLY review easy").fetchedObjects!.first!
            let Card4 = CardService.shared.find(title: "testONLY review hard").fetchedObjects!.first!
            
            StudyCardService.shared.study(Card1, with: .bad)
            StudyCardService.shared.study(Card4, with: .hard)
            StudyCardService.shared.study(Card2, with: .good)
            StudyCardService.shared.study(Card3, with: .easy)
            
            DispatchQueue.main.async {
                XCTAssert(Card1.ease == card1.ease - 200, "Failed card's ease did not change?")
                let fiveminutesfromnow = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!
                XCTAssert(Card1.due! <= fiveminutesfromnow, "Failed card's due did not change correctly?")
                
                XCTAssert(Card4.ease == card4.ease - 150, "Hard card's ease did not change?")
                let twodaysfromnow = Calendar.current.date(byAdding: .day, value: 2, to: Date())!
                XCTAssert(Card4.due! > fiveminutesfromnow, "Hard card's due did not change correctly?")
                XCTAssert(Card4.due! <= twodaysfromnow, "Hard card's due did not change correctly?")
                
                XCTAssert(Card2.ease == card2.ease, "Good card's ease did not change?")
                let threedaysfromnow = Calendar.current.date(byAdding: .day, value: 3, to: Date())!
                XCTAssert(Card2.due! > twodaysfromnow, "Good card's due did not change correctly?")
                XCTAssert(Card2.due! <= threedaysfromnow, "Good card's due did not change correctly?")
                
                XCTAssert(Card3.ease == 1150 , "Easy card's ease did not change?")
                let fourdaysfromnow = Calendar.current.date(byAdding: .day, value: 4, to: Date())!
                XCTAssert(Card3.due! > threedaysfromnow, "Easy card's due did not change correctly?")
                XCTAssert(Card3.due! <= fourdaysfromnow, "Easy card's due did not change correctly?")
            }
        }
        
    }
    
}
