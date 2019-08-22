//
//  ExternalIDRegistrationViewController.swift
//  BiomarinPKU
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
import ResearchUI
import Research
import BridgeSDK
import BridgeApp

class ExternalIDRegistrationStep : RSDUIStepObject, RSDStepViewControllerVendor, RSDNavigationSkipRule {
    
    func shouldSkipStep(with result: RSDTaskResult?, isPeeking: Bool) -> Bool {
        return BridgeSDK.authManager.isAuthenticated()
    }    
    
    open func instantiateViewController(with parent: RSDPathComponent?) -> (UIViewController & RSDStepController)? {
        return ExternalIDRegistrationViewController(step: self, parent: parent)
    }
}

class ExternalIDRegistrationViewController: BaseTextFieldStepViewController, UITextFieldDelegate {
    
    // The first participant ID entry, they need to enter it twice
    var firstEntry: String?
    
    // The hyphen text that is used in the external ID format "XXXX - XXXXX"
    let hyphenText = " - "
    // Format is [4 digit site ID] - [4 digit participant ID]
    let siteIdLength = 4
    let participantIdLength = 4
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.designSystem = AppDelegate.designSystem
        let background = self.designSystem.colorRules.backgroundLight
        self.view.subviews[0].backgroundColor = background.color
        
        #if DEBUG
            // During development, we should use alpha-numeric external IDs
            self.textField.keyboardType = .default
        #else
            // Production external IDs will be of the format
            self.textField.keyboardType = .numberPad
        #endif
        self.textField.delegate = self
        
        setFirstEntryTitle()
    }
    
    func setRentryTitle() {
        self.titleLabel.text = Localization.localizedString("RE_ENTER_PARTICIPANT_ID")
    }
    
    func setFirstEntryTitle() {
        self.titleLabel.text = Localization.localizedString("ENTER_PARTICIPANT_ID")
    }
    
    func setMismatchedParticipantIDTitle() {
        self.titleLabel.text = Localization.localizedString("PARTICPANT_IDS_DID_NOT_MATCH")
    }
    
    func externalId() -> String? {
        let text = self.textField?.text
        if text?.isEmpty ?? true { return nil }
        // Remove the hyphen text from the external ID
        return text?.replacingOccurrences(of: hyphenText, with: "")
    }
    
    ///
    /// The External ID textfield (displayed as Participant ID to the user)
    /// has the format of [4 digit site ID] [4 digit participant ID]
    /// Figma specifies the format should appear to the user as "XXXX - XXXXX".
    ///
    /// TODO: mdephillips 8/3/19 Unit test this function's algo if it is correct
    ///
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            
            let newText = self.processNewExternalIdText(oldText: self.textField.text ?? "", newText: updatedText)
            
            self.textField.text = newText
            let maxSize = siteIdLength + hyphenText.count + participantIdLength
            self.submitButton.isEnabled = (newText.count == maxSize)
            
            return false
        }
        return true
    }
    
    ///
    /// Process old textfield text to new formatted text based
    /// on what the user has typed in to change the text
    ///
    func processNewExternalIdText(oldText: String, newText: String) -> String {
        var updatedText = newText
        let maxSize = siteIdLength + hyphenText.count + participantIdLength
        
        // If we are at the max size, don't allow more characters
        if (updatedText.count > maxSize) {
            return oldText
        }
        
        // Check for the edge case that user deletes a character across the hyphen
        if (updatedText.count == (siteIdLength + hyphenText.count - 1)) {
            let fourthIndex = updatedText.index(updatedText.startIndex, offsetBy: siteIdLength)
            // User will no longer see the hyphen, just the site ID
            updatedText = "\(updatedText.prefix(upTo: fourthIndex))"
            return updatedText
        }
        
        // By default, remove the hyphen from the updated text, and re-apply
        // it based on the raw text digit entry
        updatedText = updatedText.replacingOccurrences(of: hyphenText, with: "")
        if (updatedText.count >= siteIdLength) {
            let fourthIndex = updatedText.index(updatedText.startIndex, offsetBy: siteIdLength)
            updatedText = "\(updatedText.prefix(upTo: fourthIndex))\(hyphenText)\(updatedText.suffix(from: fourthIndex))"
        }
        
        return updatedText
    }
    
    func signUpAndSignIn(completion: @escaping SBBNetworkManagerCompletionBlock) {
        guard let externalId = self.externalId(), !externalId.isEmpty else { return }
        
        if self.firstEntry == nil {
            self.firstEntry = externalId
            self.setRentryTitle()
            self.clearTextField()
            return
        }
        
        if externalId != self.firstEntry {
            self.firstEntry = nil
            self.setMismatchedParticipantIDTitle()
            self.clearTextField()
            return
        }
        
        let signUp: SBBSignUp = SBBSignUp()
        signUp.checkForConsent = true
        signUp.externalId = externalId
        signUp.password = "\(externalId)foo#$H0"   // Add some additional characters match password requirements
        signUp.dataGroups = ["test_user"]
        signUp.sharingScope = "all_qualified_researchers"
        
        self.submitButton.isEnabled = false
        // Causes the view to resign the first responder status.
        dismissKeyboard()
        
        BridgeSDK.authManager.signUpStudyParticipant(signUp, completion: { (task, result, error) in

            DispatchQueue.main.async {
                self.submitButton.isEnabled = true
            }
            
            guard error == nil else {
                completion(task, result, error)
                return
            }
            
            // we're signed up so sign in
            BridgeSDK.authManager.signIn(withExternalId: signUp.externalId!, password: signUp.password!, completion: { (task, result, error) in
                completion(task, result, error)
            })
        })
    }
    
    @IBAction override open func submitTapped() {
        self.nextButton?.isEnabled = false
        self.signUpAndSignIn { (task, result, error) in
            DispatchQueue.main.async {
                if error == nil {
                   super.goForward()
                } else {
                    self.nextButton?.isEnabled = true
                    self.presentAlertWithOk(title: "Error attempting sign in", message: error!.localizedDescription, actionHandler: nil)
                    // TODO: emm 2018-04-25 handle error from Bridge
                    // 400 is the response for an invalid external ID
                    debugPrint("Error attempting to sign up and sign in:\n\(String(describing: error))\n\nResult:\n\(String(describing: result))")
                }
            }
        }
    }

}
