//
//  BiomarinPKUTests.swift
//  BiomarinPKUTests
//
//  Created by Shannon Young on 5/2/19.
//  Copyright © 2019 Sage Bionetworks. All rights reserved.
//

import XCTest
import BridgeApp
@testable import BiomarinPKU

class TaskListScheduleManagerTests: XCTestCase {

    var activities: [SBBScheduledActivity] = []
    var manager: TaskListScheduleManager = TaskListScheduleManager()
    
    let taskRowEndIndex = 9
    let rowCount = 11
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
        let expectedResult = ["Tapping", "Tremor", "Kinetic Tremor", "Attentional Blink", "Symbol Substitution", "Go No Go", "N Back", "Spatial Memory", "Unknown Task"]
        
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
        let taskSwitchRow = manager.supplementalRow(for: IndexPath(row: 9, section: 0))
        XCTAssertNotNil(taskSwitchRow)
        XCTAssertEqual(TaskListSupplementalRow.TaskSwitch, taskSwitchRow)
        
        let fitbitRow = manager.supplementalRow(for: IndexPath(row: 10, section: 0))
        XCTAssertNotNil(fitbitRow)
        XCTAssertEqual(TaskListSupplementalRow.ConnectFitbit, fitbitRow)
    }
    
    func testSupplementalRowIndex() {
        // Supplemental rows
        XCTAssertEqual(manager.supplementalRowIndex(for: IndexPath(row: 9, section: 0)), 0)
        XCTAssertEqual(manager.supplementalRowIndex(for: IndexPath(row: 10, section: 0)), 1)
    }
    
    func testSortedScheduledActivity() {
        let expectedResultIdentifiers = ["Tapping", "Tremor", "Kinetic Tremor", "Attentional Blink", "Symbol Substitution", "Go No Go", "N Back", "Spatial Memory", "Unknown Task"]
        
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
        let expectedTitles = ["Finger Tapping", "Resting Tremor", "Kinetic Tremor", "Attentional Blink", "Digital Symbol Substitution", "Go-No-Go", "N-Back", "Spatial Working Memory", "Unknown Task Title", "Task Switch", "Connect Fitbit"]

        XCTAssertEqual(expectedTitles.count, rowCount)
        for (index) in 0..<rowCount {
            let title = manager.title(for: IndexPath(row: index, section: 0))
            XCTAssertEqual(expectedTitles[index], title)
        }
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
