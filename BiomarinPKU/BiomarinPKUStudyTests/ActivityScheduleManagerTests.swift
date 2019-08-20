//
// ActivityScheduleManagerTests.swift
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

class ActivityScheduleManagerTests: XCTestCase {
    
    let scheduleManager = TestableWeek1ScheduleManager()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testWeek1Sleep() {
        for i in 1...7 {
            let taskId = ActivityType.sleep.taskIdentifier(for: i)
            XCTAssertEqual(taskId, RSDIdentifier.sleepCheckInTask.identifier)
        }
    }
    
    func testWeek1Daily() {
        for i in 1...7 {
            let taskId = ActivityType.daily.taskIdentifier(for: i)
            XCTAssertEqual(taskId, RSDIdentifier.dailyCheckInTask.identifier)
        }
    }
    
    func testWeek1Cognition() {
        let day1 = ActivityType.cognition.taskIdentifier(for: 1)
        XCTAssertEqual(day1, RSDIdentifier.goNoGoTask.identifier)
        
        let day2 = ActivityType.cognition.taskIdentifier(for: 2)
        XCTAssertEqual(day2, RSDIdentifier.symbolSubstitutionTask.identifier)
        
        let day3 = ActivityType.cognition.taskIdentifier(for: 3)
        XCTAssertEqual(day3, RSDIdentifier.spatialMemoryTask.identifier)
        
        let day4 = ActivityType.cognition.taskIdentifier(for: 4)
        XCTAssertEqual(day4, RSDIdentifier.nBackTask.identifier)
        
        let day5 = ActivityType.cognition.taskIdentifier(for: 5)
        XCTAssertEqual(day5, RSDIdentifier.taskSwitchTask.identifier)
        
        let day6 = ActivityType.cognition.taskIdentifier(for: 6)
        XCTAssertEqual(day6, RSDIdentifier.attentionalBlinkTask.identifier)
        
        let day7 = ActivityType.cognition.taskIdentifier(for: 7)
        XCTAssertEqual(day7, RSDIdentifier.goNoGoTask.identifier)
        
        for dayIdx in 8...14 { // Week 2
            let day = ActivityType.cognition.taskIdentifier(for: dayIdx)
            XCTAssertEqual(day, RSDIdentifier.symbolSubstitutionTask.identifier)
        }
        
        for dayIdx in 15...21 { // Week 3
            let day = ActivityType.cognition.taskIdentifier(for: dayIdx)
            XCTAssertEqual(day, RSDIdentifier.spatialMemoryTask.identifier)
        }
        
        for dayIdx in 22...28 { // Week 3
            let day = ActivityType.cognition.taskIdentifier(for: dayIdx)
            XCTAssertEqual(day, RSDIdentifier.nBackTask.identifier)
        }
        
        for dayIdx in 29...35 { // Week 4
            let day = ActivityType.cognition.taskIdentifier(for: dayIdx)
            XCTAssertEqual(day, RSDIdentifier.taskSwitchTask.identifier)
        }
        
        for dayIdx in 36...42 { // Week 5
            let day = ActivityType.cognition.taskIdentifier(for: dayIdx)
            XCTAssertEqual(day, RSDIdentifier.attentionalBlinkTask.identifier)
        }
        
        for dayIdx in 43...49 { // Week 6
            let day = ActivityType.cognition.taskIdentifier(for: dayIdx)
            XCTAssertEqual(day, RSDIdentifier.goNoGoTask.identifier)
        }
        
        for dayIdx in 50...56 { // Week 7
            let day = ActivityType.cognition.taskIdentifier(for: dayIdx)
            XCTAssertEqual(day, RSDIdentifier.symbolSubstitutionTask.identifier)
        }
    }
    
    func testWeek1Physical() {
        let day1 = ActivityType.physical.taskIdentifier(for: 1)
        XCTAssertEqual(day1, RSDIdentifier.tappingTask.identifier)
        
        let day2 = ActivityType.physical.taskIdentifier(for: 2)
        XCTAssertEqual(day2, RSDIdentifier.tremorTask.identifier)
        
        let day3 = ActivityType.physical.taskIdentifier(for: 3)
        XCTAssertEqual(day3, RSDIdentifier.kineticTremorTask.identifier)
        
        let day4 = ActivityType.physical.taskIdentifier(for: 4)
        XCTAssertEqual(day4, RSDIdentifier.tappingTask.identifier)
        
        let day5 = ActivityType.physical.taskIdentifier(for: 5)
        XCTAssertEqual(day5, RSDIdentifier.tremorTask.identifier)
        
        let day6 = ActivityType.physical.taskIdentifier(for: 6)
        XCTAssertEqual(day6, RSDIdentifier.kineticTremorTask.identifier)
        
        let day7 = ActivityType.physical.taskIdentifier(for: 7)
        XCTAssertEqual(day7, RSDIdentifier.tappingTask.identifier)
        
        for dayIdx in 8...14 { // Week 2
            let day = ActivityType.physical.taskIdentifier(for: dayIdx)
            XCTAssertEqual(day, RSDIdentifier.tremorTask.identifier)
        }
        
        for dayIdx in 15...21 { // Week 3
            let day = ActivityType.physical.taskIdentifier(for: dayIdx)
            XCTAssertEqual(day, RSDIdentifier.kineticTremorTask.identifier)
        }
        
        for dayIdx in 22...28 { // Week 3
            let day = ActivityType.physical.taskIdentifier(for: dayIdx)
            XCTAssertEqual(day, RSDIdentifier.tappingTask.identifier)
        }
    }
    
    func testCompleteDefaultKey() {
        XCTAssertEqual(ActivityType.sleep.completeDefaultKey(for: 1), "sleepDay1")
        XCTAssertEqual(ActivityType.daily.completeDefaultKey(for: 1), "dailyDay1")
        XCTAssertEqual(ActivityType.cognition.completeDefaultKey(for: 1), "cognitionDay1")
        XCTAssertEqual(ActivityType.physical.completeDefaultKey(for: 1), "physicalDay1")
        
        XCTAssertEqual(ActivityType.sleep.completeDefaultKey(for: 7), "sleepDay7")
        XCTAssertEqual(ActivityType.daily.completeDefaultKey(for: 7), "dailyDay7")
        XCTAssertEqual(ActivityType.cognition.completeDefaultKey(for: 7), "cognitionDay7")
        XCTAssertEqual(ActivityType.physical.completeDefaultKey(for: 7), "physicalDay7")
        
        XCTAssertEqual(ActivityType.sleep.completeDefaultKey(for: 8), "sleepDay8")
        XCTAssertEqual(ActivityType.daily.completeDefaultKey(for: 8), "dailyDay8")
        XCTAssertEqual(ActivityType.cognition.completeDefaultKey(for: 8), "cognitionWeek2")
        XCTAssertEqual(ActivityType.physical.completeDefaultKey(for:8), "physicalWeek2")
        
        XCTAssertEqual(ActivityType.sleep.completeDefaultKey(for: 14), "sleepDay14")
        XCTAssertEqual(ActivityType.daily.completeDefaultKey(for: 14), "dailyDay14")
        XCTAssertEqual(ActivityType.cognition.completeDefaultKey(for: 14), "cognitionWeek2")
        XCTAssertEqual(ActivityType.physical.completeDefaultKey(for:14), "physicalWeek2")
        
        XCTAssertEqual(ActivityType.sleep.completeDefaultKey(for: 15), "sleepDay15")
        XCTAssertEqual(ActivityType.daily.completeDefaultKey(for: 15), "dailyDay15")
        XCTAssertEqual(ActivityType.cognition.completeDefaultKey(for: 15), "cognitionWeek3")
        XCTAssertEqual(ActivityType.physical.completeDefaultKey(for:15), "physicalWeek3")
    }
    
    func testDayOfStudy() {
        let studyStart = studyDate(11, 9, 22, 0) // "2019-08-11T09:22:00Z"
        scheduleManager.scheduledActivities = [MockScheduledActivity(scheduledOnDate: studyStart)]
        
        scheduleManager.mockToday = studyDate(11, 10, 44, 0) //"2019-08-11T10:44:00Z"
        XCTAssertEqual(scheduleManager.dayOfStudy(), 1)
        
        scheduleManager.mockToday = studyDate(12, 23, 22, 0) // "2019-08-12T23:22:00Z"
        XCTAssertEqual(scheduleManager.dayOfStudy(), 2)
        
        scheduleManager.mockToday = studyDate(13, 1, 00, 0) //"2019-08-13T01:00:00Z"
        XCTAssertEqual(scheduleManager.dayOfStudy(), 3)
        
        scheduleManager.mockToday = studyDate(14, 18, 22, 0) //"2019-08-14T18:22:00"
        XCTAssertEqual(scheduleManager.dayOfStudy(), 4)
        
        scheduleManager.mockToday = studyDate(15, 0, 0, 1) // "2019-08-15T00:00:01Z"
        XCTAssertEqual(scheduleManager.dayOfStudy(), 5)
        
        scheduleManager.mockToday = studyDate(16, 23, 59, 59) // "2019-08-16T23:59:59Z"
        XCTAssertEqual(scheduleManager.dayOfStudy(), 6)
        
        scheduleManager.mockToday = studyDate(17, 12, 0, 0) // "2019-08-17T12:00:00Z"
        XCTAssertEqual(scheduleManager.dayOfStudy(), 7)
    }
    
    func testWeekOfStudy() {
        let studyStart = studyDate(11, 9, 22, 0) // "2019-08-11T09:22:00Z"
        scheduleManager.scheduledActivities = [MockScheduledActivity(scheduledOnDate: studyStart)]
        
        scheduleManager.mockToday = studyDate(11, 10, 44, 0) //"2019-08-11T10:44:00Z"
        XCTAssertEqual(ActivityType.daily.weekOfStudy(dayOfStudy: scheduleManager.dayOfStudy()), 1)
        
        scheduleManager.mockToday = studyDate(12, 23, 22, 0) // "2019-08-12T23:22:00Z"
        XCTAssertEqual(ActivityType.daily.weekOfStudy(dayOfStudy: scheduleManager.dayOfStudy()), 1)
        
        scheduleManager.mockToday = studyDate(13, 1, 00, 0) //"2019-08-13T01:00:00Z"
        XCTAssertEqual(ActivityType.daily.weekOfStudy(dayOfStudy: scheduleManager.dayOfStudy()), 1)
        
        scheduleManager.mockToday = studyDate(14, 18, 22, 0) //"2019-08-14T18:22:00"
        XCTAssertEqual(ActivityType.daily.weekOfStudy(dayOfStudy: scheduleManager.dayOfStudy()), 1)
        
        scheduleManager.mockToday = studyDate(15, 0, 0, 1) // "2019-08-15T00:00:01Z"
        XCTAssertEqual(ActivityType.daily.weekOfStudy(dayOfStudy: scheduleManager.dayOfStudy()), 1)
        
        scheduleManager.mockToday = studyDate(16, 23, 59, 59) // "2019-08-16T23:59:59Z"
        XCTAssertEqual(ActivityType.daily.weekOfStudy(dayOfStudy: scheduleManager.dayOfStudy()), 1)
        
        scheduleManager.mockToday = studyDate(17, 12, 0, 0) // "2019-08-17T12:00:00Z"
        XCTAssertEqual(ActivityType.daily.weekOfStudy(dayOfStudy: scheduleManager.dayOfStudy()), 1)
        
        scheduleManager.mockToday = studyDate(18, 0, 0, 1) // "2019-08-15T00:00:01Z"
        XCTAssertEqual(ActivityType.daily.weekOfStudy(dayOfStudy: scheduleManager.dayOfStudy()), 2)
    }
    
    func testDaliyTypesTest() {
        for dayIdx in 1...7 {
            XCTAssertEqual(ActivityType.dailyTypes(for: dayIdx).count, 4)
        }
        for dayIdx in 8...21 {
            XCTAssertEqual(ActivityType.dailyTypes(for: dayIdx).count, 2)
        }
    }
    
    func testWeeklyTypesTest() {
        for dayIdx in 1...7 {
            XCTAssertEqual(ActivityType.weeklyTypes(for: dayIdx).count, 0)
        }
        for dayIdx in 8...21 {
            XCTAssertEqual(ActivityType.weeklyTypes(for: dayIdx).count, 2)
        }
    }
    
    private func studyDate(_ day: Int, _ hour: Int, _ min: Int, _ sec: Int) -> Date {
        return Calendar.current.date(from: DateComponents(year: 2019, month: 8, day: day, hour: hour, minute: min, second: sec))!
    }
}

class TestableWeek1ScheduleManager: ActivityScheduleManager {
    
    var mockToday = Date()
    
    override open var today: Date {
        return mockToday
    }
    
    public override init() {
        super.init()
    }
}

class MockScheduledActivity: SBBScheduledActivity {
    
    var mockScheduledOn = Date()
    
    override open var scheduledOn: Date {
        get {
            return mockScheduledOn
        }
        set(newScheduledOn) {
            mockScheduledOn = newScheduledOn
        }
    }
    
    init(scheduledOnDate: Date) {
        super.init()
        mockScheduledOn = scheduledOnDate
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
