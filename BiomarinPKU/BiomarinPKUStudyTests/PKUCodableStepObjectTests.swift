//
//  PKUCodableStepObjectTests.swift
//  BiomarinPKUTests
//
//  Copyright © 2019 Sage Bionetworks. All rights reserved.
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
@testable import Research
@testable import BiomarinPKU_Study

class PKUCodableStepObjectTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // setup to have an image wrapper delegate set so the image wrapper won't crash
        RSDImageWrapper.sharedDelegate = TestImageWrapperDelegate()
        
        // Use a statically defined timezone.
        rsd_ISO8601TimestampFormatter.timeZone = TimeZone(secondsFromGMT: Int(-2.5 * 60 * 60))
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBrainBaselinStepObject_Codable() {
        
        let json = """
        {
            "identifier"   : "foo",
            "type"         : "brainBaseline",
            "testName"     : "PTBlink-Phone-BioMarin-PKU"
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let factory = PKUTaskFactory()
            let decoder = factory.createJSONDecoder()
            
            let object = try decoder.decode(BrainBaselineStepObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.testName, "PTBlink-Phone-BioMarin-PKU")
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testBrainBaselinOverviewStepObject_Codable() {
        
        let json = """
        {
            "identifier": "foo",
            "type": "brainBaselineOverview",
            "title": "Hello World!",
            "text": "Some text.",
            "image": {    "type": "fetchable",
                          "imageName": "before" },
            "measurements"  : "measurements",
            "yourObjective" : "objective",
            "instructions"  : "instructions",
            "actions": { "goForward": { "type" : "default",
                                        "buttonTitle" : "Go, Dogs! Go!" },
                         "learnMore": { "type" : "videoView",
                                        "buttonTitle" : "video title",
                                        "url" : "url.mp4" }
                        }

        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {

            let factory = PKUTaskFactory()
            let decoder = factory.createJSONDecoder()
            
            let object = try decoder.decode(BrainBaselineOverviewStepObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.title, "Hello World!")
            XCTAssertEqual(object.text, "Some text.")
            XCTAssertEqual((object.imageTheme as? RSDFetchableImageThemeElementObject)?.imageName, "before")
            
            XCTAssertEqual(object.measurements, "measurements")
            XCTAssertEqual(object.yourObjective, "objective")
            XCTAssertEqual(object.instructions, "instructions")
            
            let goForwardAction = object.action(for: .navigation(.goForward), on: object)
            XCTAssertNotNil(goForwardAction)
            XCTAssertEqual(goForwardAction?.buttonTitle, "Go, Dogs! Go!")
            
            let learnMoreAction = object.action(for: .navigation(.learnMore), on: object)
            XCTAssertNotNil(learnMoreAction)
            XCTAssertEqual((learnMoreAction as? RSDVideoViewUIActionObject)?.buttonTitle, "video title")
            XCTAssertEqual((learnMoreAction as? RSDVideoViewUIActionObject)?.url, "url.mp4")
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testReminderStepObject_Codable() {
        
        let json = """
        {
            "identifier": "foo",
            "type": "reminder",
            "title": "Hello World!",
            "text": "Some text.",
            "image": {    "type": "fetchable",
                          "imageName": "before" },
            "alwaysShow"  : true,
            "defaultDayOfWeek" : "Saturday",
            "defaultTime"  : "9:00 AM",
            "doNotRemindMeTitle" : "title 2",
            "hideDayOfWeek"  : true,
            "reminderType"  : "cognition",
            "actions": { "goForward": { "type" : "default",
                                        "buttonTitle" : "Go, Dogs! Go!" }}

        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let factory = PKUTaskFactory()
            let decoder = factory.createJSONDecoder()
            
            let object = try decoder.decode(ReminderStepObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.title, "Hello World!")
            XCTAssertEqual(object.text, "Some text.")
            XCTAssertEqual((object.imageTheme as? RSDFetchableImageThemeElementObject)?.imageName, "before")
            
            XCTAssertEqual(object.alwaysShow, true)
            XCTAssertEqual(object.hideDayOfWeek, true)
            XCTAssertEqual(object.defaultTime, "9:00 AM")
            XCTAssertEqual(object.defaultDayOfWeek, "Saturday")
            XCTAssertEqual(object.doNotRemindMeTitle, "title 2")
            XCTAssertEqual(object.reminderType, ReminderType.cognition)
            
            let goForwardAction = object.action(for: .navigation(.goForward), on: object)
            XCTAssertNotNil(goForwardAction)
            XCTAssertEqual(goForwardAction?.buttonTitle, "Go, Dogs! Go!")
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
}

struct TestImageWrapperDelegate : RSDImageWrapperDelegate {
    func fetchImage(for imageWrapper: RSDImageWrapper, callback: @escaping ((String?, RSDImage?) -> Void)) {
        DispatchQueue.main.async {
            callback(imageWrapper.imageName, nil)
        }
    }
}
