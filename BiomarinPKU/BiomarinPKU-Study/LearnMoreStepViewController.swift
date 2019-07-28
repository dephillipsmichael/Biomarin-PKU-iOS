//
//  LearnMoreStepViewController.swift
//  BiomarinPKU
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

import Foundation
import BridgeApp

open class LearnMoreStepViewController: SurveyStepViewController {
    
    let learnMoreLabelPadding: CGFloat = 32.0
    
    var learnMoreStep: LearnMoreStepObject? {
        return self.step as? LearnMoreStepObject
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var learnMoreLabel: UILabel?
    
    /// Returns a new step view controller for the specified step.
    /// - parameter step: The step to be presented.
    override public init(step: RSDStep, parent: RSDPathComponent?) {
        super.init(nibName: nil, bundle: nil)
        self.stepViewModel = self.instantiateStepViewModel(for: step, with: parent)
    }
    
    override open func setupHeader(_ header: RSDStepNavigationView) {
        super.setupHeader(header)
        // Uses back button for cancel button in learn more screen
        let image = UIImage(named: "backArrowHeader", in: Bundle(for: RSDWebViewController.self), compatibleWith: self.view.traitCollection)
        header.cancelButton?.setImage(image, for: .normal)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        if (learnMoreLabel == nil) {
            learnMoreLabel = UILabel()
            self.view.addSubview(learnMoreLabel!)
            
            // Setup constraints to have label be under nav header
            if let navHeader = self.navigationHeader {
                learnMoreLabel?.rsd_alignBelow(view: navHeader, padding: learnMoreLabelPadding * 2)
            }
            learnMoreLabel?.rsd_alignToSuperview([.leading, .trailing], padding: learnMoreLabelPadding)
            learnMoreLabel?.translatesAutoresizingMaskIntoConstraints = false
            learnMoreLabel?.numberOfLines = 0
            
            let light = self.designSystem.colorRules.backgroundLight
            learnMoreLabel?.textColor = self.designSystem.colorRules.textColor(on: light, for: .body)
            learnMoreLabel?.font = self.designSystem.fontRules.font(for: .body)
            learnMoreLabel?.text = self.learnMoreStep?.learnMoreText
        }
    }
}

extension RSDStepType {
    public static let learnMore: RSDStepType = "learnMore"
}

extension LearnMoreStepObject: RSDStepViewControllerVendor {
    public func instantiateViewController(with parent: RSDPathComponent?) -> (UIViewController & RSDStepController)? {
        let vc = LearnMoreStepViewController(step: self, parent: parent)
        vc.designSystem = AppDelegate.designSystem
        return vc
    }
}

open class LearnMoreStepObject: RSDUIStepObject {
    
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case learnMoreText
    }
    
    var learnMoreText: String?
    
    override open func copyInto(_ copy: RSDUIStepObject) {
        super.copyInto(copy)
        if let learnMoreStep = copy as? LearnMoreStepObject {
            self.learnMoreText = learnMoreStep.learnMoreText
        }
    }
    
    override open func decode(from decoder: Decoder, for deviceType: RSDDeviceType?) throws {
        try super.decode(from: decoder, for: deviceType)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.learnMoreText = try container.decodeIfPresent(String.self, forKey: .learnMoreText) ?? self.learnMoreText
    }
}
