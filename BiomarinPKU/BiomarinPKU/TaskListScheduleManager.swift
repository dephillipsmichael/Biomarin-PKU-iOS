//
//  TaskListScheduleManager.swift
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
import MotorControl

/// Subclass the schedule manager to set up a predicate to filter the schedules.
public class TaskListScheduleManager : SBAScheduleManager {
    
    public let tasks: [RSDIdentifier] = [.tappingTask, .restingKineticTremorTask,
        .attentionalBlinkTask, .symbolSubstitutionTask, .goNoGoTask, .nBackTask,
        .spatialMemoryTask, .taskSwitchTask]
    
    ///
    /// - returns: the total table row count including activities
    ///         and the supplemental rows that go after them
    ///
    public var tableRowCount: Int {
        return self.tasks.count
    }
    
    public var tableSectionCount: Int {
        return 1
    }
    
    ///
    /// - parameter indexPath: from the table view
    ///
    /// - returns: the task info object for the task list row
    ///
    open func taskInfo(for indexPath: IndexPath) -> RSDTaskInfo {
        let taskId = tasks[indexPath.row]
        
        if (taskId == .tappingTask) {
            return MCTTaskInfo(MCTTaskIdentifier.tapping)
        } else if (taskId == .tremorTask) {
            return MCTTaskInfo(MCTTaskIdentifier.tremor)
        } else if (taskId == .kineticTremorTask) {
            return MCTTaskInfo(MCTTaskIdentifier.kineticTremor)
        } else if (taskId == .restingKineticTremorTask) {
            return MCTTaskInfo(MCTTaskIdentifier.restingKineticTremor)
        } else {
            return RSDTaskInfoObject(with: taskId.rawValue)
        }
    }
    
    ///
    /// - parameter indexPath: from the table view
    ///
    /// - returns: the title for the task list row, this may be an activity label
    ///         or a supplemental row title depending on the index path
    ///
    open func title(for indexPath: IndexPath) -> String? {
        let taskId = tasks[indexPath.row]
        switch taskId {
        case .tappingTask:
            return "Finger Tapping"
        case .tremorTask:
            return "Phone Hold"
        case .kineticTremorTask:
            return "Finger-to-Nose"
        case .restingKineticTremorTask:
            return "Dual Phone Hold"
        case .symbolSubstitutionTask:
            return "Digit Symbol Substitution"
        case .goNoGoTask:
            return "Go-No-Go"
        case .nBackTask:
            return "N-Back"
        case .spatialMemoryTask:
            return "Spatial Working Memory"
        default:
            return taskId.rawValue
        }
    }
    
    /// Setup the step view model and preform step customization
    open func customizeStepViewModel(stepModel: RSDStepViewModel) {
        if let overviewStep = stepModel.step as? RSDOverviewStepObject {
            if let overviewLearnMoreAction = mctOverviewLearnMoreAction(for: stepModel.parent?.identifier ?? "") {
                // Overview steps can have a learn more link to a video
                // This is not included in the MCT framework because
                // they are specific to the PKU project, so we must add it here
                overviewStep.actions?[.navigation(.learnMore)] = overviewLearnMoreAction
            }
        }
    }
    
    /// Get the learn more video url for the overview screen of the task
    open func mctOverviewLearnMoreAction(for taskIdentifier: String) -> RSDVideoViewUIActionObject? {
        let videoUrl: String? = {
            switch (taskIdentifier) {
            case MCTTaskIdentifier.tapping.rawValue:
                return "Tapping.mp4"
            case MCTTaskIdentifier.tremor.rawValue:
                return "Tremor.mp4"
            case MCTTaskIdentifier.kineticTremor.rawValue:
                return "KineticTremor.mp4"
            case MCTTaskIdentifier.restingKineticTremor.rawValue:
                return "RestingKineticTremor.mp4"
            default:
                return nil
            }
        }()
        
        guard let videoUrlUnwrapped = videoUrl else { return nil }
        
        return RSDVideoViewUIActionObject(url: videoUrlUnwrapped, buttonTitle: Localization.localizedString("SEE_THIS_IN_ACTION"), bundleIdentifier: Bundle.main.bundleIdentifier)
    }
}
