//
// ActivityViewControllerTests.swift
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

class ActivityViewControllerTests: XCTestCase {
    
    let vc = ActivityViewController(nibName: "", bundle: Bundle.main)
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExpiresTime() {
        let expiresTime = date(5, 0, 0, 0)
        
        var now = date(4, 5, 0, 0)
        XCTAssertEqual(vc.timeUntilExpiration(from: now, until: expiresTime), "19:00:00")
        
        now = date(4, 23, 59, 59)
        XCTAssertEqual(vc.timeUntilExpiration(from: now, until: expiresTime), "00:00:01")
        
        now = date(5, 0, 0, 0)
        XCTAssertEqual(vc.timeUntilExpiration(from: now, until: expiresTime), "00:00:00")
        
        now = date(4, 0, 0, 1)
        XCTAssertEqual(vc.timeUntilExpiration(from: now, until: expiresTime), "23:59:59")
        
        now = date(4, 11, 11, 11)
        XCTAssertEqual(vc.timeUntilExpiration(from: now, until: expiresTime), "12:48:49")
    }
    
    func testExpiresLabelText() {
        for dayIdx in 1...7 { // Week 1
            XCTAssertEqual(vc.expiresLabelText(for: dayIdx, expiresTimeStr: "12:34:56"), "Today’s activities expire in 12:34:56")
        }
        for dayIdx in 8...21 { // Week 2
            XCTAssertEqual(vc.expiresLabelText(for: dayIdx, expiresTimeStr: "12:34:56"), "Daily activities expire in 12:34:56")
        }
    }
    
    func testDayTitleLabelText() {
        XCTAssertEqual(vc.dayLabelText(for: 1, week: 1), "1 of 7")
        XCTAssertEqual(vc.dayLabelText(for: 2, week: 1), "2 of 7")
        XCTAssertEqual(vc.dayLabelText(for: 3, week: 1), "3 of 7")
        XCTAssertEqual(vc.dayLabelText(for: 4, week: 1), "4 of 7")
        XCTAssertEqual(vc.dayLabelText(for: 5, week: 1), "5 of 7")
        XCTAssertEqual(vc.dayLabelText(for: 6, week: 1), "6 of 7")
        XCTAssertEqual(vc.dayLabelText(for: 7, week: 1), "7 of 7")
        for dayIdx in 8...14 { // Week 2
            XCTAssertEqual(vc.dayLabelText(for: dayIdx, week: 2), "2")
        }
        for dayIdx in 15...21 { // Week 3
            XCTAssertEqual(vc.dayLabelText(for: dayIdx, week: 3), "3")
        }
    }
    
    func testDayLabelText() {
        for dayIdx in 1...7 { // Week 1
            XCTAssertEqual(vc.dayTitleLabelText(for: dayIdx), "Day")
        }
        for dayIdx in 8...15 { // Week 2 and first day of Week 3
            XCTAssertEqual(vc.dayTitleLabelText(for: dayIdx), "Week")
        }
    }
    
    func testExpiresTimeWeeklyText() {
        for dayIdx in 1...7 { // Week 1, hide weekly expiration text
            XCTAssertNil(vc.expiresWeeklyLabelText(for: dayIdx, week: 1, expiresTimeStr: "12:34:56"))
        }
        XCTAssertEqual(vc.expiresWeeklyLabelText(for: 8, week: 2, expiresTimeStr: "12:34:56"), "Weekly activities expire in 7 days")
        XCTAssertEqual(vc.expiresWeeklyLabelText(for: 9, week: 2, expiresTimeStr: "12:34:56"), "Weekly activities expire in 6 days")
        XCTAssertEqual(vc.expiresWeeklyLabelText(for: 10, week: 2, expiresTimeStr: "12:34:56"), "Weekly activities expire in 5 days")
        XCTAssertEqual(vc.expiresWeeklyLabelText(for: 11, week: 2, expiresTimeStr: "12:34:56"), "Weekly activities expire in 4 days")
        XCTAssertEqual(vc.expiresWeeklyLabelText(for: 12, week: 2, expiresTimeStr: "12:34:56"), "Weekly activities expire in 3 days")
        XCTAssertEqual(vc.expiresWeeklyLabelText(for: 13, week: 2, expiresTimeStr: "12:34:56"), "Weekly activities expire in 2 days")
        XCTAssertEqual(vc.expiresWeeklyLabelText(for: 14, week: 2, expiresTimeStr: "12:34:56"), "Weekly activities expire in 12:34:56")
        XCTAssertEqual(vc.expiresWeeklyLabelText(for: 15, week: 3, expiresTimeStr: "12:34:56"), "Weekly activities expire in 7 days")
    }
    
    private func date(_ day: Int, _ hour: Int, _ min: Int, _ sec: Int) -> Date {
        return Calendar.current.date(from: DateComponents(year: 2019, month: 8, day: day, hour: hour, minute: min, second: sec))!
    }
}

