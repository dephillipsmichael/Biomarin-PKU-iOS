//
//  ExternalIdViewControllerTests.swift
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

class ExternalIdViewControllerTests: XCTestCase {
    
    let vc = ExternalIDRegistrationViewController(nibName: "", bundle: Bundle.main)
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExternalIdFormatting() {
        XCTAssertEqual("0", vc.processNewExternalIdText(oldText: "", newText: "0"))
        XCTAssertEqual("01", vc.processNewExternalIdText(oldText: "0", newText: "01"))
        XCTAssertEqual("012", vc.processNewExternalIdText(oldText: "01", newText: "012"))
        XCTAssertEqual("0123 - ", vc.processNewExternalIdText(oldText: "012", newText: "0123"))
        XCTAssertEqual("0123 - 4", vc.processNewExternalIdText(oldText: "0123", newText: "0123 - 4"))
        XCTAssertEqual("0123 - 45", vc.processNewExternalIdText(oldText: "0123 - 4", newText: "0123 - 45"))
        XCTAssertEqual("0123 - 456", vc.processNewExternalIdText(oldText: "0123 - 45", newText: "0123 - 456"))
        XCTAssertEqual("0123 - 4567", vc.processNewExternalIdText(oldText: "0123 - 456", newText: "0123 - 4567"))
        
        XCTAssertEqual("0123", vc.processNewExternalIdText(oldText: "0123 - ", newText: "0123 -"))
        XCTAssertEqual("0123 - 4", vc.processNewExternalIdText(oldText: "0123", newText: "01234"))
    }
}
