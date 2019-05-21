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

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSortOrderSchedules() {
        var activities = [SBBScheduledActivity]()
        activities.append(MockScheduledActivity(identifier: "Symbol Substitution"))
        activities.append(MockScheduledActivity(identifier: "Spatial Memory"))
        activities.append(MockScheduledActivity(identifier: "Tapping"))
        activities.append(MockScheduledActivity(identifier: "Kinetic Tremor"))
        activities.append(MockScheduledActivity(identifier: "Attentional Blink"))
        activities.append(MockScheduledActivity(identifier: "Unknown Task"))
        activities.append(MockScheduledActivity(identifier: "N Back"))
        activities.append(MockScheduledActivity(identifier: "Tremor"))
        activities.append(MockScheduledActivity(identifier: "Go No Go"))
        
        let manager = TaskListScheduleManager()
        var expectedResult = manager.sortOrder
        expectedResult.append(RSDIdentifier(rawValue: "Unknown Task"))
        
        var actualResult = manager.sortActivities(activities)
        XCTAssertNotNil(actualResult)
        
        XCTAssertEqual(actualResult?.count, expectedResult.count)
        for (index, expected) in expectedResult.enumerated() {
            let actualRawValue = actualResult![index].activityIdentifier
            XCTAssertEqual(expected.rawValue, actualRawValue)
        }
    }
}

class MockScheduledActivity: SBBScheduledActivity {
    var mockIdentifier: String = ""
    init(identifier: String) {
        super.init()
        mockIdentifier = identifier
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override open var activityIdentifier: String? {
        return mockIdentifier
    }
}
