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
import MotorControl
@testable import BiomarinPKU_Study

class ActivityScheduleManagerTests: XCTestCase {
    
    let scheduleManager = TestableWeek1ScheduleManager()
    
    let PKUStudyTaskIdentifiers = [
        "RestingKineticTremor",
        "Attentional Blink",
        "Daily Check-In",
        "Sleep Check-In",
        "Task Switch",
        "Go No Go",
        "Tremor",
        "N Back",
        "RestingKineticTremor",
        "Tapping",
        "Kinetic Tremor",
        "Spatial Memory",
        "Symbol Substitution"]
    
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
            XCTAssertEqual(taskId, RSDIdentifier.sleepCheckInTask.rawValue)
        }
    }
    
    func testWeek1Daily() {
        for i in 1...7 {
            let taskId = ActivityType.daily.taskIdentifier(for: i)
            XCTAssertEqual(taskId, RSDIdentifier.dailyCheckInTask.rawValue)
        }
    }
    
    func testWeek1Cognition() {
        let day1 = ActivityType.cognition.taskIdentifier(for: 1)
        XCTAssertEqual(day1, RSDIdentifier.goNoGoTask.rawValue)
        
        let day2 = ActivityType.cognition.taskIdentifier(for: 2)
        XCTAssertEqual(day2, RSDIdentifier.symbolSubstitutionTask.rawValue)
        
        let day3 = ActivityType.cognition.taskIdentifier(for: 3)
        XCTAssertEqual(day3, RSDIdentifier.spatialMemoryTask.rawValue)
        
        let day4 = ActivityType.cognition.taskIdentifier(for: 4)
        XCTAssertEqual(day4, RSDIdentifier.nBackTask.rawValue)
        
        let day5 = ActivityType.cognition.taskIdentifier(for: 5)
        XCTAssertEqual(day5, RSDIdentifier.taskSwitchTask.rawValue)
        
        let day6 = ActivityType.cognition.taskIdentifier(for: 6)
        XCTAssertEqual(day6, RSDIdentifier.attentionalBlinkTask.rawValue)
        
        let day7 = ActivityType.cognition.taskIdentifier(for: 7)
        XCTAssertEqual(day7, RSDIdentifier.goNoGoTask.rawValue)
        
        for dayIdx in 8...14 { // Week 2
            let day = ActivityType.cognition.taskIdentifier(for: dayIdx)
            XCTAssertEqual(day, RSDIdentifier.symbolSubstitutionTask.rawValue)
        }
        
        for dayIdx in 15...21 { // Week 3
            let day = ActivityType.cognition.taskIdentifier(for: dayIdx)
            XCTAssertEqual(day, RSDIdentifier.spatialMemoryTask.rawValue)
        }
        
        for dayIdx in 22...28 { // Week 3
            let day = ActivityType.cognition.taskIdentifier(for: dayIdx)
            XCTAssertEqual(day, RSDIdentifier.nBackTask.rawValue)
        }
        
        for dayIdx in 29...35 { // Week 4
            let day = ActivityType.cognition.taskIdentifier(for: dayIdx)
            XCTAssertEqual(day, RSDIdentifier.taskSwitchTask.rawValue)
        }
        
        for dayIdx in 36...42 { // Week 5
            let day = ActivityType.cognition.taskIdentifier(for: dayIdx)
            XCTAssertEqual(day, RSDIdentifier.attentionalBlinkTask.rawValue)
        }
        
        for dayIdx in 43...49 { // Week 6
            let day = ActivityType.cognition.taskIdentifier(for: dayIdx)
            XCTAssertEqual(day, RSDIdentifier.goNoGoTask.rawValue)
        }
        
        for dayIdx in 50...56 { // Week 7
            let day = ActivityType.cognition.taskIdentifier(for: dayIdx)
            XCTAssertEqual(day, RSDIdentifier.symbolSubstitutionTask.rawValue)
        }
    }
    
    func testWeek1Physical() {
        let day1 = ActivityType.physical.taskIdentifier(for: 1)
        XCTAssertEqual(day1, RSDIdentifier.tappingTask.rawValue)
        
        let day2 = ActivityType.physical.taskIdentifier(for: 2)
        XCTAssertEqual(day2, RSDIdentifier.restingKineticTremorTask.rawValue)
        
        let day3 = ActivityType.physical.taskIdentifier(for: 3)
        XCTAssertEqual(day3, RSDIdentifier.tappingTask.rawValue)
        
        let day4 = ActivityType.physical.taskIdentifier(for: 4)
        XCTAssertEqual(day4, RSDIdentifier.restingKineticTremorTask.rawValue)
        
        let day5 = ActivityType.physical.taskIdentifier(for: 5)
        XCTAssertEqual(day5, RSDIdentifier.tappingTask.rawValue)
        
        let day6 = ActivityType.physical.taskIdentifier(for: 6)
        XCTAssertEqual(day6, RSDIdentifier.restingKineticTremorTask.rawValue)
        
        let day7 = ActivityType.physical.taskIdentifier(for: 7)
        XCTAssertEqual(day7, RSDIdentifier.tappingTask.rawValue)
        
        for dayIdx in 8...14 { // Week 2
            let day = ActivityType.physical.taskIdentifier(for: dayIdx)
            XCTAssertEqual(day, RSDIdentifier.restingKineticTremorTask.rawValue)
        }
        
        for dayIdx in 15...21 { // Week 3
            let day = ActivityType.physical.taskIdentifier(for: dayIdx)
            XCTAssertEqual(day, RSDIdentifier.tappingTask.rawValue)
        }
        
        for dayIdx in 22...28 { // Week 3
            let day = ActivityType.physical.taskIdentifier(for: dayIdx)
            XCTAssertEqual(day, RSDIdentifier.restingKineticTremorTask.rawValue)
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
    
    func testDataValidScenarios() {
        // As of now, only resting kinetic tremor data can be invalid
        // Make sure all tasks are valid
        for identifier in scheduleManager.endOfStudySortOrder {
            if identifier != .restingKineticTremorTask {
                XCTAssertTrue(scheduleManager.isDataValid(taskResult: RSDTaskResultObject(identifier: identifier.rawValue)).isValid)
            }
        }
        
        // Test successful scenarios
        var result = self.createValidResult(hand: .left)
        var validity = scheduleManager.isDataValid(taskResult: result)
        XCTAssertTrue(validity.isValid)
        XCTAssertNil(validity.errorMsg)
        
        result = self.createValidResult(hand: .right)
        validity = scheduleManager.isDataValid(taskResult: result)
        XCTAssertTrue(validity.isValid)
        XCTAssertNil(validity.errorMsg)
        
        result = self.createValidResult(hand: .both)
        validity = scheduleManager.isDataValid(taskResult: result)
        XCTAssertTrue(validity.isValid)
        XCTAssertNil(validity.errorMsg)
    }
    
    func testMultipleScheduledActivities_studyStartDate() {
        
        let studyStart = studyDate(11, 9, 22, 0) // "2019-08-11T09:22:00Z"
        let mockToday = studyDate2021Jan(28, 9, 22, 0) // "2021-01-28T09:22:00Z"
        
        let testScheduleManager = TestableWeek1ScheduleManager()
        testScheduleManager.mockToday = mockToday
        
        // In late January 2021, there was a bug introduced
        // to bridge which trigger a user's schedules to be
        // re-created with a scheduledOn date equal to that day
        // This caused the app to think it was on study day 1
        //
        // To fix this and test to avoid this in the future,
        // let's duplicate activities, all dated after
        // the intial schedule, and make sure the activity manager
        // still knows the correct study start date
        var scheduledActivities = [MockScheduledActivity]()

        for taskId in PKUStudyTaskIdentifiers {
            scheduledActivities.append(MockScheduledActivity(identifier: taskId, scheduledOnDate: mockToday))
        }
        
        for taskId in PKUStudyTaskIdentifiers {
            scheduledActivities.append(MockScheduledActivity(identifier: taskId, scheduledOnDate: studyStart))
        }
        
        testScheduleManager.scheduledActivities = scheduledActivities
        
        // Test that we get the study start date start of day
        XCTAssertEqual(studyStart.startOfDay(), testScheduleManager.studyStartDate)
        
        // Reverse the order of the scheduled activities and test again
        // This tests that it is order independent, which was failing
        // before with the study start date not being the oldest scheduledOn date
        scheduleManager.scheduledActivities = scheduledActivities.reversed()
        XCTAssertEqual(studyStart.startOfDay(), testScheduleManager.studyStartDate)
    }
    
    func testDataInvalidHandSelectionScenarios() {
        // Test no hand selection
        var result = self.createValidResult(hand: .left)
        result.removeStepHistory(from: MCTHandSelectionDataSource.selectionKey)
        let validity = scheduleManager.isDataValid(taskResult: result)
        XCTAssertFalse(validity.isValid)
        XCTAssertEqual(validity.errorMsg, "Missing hand selection answer result")
    }
    
    func testDataInvalidLeftScenarios() {
        // Test missing left resting hand motion data
        var result = self.createValidResult(hand: .left)
        result.appendStepHistory(with: self.removeMotionAsync(result, "restingLeft"))
        var validity = scheduleManager.isDataValid(taskResult: result)
        XCTAssertFalse(validity.isValid)
        XCTAssertEqual(validity.errorMsg, "Missing required left resting motion file result")
        
        result = self.createValidResult(hand: .both)
        result.appendStepHistory(with: self.removeMotionAsync(result, "restingLeft"))
        validity = scheduleManager.isDataValid(taskResult: result)
        XCTAssertFalse(validity.isValid)
        XCTAssertEqual(validity.errorMsg, "Missing required left resting motion file result")
        
        // Test missing left kinetic hand motion data
        result = self.createValidResult(hand: .left)
        result.appendStepHistory(with: self.removeMotionAsync(result, "kineticLeft"))
        validity = scheduleManager.isDataValid(taskResult: result)
        XCTAssertFalse(validity.isValid)
        XCTAssertEqual(validity.errorMsg, "Missing required left kinetic motion file result")
        
        result = self.createValidResult(hand: .both)
        result.appendStepHistory(with: self.removeMotionAsync(result, "kineticLeft"))
        validity = scheduleManager.isDataValid(taskResult: result)
        XCTAssertFalse(validity.isValid)
        XCTAssertEqual(validity.errorMsg, "Missing required left kinetic motion file result")
    }
    
    func testDataInvalidRightScenarios() {
        // Test missing right resting hand motion data
        var result = self.createValidResult(hand: .right)
        result.appendStepHistory(with: self.removeMotionAsync(result, "restingRight"))
        var validity = scheduleManager.isDataValid(taskResult: result)
        XCTAssertFalse(validity.isValid)
        XCTAssertEqual(validity.errorMsg, "Missing required right resting motion file result")
        
        result = self.createValidResult(hand: .both)
        result.appendStepHistory(with: self.removeMotionAsync(result, "restingRight"))
        validity = scheduleManager.isDataValid(taskResult: result)
        XCTAssertFalse(validity.isValid)
        XCTAssertEqual(validity.errorMsg, "Missing required right resting motion file result")
        
        // Test missing right kinetic hand motion data
        result = self.createValidResult(hand: .right)
        result.appendStepHistory(with: self.removeMotionAsync(result, "kineticRight"))
        validity = scheduleManager.isDataValid(taskResult: result)
        XCTAssertFalse(validity.isValid)
        XCTAssertEqual(validity.errorMsg, "Missing required right kinetic motion file result")
        
        result = self.createValidResult(hand: .both)
        result.appendStepHistory(with: self.removeMotionAsync(result, "kineticRight"))
        validity = scheduleManager.isDataValid(taskResult: result)
        XCTAssertFalse(validity.isValid)
        XCTAssertEqual(validity.errorMsg, "Missing required right kinetic motion file result")
    }
    
    fileprivate func removeMotionAsync(_ result: RSDTaskResult, _ subtaskResultIdentifier: String) -> RSDTaskResultObject {
        var motionTaskResult = result.findResult(with: subtaskResultIdentifier) as! RSDTaskResultObject
        motionTaskResult.asyncResults!.remove(where: { $0.identifier == "motion" })
        return motionTaskResult
    }
    
    fileprivate func createValidResult(hand: MCTHandSelection) -> RSDTaskResultObject {
        var result = RSDTaskResultObject(identifier: RSDIdentifier.restingKineticTremorTask.rawValue)
        
        result.appendStepHistory(with: RSDAnswerResultObject(identifier: MCTHandSelectionDataSource.selectionKey, answerType: .string, value: hand.rawValue))
        
        if hand == .left || hand == .both {
            var subTaskResultResting = RSDTaskResultObject(identifier: "restingLeft")
            subTaskResultResting.appendAsyncResult(with: RSDFileResultObject(identifier: "motion"))
            result.appendStepHistory(with: subTaskResultResting)
            
            var subTaskResultKinetic = RSDTaskResultObject(identifier: "kineticLeft")
            subTaskResultKinetic.appendAsyncResult(with: RSDFileResultObject(identifier: "motion"))
            result.appendStepHistory(with: subTaskResultKinetic)
        }
        
        if hand == .right || hand == .both {
            var subTaskResultResting = RSDTaskResultObject(identifier: "restingRight")
            subTaskResultResting.appendAsyncResult(with: RSDFileResultObject(identifier: "motion"))
            result.appendStepHistory(with: subTaskResultResting)
            
            var subTaskResultKinetic = RSDTaskResultObject(identifier: "kineticRight")
            subTaskResultKinetic.appendAsyncResult(with: RSDFileResultObject(identifier: "motion"))
            result.appendStepHistory(with: subTaskResultKinetic)
        }
        
        return result
    }
    
    private func studyDate(_ day: Int, _ hour: Int, _ min: Int, _ sec: Int) -> Date {
        return Calendar.current.date(from: DateComponents(year: 2019, month: 8, day: day, hour: hour, minute: min, second: sec))!
    }
    
    private func studyDate2021Jan(_ day: Int, _ hour: Int, _ min: Int, _ sec: Int) -> Date {
        return Calendar.current.date(from: DateComponents(year: 2021, month: 1, day: day, hour: hour, minute: min, second: sec))!
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
    var mockActivityIdentifier = String()
    
    override open var scheduledOn: Date {
        get {
            return mockScheduledOn
        }
        set(newScheduledOn) {
            mockScheduledOn = newScheduledOn
        }
    }
    
    override open var activityIdentifier: String? {
        return mockActivityIdentifier
    }
    
    init(scheduledOnDate: Date) {
        super.init()
        mockScheduledOn = scheduledOnDate
    }
    
    init(identifier: String, scheduledOnDate: Date) {
        super.init()
        mockScheduledOn = scheduledOnDate
        mockActivityIdentifier = identifier
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
