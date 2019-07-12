//
// TaskListScheduleManagerTests.swift
// BiomarinPKUTests

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

import XCTest
import BridgeSDK
import BridgeApp
@testable import BiomarinPKU

class TaskListScheduleManagerTests: XCTestCase {

    var activities: [SBBScheduledActivity] = []
    var manager: TaskListScheduleManager = TaskListScheduleManager()
    
    let taskRowEndIndex = 10
    let rowCount = 10
    let sectionCount = 1
    
    override func setUp() {
        activities = MockScheduledActivity.mockActivities()
        manager = TaskListScheduleManager()
        manager.scheduledActivities = activities
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSortOrderSchedules() {
        // Unknown tasks should be sorted at the end
        let expectedResult = ["Tapping", "Tremor", "Kinetic Tremor", "Attentional Blink", "Symbol Substitution", "Go No Go", "N Back", "Spatial Memory", "Task Switch", "Unknown Task"]
        
        var actualResult = manager.sortActivities(activities)
        XCTAssertNotNil(actualResult)
        
        XCTAssertEqual(actualResult?.count, expectedResult.count)
        for (index, expected) in expectedResult.enumerated() {
            let actualRawValue = actualResult![index].activityIdentifier
            XCTAssertEqual(expected, actualRawValue)
        }
    }
    
    func testTableRowCount() {
        XCTAssertEqual(manager.tableRowCount, rowCount)
    }
    
    func testTableSectionCount() {
        XCTAssertEqual(manager.tableSectionCount, sectionCount)
    }
    
    func testIsTaskRow() {
        for (index) in 0..<rowCount {
            if (index < taskRowEndIndex) { // Task Rows
                XCTAssertTrue(manager.isTaskRow(for: IndexPath(row: index, section: 0)))
            } else { // Supplemental rows
                XCTAssertFalse(manager.isTaskRow(for: IndexPath(row: index, section: 0)))
            }
        }
    }
    
    func testIsSupplementalRow() {
        for (index) in 0..<rowCount {
            if (index < taskRowEndIndex) { // Task Rows
                XCTAssertFalse(manager.isTaskSupplementalRow(for: IndexPath(row: index, section: 0)))
            } else { // Supplemental rows
                XCTAssertTrue(manager.isTaskSupplementalRow(for: IndexPath(row: index, section: 0)))
            }
        }
    }
    
    func testIsSupplementalRowIndex() {
        // Supplemental rows
        // Re-enable this test if fitbit is re-added
//        let fitbitRow = manager.supplementalRow(for: IndexPath(row: taskRowEndIndex, section: 0))
//        XCTAssertNotNil(fitbitRow)
//        XCTAssertEqual(TaskListSupplementalRow.ConnectFitbit, fitbitRow)
    }
    
    func testSupplementalRowIndex() {
        // Supplemental rows
        XCTAssertEqual(manager.supplementalRowIndex(for: IndexPath(row: taskRowEndIndex, section: 0)), 0)
        XCTAssertEqual(manager.supplementalRowIndex(for: IndexPath(row: taskRowEndIndex + 1, section: 0)), 1)
    }
    
    func testSortedScheduledActivity() {
        let expectedResultIdentifiers = ["Tapping", "Tremor", "Kinetic Tremor", "Attentional Blink", "Symbol Substitution", "Go No Go", "N Back", "Spatial Memory", "Task Switch", "Unknown Task"]
        
        for (index) in 0..<rowCount {
            if (index < taskRowEndIndex) { // Task Rows
                XCTAssertEqual(manager.sortedScheduledActivity(for: (IndexPath(row: index, section: 0)))?.activityIdentifier ?? "", expectedResultIdentifiers[index])
            } else { // Supplemental Rows
                XCTAssertNil(manager.sortedScheduledActivity(for: IndexPath(row: index, section: 0)))
            }
        }
    }
    
    func testTableRowTitles() {
        // Unknown tasks should be sorted at the end
        // and then the supplemental rows
        let expectedTitles = ["Finger Tapping", "Resting Tremor", "Kinetic Tremor", "Attentional Blink", "Digital Symbol Substitution", "Go-No-Go", "N-Back", "Spatial Working Memory", "Task Switch", "Unknown Task Title"]

        XCTAssertEqual(expectedTitles.count, rowCount)
        for (index) in 0..<rowCount {
            let title = manager.title(for: IndexPath(row: index, section: 0))
            XCTAssertEqual(expectedTitles[index], title)
        }
    }
    
    func testLearnMoreMctOverview() {
        let tappingAction = manager.mctOverviewLearnMoreAction(for: "Tapping")
        XCTAssertNotNil(tappingAction)
        XCTAssertEqual(tappingAction?.buttonTitle, "See this in action")
        XCTAssertEqual(tappingAction?.url, "Tapping.mp4")
        
        let tremorAction = manager.mctOverviewLearnMoreAction(for: "Tremor")
        XCTAssertNotNil(tremorAction)
        XCTAssertEqual(tremorAction?.buttonTitle, "See this in action")
        XCTAssertEqual(tremorAction?.url, "Tremor.mp4")
        
        let kineticAction = manager.mctOverviewLearnMoreAction(for: "Kinetic Tremor")
        XCTAssertNotNil(kineticAction)
        XCTAssertEqual(kineticAction?.buttonTitle, "See this in action")
        XCTAssertEqual(kineticAction?.url, "KineticTremor.mp4")
        
        let checkinAction = manager.mctOverviewLearnMoreAction(for: "Sleep Check-In")
        XCTAssertNil(checkinAction)
    }
    
    func testCustomizeOverviewStepViewModel() {
        
    }
}

class MockScheduledActivity: SBBScheduledActivity {
    var mockIdentifier: String = ""
    init(identifier: String, label: String) {
        super.init()
        mockIdentifier = identifier
        mockActivity = MockActivity(label: label)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override open var activityIdentifier: String? {
        return mockIdentifier
    }
    
    var mockActivity = MockActivity(label: "")
    override open var activity: SBBActivity {
        get {
            return mockActivity
        }
        set(newActivity) {
            mockActivity = newActivity as! MockActivity
        }
    }

    static func mockActivities() -> [SBBScheduledActivity] {
        var activities = [SBBScheduledActivity]()
        activities.append(MockScheduledActivity(identifier: "Symbol Substitution", label: "Digital Symbol Substitution"))
        activities.append(MockScheduledActivity(identifier: "Spatial Memory", label: "Spatial Working Memory"))
        activities.append(MockScheduledActivity(identifier: "Tapping", label: "Finger Tapping"))
        activities.append(MockScheduledActivity(identifier: "Kinetic Tremor", label: "Kinetic Tremor"))
        activities.append(MockScheduledActivity(identifier: "Attentional Blink", label: "Attentional Blink"))
        activities.append(MockScheduledActivity(identifier: "Unknown Task", label: "Unknown Task Title"))
        activities.append(MockScheduledActivity(identifier: "N Back", label: "N-Back"))
        activities.append(MockScheduledActivity(identifier: "Tremor", label: "Resting Tremor"))
        activities.append(MockScheduledActivity(identifier: "Go No Go", label: "Go-No-Go"))
        activities.append(MockScheduledActivity(identifier: "Task Switch", label: "Task Switch"))
        return activities
    }
}

class MockActivity: SBBActivity {
    var mockLabel: String = ""
    override open var label: String {
        get {
            return mockLabel
        }
        set(newLabel) {
            mockLabel = newLabel
        }
    }
    init(label: String) {
        super.init()
        mockLabel = label
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
