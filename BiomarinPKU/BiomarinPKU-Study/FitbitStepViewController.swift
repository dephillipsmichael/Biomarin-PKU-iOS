//
//  FitbitStepViewController.swift
//  PsorcastValidation
//
//  Copyright © 2018-2019 Sage Bionetworks. All rights reserved.
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
import MotorControl
import BridgeApp

class FitbitStep : RSDUIStepObject, RSDStepViewControllerVendor, RSDNavigationSkipRule {
    
    /// The user default key to see if the user has completed their fitbit connection
    public static let isFitbitConnectedKey = "IsFitBitConnected"
    
    public required init(identifier: String, type: RSDStepType? = nil) {
        super.init(identifier: identifier, type: type)
        self.commonInit()
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        commonInit()
    }
    
    private func commonInit() {
        self.title = Localization.localizedString("CONNECT_FITBIT")
        self.text = Localization.localizedString("CONNECT_FITBIT_MSG")
        self.imageTheme = RSDFetchableImageThemeElementObject(imageName: "FitbitHeader")
        self.shouldHideActions = [.navigation(.skip), .navigation(.goBackward)]
        if (self.actions == nil) {
            self.actions = [RSDUIActionType : RSDUIAction]()
        }
        self.actions?[.navigation(.goForward)] = RSDUIActionObject(buttonTitle: Localization.localizedString("BUTTON_NEXT"))
    }
    
    func shouldSkipStep(with result: RSDTaskResult?, isPeeking: Bool) -> Bool {
        return UserDefaults.standard.bool(forKey: FitbitStep.isFitbitConnectedKey)
    }
    
    open func instantiateViewController(with parent: RSDPathComponent?) -> (UIViewController & RSDStepController)? {
        return FitbitStepViewController(step: self, parent: parent)
    }
}

class FitbitStepViewController: RSDStepViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationFooter?.nextButton?.isEnabled = true
    }
    
    override func goForward() {
        
        self.navigationFooter?.nextButton?.isEnabled = false
        
        (AppDelegate.shared as? AppDelegate)?.connectToFitbit(completionHandler: { (toekn, error) in
            
            self.navigationFooter?.nextButton?.isEnabled = true
            
            if let errorUnwrapped = error {
                let errorTitle = "Error connecting to Fitbit"
                let errorMsg = errorUnwrapped.localizedDescription
                debugPrint("\(errorTitle): \(errorMsg)")
                
                let errorAlert = UIAlertController(title: errorTitle, message: errorMsg, preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: Localization.localizedString("BUTTON_OK"), style: .default, handler: { (action: UIAlertAction!) in
                    self.dismiss(animated: true, completion: nil)
                }))
                
                self.present(errorAlert, animated: true, completion: nil)
                return
            }
            
            UserDefaults.standard.set(true, forKey: FitbitStep.isFitbitConnectedKey)
            super.goForward()
        })
    }
}
