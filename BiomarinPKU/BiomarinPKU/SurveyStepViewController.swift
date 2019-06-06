//
//  SurveyStepViewController.swift
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

open class SurveyStepViewController: RSDTableStepViewController {
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.backgroundColor = self.designSystem.colorRules.backgroundPrimary.color
    }
    
    override open func setupHeader(_ header: RSDStepNavigationView) {
        // This needs to come before the super function so that the font
        // will have the correct autolayout sizes
        AppDelegate.setupHeader(header)
        super.setupHeader(header)
        
        if let tableHeader = header as? RSDTableStepHeaderView {
            // PKU survey questions hide the progress view
            tableHeader.progressView?.isHidden = true
        }
    }
    
    override open func showLearnMore() {
        
        // A trick to get bridge surveys to have learn more screens that
        // are customizable on bridge is to make special step identifiers
        // that follow the format "learn_more_[step_id_with_learn_more_action]
        let learnMoreStepIdentifier = "learn_more_\(self.stepViewModel.step.identifier)"
        
        guard let taskViewModel = self.stepViewModel.parentTaskPath as? RSDTaskViewModel,
            let infoScreen = (taskViewModel.task?.stepNavigator as? SBBSurvey)?.elements.first(where: { ($0 as? SBBSurveyElement)?.identifier == learnMoreStepIdentifier }) as? SBBSurveyInfoScreen else {
            super.showLearnMore()
            return
        }
        
        // the old instruction step format?  I dont see an RSDInstructionStepObject
        let infoStep = LearnMoreStepObject(identifier: infoScreen.identifier, type: .learnMore)
        infoStep.title = infoScreen.title
        infoStep.learnMoreText = infoScreen.text
        infoStep.shouldHideActions = [.navigation(.goBackward), .navigation(.goForward), .navigation(.skip)]
        
        var navigator = RSDConditionalStepNavigatorObject(with: [infoStep])
        navigator.progressMarkers = []
        let task = RSDTaskObject(identifier: step.identifier, stepNavigator: navigator)
        let taskVc = RSDTaskViewController(task: task)
        taskVc.delegate = self
        self.present(taskVc, animated: true, completion: nil)
    }
}
