//
//  BrainBaselineOverviewStepViewController.swift
//  PKU
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

import UIKit
import BridgeApp

/// The scrolling brainbaseline overview step view controller is a custom subclass of
/// uses a scrollview to allow showing detailed overview instructions.
open class BrainBaselineOverviewStepViewController: RSDStepViewController {

    /// The label which tells the user the title of the measurement text section
    @IBOutlet
    open weak var measurementTitleLabel: UILabel!
    
    /// The label which tells the user the text of the measurement text section
    @IBOutlet
    open weak var measurementTextLabel: UILabel!
    
    /// The label which tells the user the title of the your objective text section
    @IBOutlet
    open weak var yourObjectiveTitleLabel: UILabel!
    
    /// The label which tells the user the text of the your objective text section
    @IBOutlet
    open weak var yourObjectiveTextLabel: UILabel!
    
    /// The label which tells the user the title of the instructions text section
    @IBOutlet
    open weak var instructionsTitleLabel: UILabel!
    
    /// The label which tells the user the text of the instructions text section
    @IBOutlet
    open weak var instructionsTextLabel: UILabel!
    
    /// The scrollview that holds all the content
    @IBOutlet
    open weak var scrollView: UILabel!
    
    var overviewStep: BrainBaselineOverviewStepObject? {
        return self.step as? BrainBaselineOverviewStepObject
    }
  
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationHeader?.titleLabel?.text = self.overviewStep?.title
        self.navigationHeader?.textLabel?.text = self.overviewStep?.text
        
        self.measurementTitleLabel.text = Localization.localizedString("BRAIN_BASELINE_MEASUREMENTS_TITLE")
        if let text = self.overviewStep?.measurements {
            self.measurementTextLabel.text = text
        }
        
        self.yourObjectiveTitleLabel.text = Localization.localizedString("BRAIN_BASELINE_YOUR_OBJECTIVE_TITLE")
        if let text = self.overviewStep?.yourObjective {
            self.yourObjectiveTextLabel.text = text
        }
        
        self.instructionsTitleLabel.text = Localization.localizedString("BRAIN_BASELINE_INSTRUCTIONS_TITLE")
        if let text = self.overviewStep?.instructions {
            self.instructionsTextLabel.text = text
        }
        
        if let learnMore = super.stepViewModel.action(for: .navigation(.learnMore)) {
            self.learnMoreButton?.setTitle(learnMore.buttonTitle ?? "", for: .normal)
        }
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.navigationHeader?.imageView?.layer.cornerRadius = (self.navigationHeader?.imageView?.bounds.width ?? 0) / 2
    }
    
    override open func setColorStyle(for placement: RSDColorPlacement, background: RSDColorTile) {
        super.setColorStyle(for: placement, background: background)
        
        if placement == .body {
            
            self.scrollView.backgroundColor = background.color
            
            [self.measurementTitleLabel, self.yourObjectiveTitleLabel, self.instructionsTitleLabel].forEach ({ (label) in
                label?.font = self.designSystem.fontRules.font(for: .heading3)
                label?.textColor = self.designSystem.colorRules.textColor(on: background, for: .heading3)
            })
            
            [self.measurementTextLabel, self.yourObjectiveTextLabel, self.instructionsTextLabel].forEach ({ (label) in
                label?.font = self.designSystem.fontRules.font(for: .body)
                label?.textColor = self.designSystem.colorRules.textColor(on: background, for: .body)
            })
            
            self.learnMoreButton?.titleLabel?.textColor = self.designSystem.colorRules.textColor(on: background, for: .body)
            
        } else if placement == .header {
            self.navigationHeader?.imageView?.backgroundColor = self.designSystem.colorRules.palette.accent.normal.color
        }
    }
    
    // MARK: Initialization
    
    /// The default nib name to use when instantiating the view controller using `init(step:)`.
    open class var nibName: String {
        return String(describing: BrainBaselineOverviewStepViewController.self)
    }
    
    /// The default bundle to use when instantiating the view controller using `init(step:)`.
    open class var bundle: Bundle {
        return Bundle(for: BrainBaselineOverviewStepViewController.self)
    }

}

open class BrainBaselineOverviewStepObject : RSDUIStepObject, RSDStepViewControllerVendor {
    
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case measurements, yourObjective, instructions
    }
    
    open var measurements: String?
    open var yourObjective: String?
    open var instructions: String?
    
    /// Default type is `.brainBaselineOverview`.
    open override class func defaultType() -> RSDStepType {
        return .brainBaselineOverview
    }
    
    /// Override to set the properties of the subclass.
    override open func copyInto(_ copy: RSDUIStepObject) {
        super.copyInto(copy)
        guard let subclassCopy = copy as? BrainBaselineOverviewStepObject else {
            assertionFailure("Superclass implementation of the `copy(with:)` protocol should return an instance of this class.")
            return
        }
        subclassCopy.measurements = self.measurements
        subclassCopy.yourObjective = self.yourObjective
        subclassCopy.instructions = self.instructions
    }
    
    /// Override the decoder per device type b/c the task may require a different set of permissions depending upon the device.
    open override func decode(from decoder: Decoder, for deviceType: RSDDeviceType?) throws {
        try super.decode(from: decoder, for: deviceType)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.measurements = try container.decodeIfPresent(String.self, forKey: .measurements) ?? self.measurements
        self.yourObjective = try container.decodeIfPresent(String.self, forKey: .yourObjective) ?? self.yourObjective
        self.instructions = try container.decodeIfPresent(String.self, forKey: .instructions) ?? self.instructions
    }
    
    
    open class func codingKeys() -> [CodingKey] {
        return CodingKeys.allCases
    }
    
    open class func examples() -> [[String : RSDJSONValue]] {
        let jsonA: [String : RSDJSONValue] = [
            "identifier"   : "Attentional Blink",
            "type"         : "brainBaselineOverview",
            "title"        : "Attentional Blink",
            "text"         : "3 minutes",
            "measurements" : "Measurements Text",
            "yourObjective": "Your objective Text",
            "instructions" : "Instructions Text"
        ]
        
        return [jsonA]
    }
    
    public func instantiateViewController(with parent: RSDPathComponent?) -> (UIViewController & RSDStepController)? {
        let vc = BrainBaselineOverviewStepViewController(step: self, parent: parent)
        return vc
    }
}
