//
//  Week1ViewController.swift
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
import BridgeApp
import BridgeSDK
import MotorControl

extension RSDIdentifier {
    static let pkuAffectedYourDayStep: RSDIdentifier = "pku_affected_your_day"
    static let sleepQualityStep: RSDIdentifier = "sleep_quality"
    static let unusualEventsStep: RSDIdentifier = "unusual_events_occured"
}

class ActivityViewController: UIViewController, RSDTaskViewControllerDelegate {
    
    // Title of the view controller
    @IBOutlet public var titleLabel: UILabel!
    // Text of the view controller
    @IBOutlet public var textLabel: UILabel!
    // The header background behind the title and text
    @IBOutlet public var headerBackground: UIView!
    
    // The container for the day label that will need to be a circle
    @IBOutlet public var dayContainer: UIView!
    @IBOutlet public var dayContainerInner: UIView!
    // The day title label
    @IBOutlet public var dayTitleLabel: UILabel!
    // The day label of the view controller i.e. "Day 1 of 7"
    @IBOutlet public var dayLabel: UILabel!
    
    // Heights for the account container when normal or expanded
    let accountContainerHeight = 54
    let accountExpandedContainerHeight = 94
    // The view container for the account details widget
    @IBOutlet public var accountDetailsContainer: UIView!
    @IBOutlet public var accountDetailsContainerHeight: NSLayoutConstraint!
    // The account details label
    @IBOutlet public var accountDetailsButton: UIButton!
    // The up/down arrow icon image
    @IBOutlet public var accountContainerArrowImageView: UIImageView!
    // The exteral ID of the user
    @IBOutlet public var accountLabel: UILabel!
    // The end study button
    @IBOutlet public var endStudyButton: UIButton!
    
    // The expires time label for daily and weekly
    @IBOutlet public var expiresLabel: UILabel!
    @IBOutlet public var expiresWeeklyLabel: UILabel!
    
    // The loading view for when the schedules are being loaded
    @IBOutlet public var loadingView: UIActivityIndicatorView!
    // The activities container
    @IBOutlet public var activitiesContainer: UIView!
    // The button  for the activity views
    @IBOutlet var activityButtons: Array<RSDUnderlinedButton>?
    // The button  for the activity views
    @IBOutlet var activityDetailLabels: Array<UILabel>?
    // The done images for the activity views
    @IBOutlet var activityDoneIcons: Array<UIImageView>?
    
    var expirationTimer = Timer()
    var expirationgDay: Int?
    
    let scheduleManager = ActivityScheduleManager.shared
    
    var deepLinkActivity: ActivityType?
    var activitiesLoaded: Bool = false
    
    let hasRunWeek1CompleteKey = "hasRunWeek1CompleteTask"
    let week1CompleteTaskId = "Week1Complete"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ActivityScheduleManager.shared = ActivityScheduleManager()
        
        // Add an observer to observe schedule changes
        NotificationCenter.default.addObserver(forName: .SBAUpdatedScheduledActivities, object: scheduleManager, queue: OperationQueue.main) { (notification) in
            
            self.loadingView.isHidden = true
            self.activitiesContainer.isHidden = false
            self.refreshUI()
            
            self.activitiesLoaded = true
            
            // Deep link to an activity if the user tapped a notification
            self.runDeepLinkIfApplicable()
            
            // Check if we have transitioned from week 1 to week 2
            // and the user hasn't seen the week 1 complete task
            if self.shouldRunWeek1CompleteTask() {
                self.runWeek1CompelteTask()
            }
        }
        
        // Reload the schedules and show loading UI
        self.loadingView.isHidden = false
        self.activitiesContainer.isHidden = true
        
        // Schedule expiration timer to run every second
        self.expirationTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimeFormattedText), userInfo: nil, repeats: true)
        
        // Only set this on load, otheriwse the buttons flash when switching tabs
        for activity in ActivityType.allCases {
            let i = activity.rawValue
            self.activityButtons?[i].setTitle(activity.title(), for: .normal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // User has seen their activities so reset badge number
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        refreshUI()
        updateDesignSystem()
        scheduleManager.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.dayContainer.layer.cornerRadius = self.dayContainer.frame.width / 2
        self.dayContainerInner.layer.cornerRadius = self.dayContainerInner.frame.width / 2
    }
    
    func updateDesignSystem() {
        let designSystem = AppDelegate.designSystem
        
        let backgroundHeader = designSystem.colorRules.backgroundPrimary
        let backgroundLight = designSystem.colorRules.backgroundLight
       
        self.view.backgroundColor = backgroundLight.color
        self.headerBackground.backgroundColor = backgroundHeader.color
        
        self.titleLabel.font = designSystem.fontRules.font(for: .largeHeader)
        self.titleLabel.textColor = designSystem.colorRules.textColor(on: backgroundHeader, for: .largeHeader)
        
        self.textLabel.font = designSystem.fontRules.font(for: .body)
        self.textLabel.textColor = designSystem.colorRules.textColor(on: backgroundHeader, for: .body)
        
        self.dayTitleLabel.font = designSystem.fontRules.font(for: .microHeader)
        self.dayTitleLabel.textColor = designSystem.colorRules.textColor(on: backgroundLight, for: .microHeader)
        
        self.expiresLabel.font = designSystem.fontRules.font(for: .italicDetail)
        self.expiresLabel.textColor = designSystem.colorRules.textColor(on: backgroundLight, for: .italicDetail)
        
        self.expiresWeeklyLabel.font = designSystem.fontRules.font(for: .italicDetail)
        self.expiresWeeklyLabel.textColor = designSystem.colorRules.textColor(on: backgroundLight, for: .italicDetail)
        
        self.accountDetailsContainer.backgroundColor = backgroundLight.color
        
        self.accountDetailsButton.titleLabel?.font = designSystem.fontRules.font(for: .microDetail)
        self.accountDetailsButton.setTitleColor(designSystem.colorRules.textColor(on: backgroundLight, for: .microDetail), for: .normal)
        
        self.accountLabel.font = designSystem.fontRules.font(for: .xSmallNumber)
        self.accountLabel.textColor = designSystem.colorRules.textColor(on: backgroundLight, for: .xSmallNumber)
        
        self.endStudyButton.setTitleColor(designSystem.colorRules.textColor(on: backgroundLight, for: .smallNumber), for: .normal)
        
        for activity in ActivityType.allCases {
            let i = activity.rawValue
            
            self.activityDetailLabels?[i].textColor = designSystem.colorRules.textColor(on: backgroundLight, for: .microDetail)
            self.activityDetailLabels?[i].font = designSystem.fontRules.font(for: .microDetail)
        }
    }
    
    func refreshUI() {
        self.titleLabel.text = Localization.localizedString("WEEK_1_TITLE")
        self.textLabel.text = Localization.localizedString("WEEK_1_TEXT")
    self.accountDetailsButton.setTitle(Localization.localizedString("VIEW_ACCOUNT_DETAILS"), for: .normal)
        
        // Setup external ID to display as XXXX - XXXXX
        if let externalID = SBAParticipantManager.shared.studyParticipant?.externalId {
            let fourthIndex = externalID.index(externalID.startIndex, offsetBy: 4)
            self.accountLabel.text = "\(externalID.prefix(upTo: fourthIndex)) - \(externalID.suffix(from: fourthIndex))"
        }
        self.endStudyButton.setTitle(Localization.localizedString("TAP_TO_END_STUDY_BUTTON"), for: .normal)
        
        for activity in ActivityType.allCases {
            let i = activity.rawValue
            self.activityDetailLabels?[i].text = activity.detail()
            let isComplete = activity.isComplete(for: scheduleManager.dayOfStudy())
            self.activityButtons?[i].isEnabled = !isComplete
            self.activityDoneIcons?[i].isHidden = !isComplete
        }
        
        updateTimeFormattedText()
    }
    
    @IBAction func accountDetailsContainerTapped() {
        if (Int(self.accountDetailsContainerHeight.constant) == accountContainerHeight) {
            // User tapped to expand the container
            self.accountDetailsContainerHeight.constant = CGFloat(accountExpandedContainerHeight)
            self.accountContainerArrowImageView.image = UIImage(named: "UpArrowIcon")
        } else {
            // User tapped to return container to normal height
            self.accountDetailsContainerHeight.constant = CGFloat(accountContainerHeight)
            self.accountContainerArrowImageView.image = UIImage(named: "DownArrowIcon")
        }
        UIView.animate(withDuration: 0.15) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func endStudyTapped() {
        // TODO: mdephillips 8/8/19 show leave study pin screen
        self.presentAlertWithOk(title: "This feature will be implemented in a future version", message: "", actionHandler: nil)
    }
    
    @IBAction func sleepCheckInTapped() {
        self.presentTaskViewController(for: .sleep)
    }
    
    @IBAction func dailyCheckInTapped() {
        self.presentTaskViewController(for: .daily)
    }
    
    @IBAction func cognitionTapped() {
        self.presentTaskViewController(for: .cognition)
    }
    
    @IBAction func physicalTapped() {
        self.presentTaskViewController(for: .physical)
    }
    
    func presentTaskViewController(for activity: ActivityType) {
        let day = self.scheduleManager.dayOfStudy()
        guard !activity.isComplete(for: day) else { return }
        
        guard !self.shouldRunWeek1CompleteTask() else {
            debugPrint("User needs to see week 1 complete task first before running task")
            // Set the activity action as a deep link so it shows
            // after the user runs their week 1 complete task
            self.deepLinkActivity = activity
            return
        }
        
        scheduleManager.dayOfCurrentActivity = day
        scheduleManager.currentActivity = activity
        
        guard let schedule = self.scheduleManager.scheduledActivity(for: activity, on: scheduleManager.dayOfCurrentActivity) else {
            scheduleManager.currentActivity = nil
            debugPrint("Cannot run task when scheduled activity is nil")
            return
        }
        
        let taskViewModel = scheduleManager.instantiateTaskViewModel(for: schedule)
        
        let taskVc = RSDTaskViewController(taskViewModel: taskViewModel)
        taskVc.delegate = self
        self.present(taskVc, animated: true, completion: nil)
    }
    
    @objc func updateTimeFormattedText() {
        let expiresTimeStr = self.timeUntilExpiration(from: Date(), until: Calendar.current.startOfDay(for: Date()).addingNumberOfDays(1))
        
        let dayOfStudy = scheduleManager.dayOfStudy()
        let weekOfStudy = scheduleManager.weekOfStudy(dayOfStudy: dayOfStudy)
        
        self.expiresLabel.text = self.expiresLabelText(for: dayOfStudy, expiresTimeStr: expiresTimeStr)
        self.expiresWeeklyLabel.text = self.expiresWeeklyLabelText(for: dayOfStudy, week: weekOfStudy, expiresTimeStr: expiresTimeStr)
        self.dayLabel.text = self.dayLabelText(for: dayOfStudy, week: weekOfStudy)
        self.dayTitleLabel.text = self.dayTitleLabelText(for: dayOfStudy)
        
        // Check for day crossover
        if let previous = self.expirationgDay,
            dayOfStudy != previous {
            // Reload data on day crossover so new activities can be done
            self.scheduleManager.reloadData()
            
            // Check for week 1 complete crossover and run task if so
            if dayOfStudy == 8 && self.shouldRunWeek1CompleteTask() {
                self.runWeek1CompelteTask()
            }
        }
        
        // Keep track of previous day and week so we can determine
        // when day and week thresholds are passed
        self.expirationgDay = dayOfStudy
    }
    
    func expiresLabelText(for day: Int, expiresTimeStr: String) -> String? {
        if day <= 7 {
            return Localization.localizedStringWithFormatKey("WEEK_1_EXPIRES_FORMAT_%@", expiresTimeStr)
        } else {
            return Localization.localizedStringWithFormatKey("AFTER_WEEK_1_EXPIRES_FORMAT_%@", expiresTimeStr)
        }
    }
    
    func expiresWeeklyLabelText(for day: Int, week: Int, expiresTimeStr: String) -> String? {
        if day <= 7 {
            return nil
        } else {
            let daysUntilWeeklyExpiration = (week * 7) - day + 1
            if daysUntilWeeklyExpiration <= 1 {
                return Localization.localizedStringWithFormatKey("AFTER_WEEK_1_EXPIRES_WEEKLY_FORMAT_HOURS_%@", expiresTimeStr)
            } else {
                return Localization.localizedStringWithFormatKey("AFTER_WEEK_1_EXPIRES_WEEKLY_FORMAT_DAYS_%@", String(daysUntilWeeklyExpiration))
            }
        }
    }
    
    func dayLabelText(for day: Int, week: Int) -> String? {
        if day <= 7 {
            return Localization.localizedStringWithFormatKey("WEEK_1_DAY_FORMAT_%@", String(day))
        } else {
            return Localization.localizedStringWithFormatKey("AFTER_WEEK_1_DAY_FORMAT_%@", String(week))
        }
    }
    
    func dayTitleLabelText(for day: Int) -> String? {
        if day <= 7 {
            return Localization.localizedString(Localization.localizedString("WEEK_1_DAY"))
        } else {
            return Localization.localizedString(Localization.localizedString("WEEK"))
        }
    }
    
    func timeUntilExpiration(from now: Date, until expiration: Date) -> String {
        let secondsUntilExpiration = Int(expiration.timeIntervalSince(now))
        
        var secondsCalculation = secondsUntilExpiration
        let hours = secondsCalculation / (60 * 60)
        secondsCalculation -= (hours * 60 * 60)
        let minutes = secondsCalculation / 60
        secondsCalculation -= minutes * 60
        let seconds = secondsCalculation
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    func taskController(_ taskController: RSDTaskController, didFinishWith reason: RSDTaskFinishReason, error: Error?) {
        
        // Let the schedule manager handle the cleanup.
        scheduleManager.taskController(taskController, didFinishWith: reason, error: error)
        
        let completed = (error == nil && reason == .completed)
        
        // If we completed the week 1 complete task, save its new state
        if completed && taskController.task.identifier == week1CompleteTaskId {
            self.setHasRunWeek1CompleteTask()
        }
        
        let activity = self.scheduleManager.currentActivity
        // Dismiss the view controller
        (taskController as? UIViewController)?.dismiss(animated: true, completion: {
            // Check if the task was completed successfully
            if completed {
                // The result may contain reminder information
                // Send it to the reminder manager for processing
                ReminderManager.shared.updateNotifications(for: taskController.taskViewModel.taskResult)
                
                if let activityUnwrapped = activity {
                    // Mark day as completed and refresh the UI
                    activityUnwrapped.complete(for: self.scheduleManager.dayOfCurrentActivity)
                    self.refreshUI()
                    self.presentReminderTaskIfApplicable(afterCompleted: activityUnwrapped.reminderType())
                }
                
                self.runDeepLinkIfApplicable()
            }
        })

        scheduleManager.currentActivity = nil
    }
    
    func presentReminderTaskIfApplicable(afterCompleted type: ReminderType) {
        // Check if we need to show the reminder screen
        if !ReminderManager.shared.hasReminderBeenScheduled(type: type) {
            let task = type.taskViewModel(dayOfStudy: self.scheduleManager.dayOfStudy(), alwaysShow: false)
            let taskViewController = RSDTaskViewController(task: task)
            taskViewController.delegate = self
            self.present(taskViewController, animated: true, completion: nil)
        }
    }
    
    func taskController(_ taskController: RSDTaskController, readyToSave taskViewModel: RSDTaskViewModel) {
        scheduleManager.taskController(taskController, readyToSave: taskViewModel)
    }
    
    /// Here we can customize which VCs show for a step within a survey
    func taskViewController(_ taskViewController: UIViewController, viewControllerForStep stepModel: RSDStepViewModel) -> UIViewController? {
        self.scheduleManager.customizeStepViewModel(stepModel: stepModel)
        return nil
    }
    
    func runDeepLinkIfApplicable() {
        // Ignore any deep links for now if we need to run week 1 complete task
        guard !self.shouldRunWeek1CompleteTask() else { return }
        if let activity = self.deepLinkActivity {
            self.presentTaskViewController(for: activity)
            self.deepLinkActivity = nil
        }
    }
    
    func runWeek1CompelteTask() {
        guard let appDelegate = AppDelegate.shared as? AppDelegate else { return }
        let dayOfStudy = self.scheduleManager.dayOfStudy()
        let steps = appDelegate.week1CompleteSteps(dayOfStudy: dayOfStudy)
        var navigator = RSDConditionalStepNavigatorObject(with: steps)
        navigator.progressMarkers = []
        let task = RSDTaskObject(identifier: week1CompleteTaskId, stepNavigator: navigator)
        let taskViewController = RSDTaskViewController(task: task)
        taskViewController.delegate = self
        self.present(taskViewController, animated: true, completion: nil)
    }
    
    func shouldRunWeek1CompleteTask() -> Bool {
        return self.scheduleManager.dayOfStudy() >= 8 &&
            !UserDefaults.standard.bool(forKey: hasRunWeek1CompleteKey)
    }
    
    func setHasRunWeek1CompleteTask() {
        UserDefaults.standard.set(true, forKey: hasRunWeek1CompleteKey)
    }
}
