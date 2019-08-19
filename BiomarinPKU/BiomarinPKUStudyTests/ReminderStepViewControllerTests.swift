//
// ReminderStepViewControllerTests.swift
// BiomarinPKUStudyTests

// Copyright © 2019 Sage Bionetworks. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2.  Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission. No license is granted to the trademarks of
// the copyright holders even if such marks are included in this software.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

import Foundation
import XCTest
import BridgeApp
@testable import BiomarinPKU_Study

class ReminderStepViewControllerTests: XCTestCase {
    
    open var manager: MockReminderManager {
        return ReminderManager.shared as! MockReminderManager
    }
    
    let vc = ReminderStepViewController(nibName: nil, bundle: nil)
    let reminderStep = ReminderStepObject(identifier: "reminder")
    
    override func setUp() {
        super.setUp()
        ReminderManager.shared = MockReminderManager()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSkipRule() {
        reminderStep.alwaysShow = true
        self.manager.hasReminderBeenScheduled = true
        XCTAssertFalse(reminderStep.shouldSkipStep(with: nil, isPeeking: false))
        
        reminderStep.alwaysShow = false
        self.manager.hasReminderBeenScheduled = true
        XCTAssertTrue(reminderStep.shouldSkipStep(with: nil, isPeeking: false))
        
        reminderStep.alwaysShow = true
        self.manager.hasReminderBeenScheduled = false
        XCTAssertFalse(reminderStep.shouldSkipStep(with: nil, isPeeking: false))
        
        reminderStep.alwaysShow = false
        self.manager.hasReminderBeenScheduled = false
        XCTAssertFalse(reminderStep.shouldSkipStep(with: nil, isPeeking: false))
    }
    
    func testFindDoNotRemindAnswer() {
        for type in ReminderType.allCases {
            var result = RSDTaskResultObject(identifier: "task")
            
            XCTAssertNil(manager.findDoNotRemindAnswer(for: type, from: result))
            result.stepHistory.append(vc.createDoNotRemindResult(doNotRemind: true, for: type))
            XCTAssertTrue(manager.findDoNotRemindAnswer(for: type, from: result)!)
            
            XCTAssertNil(manager.findTimeAnswer(for: type, from: result))
            result.stepHistory.append(vc.createTimeReseult(timeStr: "9:00 AM", for: type))
            let timeAnswer = manager.findTimeAnswer(for: type, from: result)
            XCTAssertNotNil(timeAnswer)
            XCTAssertEqual(timeAnswer, "9:00 AM")
            
            XCTAssertNil(manager.findDayAnswer(for: type, from: result))
            result.stepHistory.append(vc.createDayResult(day: RSDWeekday.sunday, for: type))
            let dayAnswer = manager.findDayAnswer(for: type, from: result)
            XCTAssertNotNil(dayAnswer)
            XCTAssertEqual(dayAnswer, RSDWeekday.sunday)
        }
    }
}

