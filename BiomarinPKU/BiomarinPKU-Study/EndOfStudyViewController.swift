//
//  EndOfStudyViewController.swift
//  PsorcastValidation
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
import BridgeAppUI
import BridgeSDK
import MotorControl

class EndOfStudyViewController: UITableViewController, RSDTaskViewControllerDelegate, RSDButtonCellDelegate {
    
    let endStudyCompleteTaskId = "endStudyComplete"
    
    var scheduleManager: ActivityScheduleManager {
        return ActivityScheduleManager.shared
    }
    
    var tableFooter: TaskTableFooterView? {
        return self.tableView.tableFooterView as? TaskTableFooterView
    }
    
    var tableHeader: TaskTableHeaderView? {
        return self.tableView.tableHeaderView as? TaskTableHeaderView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Cancel all user reminders
        ReminderManager.shared.cancelAllNotifications()                
        
        // reload the schedules and add an observer to observe changes.
        scheduleManager.reloadData()
        NotificationCenter.default.addObserver(forName: .SBAUpdatedScheduledActivities, object: scheduleManager, queue: OperationQueue.main) { (notification) in
            self.tableView.reloadData()
        }
        
        updateDesignSystem()
        updateHeaderFooterText()
    }
    
    func updateDesignSystem() {
        let designSystem = AppDelegate.designSystem
        
        self.view.backgroundColor = designSystem.colorRules.backgroundPrimary.color
        
        tableHeader?.backgroundColor = AppDelegate.designSystem.colorRules.backgroundPrimary.color
        
        tableFooter?.backgroundColor = AppDelegate.designSystem.colorRules.backgroundPrimary.color
        tableFooter?.titleLabel?.textColor = designSystem.colorRules.textColor(on: designSystem.colorRules.backgroundPrimary, for: .smallHeader)
        tableFooter?.titleLabel?.font = designSystem.fontRules.font(for: .small)
        tableFooter?.doneButton?.setDesignSystem(designSystem, with: designSystem.colorRules.backgroundLight)
    }
    
    func updateHeaderFooterText() {
        // Obtain the version and the date that the app was compiled
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        let versionStr = Localization.localizedStringWithFormatKey("RELEASE_VERSION_%@", version)
        let releaseDate = compileDate() ?? ""
        let releaseDateStr = Localization.localizedStringWithFormatKey("RELEASE_DATE_%@", releaseDate)
        
        // For the trial app, show the user their external id
        if let externalId = SBAParticipantManager.shared.studyParticipant?.externalId {
            tableFooter?.titleLabel?.text = String(format: "Current ID: %@\n%@\n%@", externalId, versionStr, releaseDateStr)
        } else { // For the study app, don't show the external ID
            tableFooter?.titleLabel?.text = String(format: "%@\n%@", versionStr, releaseDateStr)
        }
        tableFooter?.doneButton?.isEnabled = self.allComplete()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.scheduleManager.endOfStudySortedSchedules?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PKUTaskCell", for: indexPath) as! TaskTableviewCell
        
        if let schedule = self.scheduleManager.endOfStudySortedSchedules?[indexPath.row],
            let activityIdentifier = schedule.activityIdentifier {
            cell.titleLabel?.text = schedule.activity.label
            let isComplete = self.scheduleManager.isEndOfStudyComplete(taskIdentifier: activityIdentifier)
            cell.setIsComplete(isComplete: isComplete)
        }
        cell.actionButton.setTitle(Localization
            .localizedString("BUTTON_TITLE_BEGIN"), for: .normal)
        cell.indexPath = indexPath
        cell.delegate = self
        cell.setDesignSystem(AppDelegate.designSystem, with: AppDelegate.designSystem.colorRules.backgroundLight)
        
        return cell
    }
    
    func didTapButton(on cell: RSDButtonCell) {
        if let schedule = self.scheduleManager.endOfStudySortedSchedules?[cell.indexPath.row] {
            let taskViewModel = scheduleManager.instantiateTaskViewModel(for: schedule)
            let taskVc = RSDTaskViewController(taskViewModel: taskViewModel)
            taskVc.modalPresentationStyle = .fullScreen
            taskVc.delegate = self
            self.present(taskVc, animated: true, completion: nil)
        }
    }
    
    @IBAction func doneTapped() {
        DispatchQueue.main.async {
            self.tableFooter?.doneButton?.isEnabled = false
            self.tableFooter?.loadingSpinner?.isHidden = false
        }
        SBBAuthManager.default().signOut { (task, anyObj, error) in
            DispatchQueue.main.async {
                self.tableFooter?.doneButton?.isEnabled = true
                self.tableFooter?.loadingSpinner?.isHidden = true
                // Remove all userdefaults date
                let defaults = UserDefaults.standard
                let dictionary = defaults.dictionaryRepresentation()
                dictionary.keys.forEach { key in
                    defaults.removeObject(forKey: key)
                }
                ReminderManager.shared.cancelAllNotifications()
                
                // Show end of study completion screen
                var navigator = RSDConditionalStepNavigatorObject(with: [self.studyCompleteStep()])
                navigator.progressMarkers = []
                let task = RSDTaskObject(identifier: self.endStudyCompleteTaskId, stepNavigator: navigator)
                let vc = RSDTaskViewController(task: task)
                vc.delegate = self
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    func studyCompleteStep() -> RSDStep {
        let step = IntroStepObject(identifier: "intro1")
        step.title = Localization.localizedString("STUDY_COMPLETE_TITLE")
        step.text = Localization.localizedString("STUDY_COMPLETE_TEXT")
        step.shouldHideActions = [.navigation(.cancel), .navigation(.goBackward), .navigation(.skip)]
        step.imageTheme = RSDFetchableImageThemeElementObject(imageName: "EndStudyCompleteHeader")
        return step
    }
    
    func taskController(_ taskController: RSDTaskController, didFinishWith reason: RSDTaskFinishReason, error: Error?) {
        
        let result = taskController.taskViewModel.taskResult
        let dataValidity = self.scheduleManager.isDataValid(taskResult: result)
        
        let completed = (error == nil && reason == .completed && dataValidity.isValid)
        
        // dismiss the view controller
        (taskController as? UIViewController)?.dismiss(animated: true, completion: {
            if taskController.task.identifier == self.endStudyCompleteTaskId {
                (AppDelegate.shared as? AppDelegate)?.showAppropriateViewController(animated: true)
            }
            
            // If data was invalid and we could not upload it, tell the user why
            if reason == .completed && !dataValidity.isValid {
                self.presentAlertWithOk(title: Localization.localizedString("DATA_ERROR_TITLE"), message: String(format: Localization.localizedString("DATA_ERROR_MSG_%@"), dataValidity.errorMsg ?? ""), actionHandler: nil)
            }
        })
        
        if taskController.task.identifier == self.endStudyCompleteTaskId {
            return // the completion block will send the user to another screen
        }
        
        // Let the schedule manager handle the cleanup.
        scheduleManager.taskController(taskController, didFinishWith: reason, error: error)
        
        if completed {
            self.scheduleManager.completeEndOfStudy(taskIdentifier: taskController.task.identifier)
        }
        
        // Reload the table view
        self.tableView.reloadData()
        // Update the done button enabled state
        self.updateHeaderFooterText()
    }
    
    func taskController(_ taskController: RSDTaskController, readyToSave taskViewModel: RSDTaskViewModel) {
        scheduleManager.taskController(taskController, readyToSave: taskViewModel)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 112.0
    }
    
    /// Here we can customize which VCs show for a step within a survey
    func taskViewController(_ taskViewController: UIViewController, viewControllerForStep stepModel: RSDStepViewModel) -> UIViewController? {
        return nil
    }
    
    func allComplete() -> Bool {
        return self.scheduleManager.endOfStudySortOrder.filter( { !self.scheduleManager.isEndOfStudyComplete(taskIdentifier: $0.rawValue) } ).count <= 0
    }
}

open class TaskTableviewCell: RSDButtonCell {
    open var backgroundTile = RSDGrayScale().white
    
    /// Title label that is associated with this cell.
    @IBOutlet open var titleLabel: UILabel?
    
    /// Divider view that is associated with this cell.
    @IBOutlet open var dividerView: UIView?
    
    /// Done label
    @IBOutlet open var doneLabel: UILabel?
    
    /// Container view that holds the done info
    @IBOutlet open var doneContainer: UIView?
    
    func setIsComplete(isComplete: Bool) {
        doneContainer?.isHidden = !isComplete
        actionButton.isHidden = isComplete
    }
    
    override open func setDesignSystem(_ designSystem: RSDDesignSystem, with background: RSDColorTile) {
        super.setDesignSystem(designSystem, with: background)
        let cellBackground = self.backgroundColorTile ?? designSystem.colorRules.backgroundLight
        updateColorsAndFonts(designSystem, cellBackground, background)
    }
    
    func updateColorsAndFonts(_ designSystem: RSDDesignSystem, _ background: RSDColorTile, _ tableBackground: RSDColorTile) {
        
        // Set the title label and divider.
        self.titleLabel?.textColor = designSystem.colorRules.textColor(on: background, for: .mediumHeader)
        self.titleLabel?.font = designSystem.fontRules.font(for: .mediumHeader)
        
        self.titleLabel?.textColor = designSystem.colorRules.textColor(on: background, for: .body)
        self.titleLabel?.font = designSystem.fontRules.font(for: .body)
        
        dividerView?.backgroundColor = designSystem.colorRules.backgroundPrimary.color
        
        (self.actionButton as? RSDRoundedButton)?.setDesignSystem(designSystem, with: background)
        
        self.doneLabel?.font = designSystem.fontRules.font(for: .body)
        self.doneLabel?.textColor = designSystem.colorRules.palette.successGreen.colorTiles[3].color
    }
}

open class TaskTableHeaderView: UIView {
    /// Title label that is associated with this view.
    @IBOutlet open var titleLabel: UILabel?
    /// Image Header that is associated with this view.
    @IBOutlet open var imageView: UIImageView?
}

open class TaskTableFooterView: UIView {
    /// Title label that is associated with this view.
    @IBOutlet open var titleLabel: UILabel?
    /// Done button for switch participant IDs
    @IBOutlet open var doneButton: RSDRoundedButton?
    /// Loading spinner that shows when done button is tapped
    @IBOutlet open var loadingSpinner: UIActivityIndicatorView?
}
