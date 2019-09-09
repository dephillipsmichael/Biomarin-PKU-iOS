//
//  BrainBaselineStepViewController.swift
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

import UIKit
import BrainBaseline
import BridgeApp
import BridgeAppUI

extension UIInterfaceOrientationMask {
    func includes(orientation: UIInterfaceOrientation) -> Bool {
        switch self {
        case UIInterfaceOrientationMask.portrait:
            return orientation == .portrait
            
        case UIInterfaceOrientationMask.portraitUpsideDown:
            return orientation == .portraitUpsideDown
            
        case UIInterfaceOrientationMask.landscape:
            let orientations: [UIInterfaceOrientation] = [.landscapeLeft, .landscapeRight]
            return orientations.contains(orientation)
            
        case UIInterfaceOrientationMask.landscapeLeft:
            return orientation == .landscapeLeft
            
        case UIInterfaceOrientationMask.landscapeRight:
            return orientation == .landscapeRight
            
        case UIInterfaceOrientationMask.allButUpsideDown:
            let orientations: [UIInterfaceOrientation] = [.landscapeLeft, .landscapeRight, .portrait]
            return orientations.contains(orientation)
            
        default:
            return true
        }
    }
    
    func forcedOrientation(for orientation: UIInterfaceOrientation) -> UIInterfaceOrientation? {
        guard !self.includes(orientation: orientation) else { return nil }
        switch self {
        case UIInterfaceOrientationMask.portrait:
            return .portrait
            
        case UIInterfaceOrientationMask.portraitUpsideDown:
            return .portraitUpsideDown
            
        case UIInterfaceOrientationMask.allButUpsideDown:
            return .landscapeLeft
            
        case UIInterfaceOrientationMask.landscape:
            return orientation == .portrait ? .landscapeRight : .landscapeLeft
            
        case UIInterfaceOrientationMask.landscapeRight:
            return .landscapeRight
            
        case UIInterfaceOrientationMask.landscapeLeft:
            return .landscapeLeft
            
        default:
            return nil
        }
    }
}

open class BrainBaselineStepViewController: RSDStepViewController, BBLPsychTestViewControllerDelegate {
    
    static let bbNibName = String(describing: BrainBaselineStepViewController.self)
    open class var nibName: String {
        return bbNibName
    }
    
    static let bbBundle = Bundle(for: BrainBaselineStepViewController.classForCoder())
    open class var bundle: Bundle {
        return bbBundle
    }
    
    @IBOutlet open weak var instructionLabel: UILabel!
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// Returns a new step view controller for the specified step.
    /// - parameter step: The step to be presented.
    override public init(step: RSDStep, parent: RSDPathComponent?) {
        super.init(nibName: nil, bundle: nil)
        self.stepViewModel = self.instantiateStepViewModel(for: step, with: parent)
    }
    
    public var startDate: Date?
    
    open var testName: String? {
        return (self.step as? BrainBaselineStepObject)?.testName
    }
    
    private var rotationObserver: NSObjectProtocol?
    
    override open func viewWillAppear(_ animated: Bool) {
        (UIApplication.shared.delegate as? SBAAppDelegate)?.orientationLock = .landscape
        super.viewWillAppear(animated)
        
        let design = AppDelegate.designSystem
        let background = design.colorRules.backgroundPrimary
        self.instructionLabel.textColor = design.colorRules.textColor(on: background, for: .heading1)
        self.instructionLabel.font = design.fontRules.font(for: .heading1)
        
        if startDate == nil {
            instructionLabel.text = Localization.localizedString("BRAIN_BASELINE_INSTRUCTION_TEXT")
            start()
        }
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // hack to force orientation to a default allowed value before going forward
        if let defaultMask = (UIApplication.shared.delegate as? SBAAppDelegate)?.defaultOrientationLock,
            let forcedOrientation = defaultMask.forcedOrientation(for: UIApplication.shared.statusBarOrientation)
        {
            UIDevice.current.setValue(forcedOrientation.rawValue, forKey: "orientation")
        }
        
        // Note: syoung 07/11/2017 This method is called *after* the OS sets up to dismiss the view
        // so also need to reset in the scheduled activity manager. (belt + suspenders)
        (UIApplication.shared.delegate as? SBAAppDelegate)?.orientationLock = nil
        
        removeRotationObserver()
    }
    
    override open func start() {
        super.start()
        // If the phone is not already in landscape mode, wait until it is before pushing the Brain Baseline
        // view controller. Otherwise just go for it.
        let orientation = UIApplication.shared.statusBarOrientation
        if (!(orientation == UIInterfaceOrientation.landscapeLeft || orientation == UIInterfaceOrientation.landscapeRight)) {
            // instructionLabel.text = self.step?.text
            self.rotationObserver = NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: OperationQueue.main, using: { (notification) in
                
                // If the new orientation is landscape mode, remove the notification observer and push the Brain
                // Baseline view controller. Otherwise keep waiting.
                let orientation = UIApplication.shared.statusBarOrientation
                if (orientation == UIInterfaceOrientation.landscapeLeft || orientation == UIInterfaceOrientation.landscapeRight) {
                    self.removeRotationObserver()
                    self.deviceDidRotate()
                }
            })
        } else {
            self.deviceDidRotate()
        }
    }
    
    private func removeRotationObserver() {
        guard let observer = self.rotationObserver else { return }
        NotificationCenter.default.removeObserver(observer)
        self.rotationObserver = nil
    }
    
    private func deviceDidRotate() {
        self.startDate = Date()
        instructionLabel.text = ""
        guard let viewController = createTestViewController()
            else {
                testDidFinish(result: nil)
                return
        }
        self.show(viewController, sender: self)
    }
    
    open func createTestViewController() -> UIViewController? {
        do {
            let controller = try BBLPsychTestViewController(psychTestNamed: self.testName!, in: BrainBaselineManager.brainBaselineContext)
            controller.delegate = self
            return UINavigationController(rootViewController: controller)
        }
        catch let error {
            print("Error creating the BBLPsychTestViewController: \(error)")
        }
        return nil
    }
    
    public func psychTestViewControllerDidFinish(_ controller: BBLPsychTestViewController) {
        
        if let resultIdUnwrapped = controller.psychTestResultID {
            do {
                let result = try BBLPsychTestResult(id: resultIdUnwrapped, in: BrainBaselineManager.brainBaselineContext)
                debugPrint("brain baseline result=\(result)")
            }
            catch let error {
                assertionFailure("error getting BBLPsychTestResult for id \(resultIdUnwrapped): \(error)")
            }
        }
        
        self.testDidFinish(result: controller.psychTestResultID)
    }
    
    open override func show(_ vc: UIViewController, sender: Any?) {
        addChild(vc)
        vc.view.frame = self.view.bounds
        view.addSubview(vc.view)
        vc.didMove(toParent: self)
    }
    
    open func testDidFinish(result: Any?) {
        if let vc = self.children.first {
            vc.willMove(toParent: nil)
            vc.view.removeFromSuperview()
            vc.removeFromParent()
            vc.didMove(toParent: nil)
        }
        
        if result == nil {
            // If the user quit the brain baseline task then tell the task view controller delegate that
            // the result was discarded.
            super.cancelTask(shouldSave: false)
        }
        else {
             self.goForward()
        }
    }
}

struct BrainBaselineStepObject : RSDStepViewControllerVendor, Decodable {
    
    let identifier: String
    let testName: String
    
    let stepType: RSDStepType = .brainBaseline
    
    func instantiateStepResult() -> RSDResult {
        // Here we can use the bbIdentifier to later get the result in AppDelegate
        return RSDAnswerResultObject(identifier: "userIdentifier", answerType: .string, value: BrainBaselineManager.bbIdentifier())
    }
    
    func validate() throws {
        // do nothing
    }
    
    func instantiateViewController(with parent: RSDPathComponent?) -> (UIViewController & RSDStepController)? {
        let vc = BrainBaselineStepViewController(step: self, parent: parent)
        return vc
    }
    
    static func examples() -> [[String : RSDJSONValue]] {
        let jsonA: [String : RSDJSONValue] = [
            "identifier"   : "Brain Baseline",
            "type"         : "brainBaseline",
            "testName"     : "PTBlink-Phone-BioMarin-PKU"
        ]
        return [jsonA]
    }
}


