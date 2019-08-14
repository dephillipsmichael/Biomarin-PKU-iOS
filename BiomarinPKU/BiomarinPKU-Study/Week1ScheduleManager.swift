//
//  Week1ScheduleManager.swift
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
public class Week1ScheduleManager : SBAScheduleManager {
    
    open var today: Date {
        return Date()
    }
    
    private func dayOfStudy(at date: Date) -> Int {
        return (Calendar.current.dateComponents([.day], from: studyStartDate, to: date).day ?? 0) + 1
    }
    
    open func dayOfStudy() -> Int {
        return self.dayOfStudy(at: today)
    }
    
    open var studyStartDate: Date {
        // The activites are scheduled when the user first requests them
        // Therefore, the day the user first signed in and started their study,
        // is the date that we can use as the study start date
        return self.scheduledActivities.first?.scheduledOn.startOfDay() ?? today.startOfDay()
    }
    
    // The current activity task the user is doing
    public var currentActivity: Week1Activity? = nil
    // The day of study that the user started doing the current activity task
    public var dayOfCurrentActivity = 0
    
    public override init() {
        RSDFactory.shared = PKUTaskFactory()
        // Install the MTC tasks in the app config so that they will use the appropriate factory.
        SBABridgeConfiguration.shared.addMapping(with: MCTTaskInfo(.tremor).task)
        SBABridgeConfiguration.shared.addMapping(with: MCTTaskInfo(.tapping).task)
        SBABridgeConfiguration.shared.addMapping(with: MCTTaskInfo(.kineticTremor).task)
    }
    
    override public func availablePredicate() -> NSPredicate {
        return NSPredicate(value: true)
    }
    
    open func scheduledActivity(for week1Activity: Week1Activity, on day: Int) -> SBBScheduledActivity? {
        let taskId = week1Activity.taskIdentifier(for: day)
        return self.scheduledActivities.first { $0.activityIdentifier == taskId }
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
            default:
                return nil
            }
        }()
        
        guard let videoUrlUnwrapped = videoUrl else { return nil }
        
        return RSDVideoViewUIActionObject(url: videoUrlUnwrapped, buttonTitle: Localization.localizedString("SEE_THIS_IN_ACTION"), bundleIdentifier: Bundle.main.bundleIdentifier)
    }
    
    /// Call from the view controller that is used to display the task when the task is ready to save.
    override open func taskController(_ taskController: RSDTaskController, readyToSave taskViewModel: RSDTaskViewModel) {
        
        // It is a requirement for our app to always upload the day of the study
        taskController.taskViewModel.taskResult.stepHistory.append(RSDAnswerResultObject(identifier: "dayOfStudy", answerType: .integer, value: dayOfCurrentActivity))
        
        super.taskController(taskController, readyToSave: taskViewModel)
    }
}

public enum Week1Activity: Int, CaseIterable {
    case sleep = 0
    case physical = 1
    case cognition = 2
    case daily = 3
    
    func isComplete(for day: Int) -> Bool {
        return UserDefaults.standard.bool(forKey: completeDefaultKey(for: day))
    }
    
    func complete(for day: Int) {
        UserDefaults.standard.set(true, forKey: completeDefaultKey(for: day))
    }
    
    func completeDefaultKey(for day: Int) -> String {
        let key = String(describing: self)
        return String(format: "%@%d", key, day)
    }
    
    func taskIdentifier(for day: Int) -> String {
        switch self {
        case .sleep:
            return RSDIdentifier.sleepCheckInTask.identifier
        case .daily:
            return RSDIdentifier.dailyCheckInTask.identifier
        case .physical:
            switch day % 3 {
            case 1:
                return RSDIdentifier.tappingTask.identifier
            case 2:
                return RSDIdentifier.tremorTask.identifier
            default: // 3
                return RSDIdentifier.kineticTremorTask.identifier
            }
        case .cognition:
            switch day % 6 {
            case 1:
                return RSDIdentifier.goNoGoTask.identifier
            case 2:
                return RSDIdentifier.symbolSubstitutionTask.identifier
            case 3:
                return RSDIdentifier.spatialMemoryTask.identifier
            case 4:
                return RSDIdentifier.nBackTask.identifier
            case 5:
                return RSDIdentifier.taskSwitchTask.identifier
            default: // 6
                return RSDIdentifier.attentionalBlinkTask.identifier
            }
        }
    }
    
    func title() -> String {
        switch self {
        case .sleep:
            return Localization.localizedString("WEEK_1_ACTIVITY_SLEEP")
        case .physical:
            return Localization.localizedString("WEEK_1_ACTIVITY_PHYSICAL")
        case .cognition:
            return Localization.localizedString("WEEK_1_ACTIVITY_COGNITION")
        case .daily:
            return Localization.localizedString("WEEK_1_ACTIVITY_DAILY")
        }
    }
    
    func detail() -> String {
        switch self {
        case .sleep:
            return Localization.localizedString("WEEK_1_MINUTES_SLEEP")
        case .physical:
            return Localization.localizedString("WEEK_1_MINUTES_PHYSICAL")
        case .cognition:
            return Localization.localizedString("WEEK_1_MINUTES_COGNITION")
        case .daily:
            return Localization.localizedString("WEEK_1_MINUTES_DAILY")
        }
    }
}
