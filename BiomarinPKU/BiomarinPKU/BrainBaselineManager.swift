//
//  BrainBaselineManager.swift
//  BiomarinPKU
//
//  Copyright © 2017 Sage Bionetworks. All rights reserved.
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

import BridgeApp
import BrainBaseline

/**
 BrainBaseline results are uploaded to their servers for processing, and the processed values
 will be exported from there directly into Synapse. All that will be uploaded to Bridge from
 here will be the usual metadata. The results returned for the dashboard need to reference the
 user context.
 */

class BrainBaselineManager: NSObject {
    
    static let studyId = "biomarin-pku-screening-no-upload"
    
    static let studyBundle: Bundle = {
        let studyBundlePath = Bundle.main.path(forResource: "BBLStudy-BioMarin-PKU", ofType: "bundle")!
        return Bundle(path: studyBundlePath)!
    }()
    
    static let brainBaselineContext: BBLContext = {
        return BBLContext(studyId: studyId, resourceBundle: studyBundle, serverInfo: BBLServerInfo.default())
    }()
    
    class func bbIdentifier() -> String? {
        return nil
    }
}
