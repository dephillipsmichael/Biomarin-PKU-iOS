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
public class ActivityScheduleManager : SBAScheduleManager {
    
    public static var shared = ActivityScheduleManager()
    
    open var today: Date {
        return Date()
    }
    
    private func dayOfStudy(at date: Date) -> Int {
        return (Calendar.current.dateComponents([.day], from: studyStartDate, to: date).day ?? 0) + 1
    }
    
    open func dayOfStudy() -> Int {
        return self.dayOfStudy(at: today)
    }
    
    open func weekOfStudy(dayOfStudy: Int) -> Int {
        return ActivityType.daily.weekOfStudy(dayOfStudy: dayOfStudy)
    }
    
    open var studyStartDate: Date {
        // The activites are scheduled when the user first requests them
        // Therefore, the day the user first signed in and started their study,
        // is the date that we can use as the study start date
        return self.scheduledActivities.first?.scheduledOn.startOfDay() ?? today.startOfDay()
    }
    
    // The current activity task the user is doing
    public var currentActivity: ActivityType? = nil
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
    
    open func scheduledActivity(for week1Activity: ActivityType, on day: Int) -> SBBScheduledActivity? {
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
            
            if let _ = overviewStep.action(for: .navigation(.skip), on: overviewStep) as? RSDReminderUIActionObject {
                // We should adjust the reminder identifier to match our paradigm
                overviewStep.actions?[.navigation(.skip)] = RSDReminderUIActionObject(reminderIdentifier: "\(ReminderType.physical.rawValue)Later", buttonTitle: Localization.localizedString("REMIND_ME_LATER_BUTTON"))
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

public enum ActivityType: Int, CaseIterable {
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
        let week = self.weekOfStudy(dayOfStudy: day)
        if self == .daily || self == .sleep || week <= 1 {
            let keySuffix = "\(String(describing: self))Day"
            return String(format: "%@%d", keySuffix, day)
        } else { // After week 1 is complete for phsyical and cognitive
            let keySuffix = "\(String(describing: self))Week"
            return String(format: "%@%d", keySuffix, week)
        }
    }
    
    func weekOfStudy(dayOfStudy: Int) -> Int {
        return ((dayOfStudy - 1) / 7) + 1
    }
    
    static func dailyTypes(for day: Int) -> [ActivityType] {
        var dailyTypes: [ActivityType] = [.daily, .sleep]
        if day <= 7 {
            dailyTypes.append(contentsOf: [.physical, .cognition])
        }
        return dailyTypes
    }
    
    static func weeklyTypes(for day: Int) -> [ActivityType] {
        var weeklyTypes = [ActivityType]()
        if day > 7 {
            weeklyTypes.append(contentsOf: [.physical, .cognition])
        }
        return weeklyTypes
    }
    
    func taskIdentifier(for day: Int) -> String {
        let week = self.weekOfStudy(dayOfStudy: day)
        switch self {
        case .sleep:
            return RSDIdentifier.sleepCheckInTask.identifier
        case .daily:
            return RSDIdentifier.dailyCheckInTask.identifier
        case .physical:
            if week <= 1 { // Week 1 logic, rotate every 3 days
                switch day % 3 {
                case 1:
                    return RSDIdentifier.tappingTask.identifier
                case 2:
                    return RSDIdentifier.tremorTask.identifier
                default: // case 0:
                    return RSDIdentifier.kineticTremorTask.identifier
                }
            } else { // All weeks after week 1
                switch week % 3 {
                case 1:
                    return RSDIdentifier.tappingTask.identifier
                case 2:
                    return RSDIdentifier.tremorTask.identifier
                default: // case 0:
                    return RSDIdentifier.kineticTremorTask.identifier
                }
            }
        case .cognition:
            if week <= 1 { // Week 1 logic, rotate e ery 6 days
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
                default: // case 0:
                    return RSDIdentifier.attentionalBlinkTask.identifier
                }
            } else { // All weeks after week 1
                switch week % 6 {
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
                default: // case 0:
                    return RSDIdentifier.attentionalBlinkTask.identifier
                }
            }
        }
    }
    
    func title() -> String {
        switch self {
        case .sleep:
            return Localization.localizedString("ACTIVITY_SLEEP")
        case .physical:
            return Localization.localizedString("ACTIVITY_PHYSICAL")
        case .cognition:
            return Localization.localizedString("ACTIVITY_COGNITION")
        case .daily:
            return Localization.localizedString("ACTIVITY_DAILY")
        }
    }
    
    func detail(for day: Int, isComplete: Bool) -> String {
        switch self {
        case .sleep:
            if !isComplete {
                return Localization.localizedString("MINUTES_SLEEP")
            } else {
                return Localization.localizedString("DONE_FOR_DAY")
            }
        case .physical:
            if !isComplete {
                return Localization.localizedString("MINUTES_PHYSICAL")
            } else {
                if day <= 7 {
                    return Localization.localizedString("DONE_FOR_DAY")
                } else {
                    return Localization.localizedString("DONE_FOR_WEEK")
                }
            }
        case .cognition:
            if !isComplete {
                return Localization.localizedString("MINUTES_COGNITION")
            } else {
                if day <= 7 {
                    return Localization.localizedString("DONE_FOR_DAY")
                } else {
                    return Localization.localizedString("DONE_FOR_WEEK")
                }
            }
        case .daily:
            if !isComplete {
                return Localization.localizedString("MINUTES_DAILY")
            } else {
                return Localization.localizedString("DONE_FOR_DAY")
            }
        }
    }
    
    func reminderType() -> ReminderType {
        switch self {
        case .daily: return .daily
        case .sleep: return .sleep
        case .physical: return .physical
        case .cognition: return .cognition
        }
    }
}
