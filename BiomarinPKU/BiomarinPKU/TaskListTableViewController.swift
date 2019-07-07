//
//  TaskListTableViewController.swift
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

class TaskListTableViewController: UITableViewController, RSDTaskViewControllerDelegate, RSDButtonCellDelegate {
    
    let scheduleManager = TaskListScheduleManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Install the MTC tasks in the app config so that they will use the appropriate factory.
        SBABridgeConfiguration.shared.addMapping(with: MCTTaskInfo(.tremor).task)
        SBABridgeConfiguration.shared.addMapping(with: MCTTaskInfo(.tapping).task)
        SBABridgeConfiguration.shared.addMapping(with: MCTTaskInfo(.kineticTremor).task)
        
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
        
        let tableHeader = self.tableView.tableHeaderView as? PKUTaskTableHeaderView
        tableHeader?.titleLabel?.textColor = designSystem.colorRules.textColor(on: designSystem.colorRules.backgroundLight, for: .heading3)
        tableHeader?.titleLabel?.font = designSystem.fontRules.font(for: .heading3)
        
        let tableFooter = self.tableView.tableFooterView as? PKUTaskTableFooterView
        tableFooter?.titleLabel?.textColor = designSystem.colorRules.textColor(on: designSystem.colorRules.backgroundLight, for: .heading4)
        tableFooter?.titleLabel?.font = designSystem.fontRules.font(for: .small)
    }
    
    func updateHeaderFooterText() {
        let tableHeader = self.tableView.tableHeaderView as? PKUTaskTableHeaderView
        tableHeader?.titleLabel?.text = Localization.localizedString("STUDY_TITLE")
        
        // Obtain the version and the date that the app was compiled
        let tableFooter = self.tableView.tableFooterView as? PKUTaskTableFooterView
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        let versionStr = Localization.localizedStringWithFormatKey("RELEASE_VERSION_%@", version)
        let releaseDate = compileDate() ?? ""
        let releaseDateStr = Localization.localizedStringWithFormatKey("RELEASE_DATE_%@", releaseDate)
        
        // For the trial app, show the user their external id
        if let externalIdStr = SBAParticipantManager.shared.studyParticipant?.externalId {
            tableFooter?.titleLabel?.text = String(format: "%@\n%@\n%@", externalIdStr, versionStr, releaseDateStr)
        } else { // For the study app, don't show the external ID
            tableFooter?.titleLabel?.text = String(format: "%@\n%@", versionStr, releaseDateStr)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.scheduleManager.tableSectionCount
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.scheduleManager.tableRowCount
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PKUTaskCell", for: indexPath) as! PKUTaskTableviewCell
        
        cell.titleLabel?.text = self.scheduleManager.title(for: indexPath)
        cell.actionButton.setTitle(Localization
            .localizedString("BUTTON_TITLE_BEGIN"), for: .normal)
        cell.indexPath = indexPath
        cell.delegate = self
        cell.setDesignSystem(AppDelegate.designSystem, with: AppDelegate.designSystem.colorRules.backgroundLight)
        
        return cell
    }
    
    func didTapButton(on cell: RSDButtonCell) {
        if (self.scheduleManager.isTaskRow(for: cell.indexPath)) {
            RSDFactory.shared = PKUTaskFactory()
            // This is an activity
            guard let activity = self.scheduleManager.sortedScheduledActivity(for: cell.indexPath) else { return }
            let taskViewModel = scheduleManager.instantiateTaskViewModel(for: activity)
            let taskVc = RSDTaskViewController(taskViewModel: taskViewModel)
            taskVc.delegate = self            
            self.present(taskVc, animated: true, completion: nil)
        } else {
            // TODO: mdephillips 5/18/19 transition to appropriate screen
            guard let supplementalRow = self.scheduleManager.supplementalRow(for: cell.indexPath) else { return }
            if (supplementalRow == .ConnectFitbit) {
                (AppDelegate.shared as? AppDelegate)?.connectToFitbit()
            }
        }
    }

    func taskController(_ taskController: RSDTaskController, didFinishWith reason: RSDTaskFinishReason, error: Error?) {

        // dismiss the view controller
        (taskController as? UIViewController)?.dismiss(animated: true, completion: nil)
        
        // Let the schedule manager handle the cleanup.
        scheduleManager.taskController(taskController, didFinishWith: reason, error: error)
        
        // Reload the table view
        self.tableView.reloadData()
    }
    
    func taskController(_ taskController: RSDTaskController, readyToSave taskViewModel: RSDTaskViewModel) {
        scheduleManager.taskController(taskController, readyToSave: taskViewModel)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 112.0
    }
    
    /// Here we can customize which VCs show for a step within a survey
    func taskViewController(_ taskViewController: UIViewController, viewControllerForStep stepModel: RSDStepViewModel) -> UIViewController? {
        let vc: RSDStepViewController? = {
            switch RSDIdentifier(rawValue: stepModel.identifier) {
            case .sleepQualityStep:
                let emojiVc = EmojiChoiceTableStepViewController(nibName: nil, bundle: nil)
                emojiVc.emojiImageType = .sleepEmoji
                return emojiVc
            case .pkuAffectedYourDayStep:
                let emojiVc = EmojiChoiceTableStepViewController(nibName: nil, bundle: nil)
                emojiVc.emojiImageType = .emoji
                return emojiVc
            case .unusualEventsStep:
                return SurveyStepViewController(nibName: nil, bundle: nil)
            default:
                return nil
            }
        }()
        vc?.stepViewModel = stepModel
        vc?.designSystem = AppDelegate.designSystem
        return vc
    }
}

open class PKUTaskTableviewCell: RSDButtonCell {
    open var backgroundTile = RSDGrayScale().white
    
    /// Title label that is associated with this cell.
    @IBOutlet open var titleLabel: UILabel?
    
    /// Divider view that is associated with this cell.
    @IBOutlet open var dividerView: UIView?
    
    override open func setDesignSystem(_ designSystem: RSDDesignSystem, with background: RSDColorTile) {
        super.setDesignSystem(designSystem, with: background)
        let cellBackground = self.backgroundColorTile ?? designSystem.colorRules.backgroundLight
        updateColorsAndFonts(designSystem, cellBackground, background)
    }
    
    func updateColorsAndFonts(_ designSystem: RSDDesignSystem, _ background: RSDColorTile, _ tableBackground: RSDColorTile) {
        
        // Set the title label and divider.
        self.titleLabel?.textColor = designSystem.colorRules.textColor(on: background, for: .heading2)
        self.titleLabel?.font = designSystem.fontRules.font(for: .heading2)
        dividerView?.backgroundColor = designSystem.colorRules.backgroundPrimary.color
        
        (self.actionButton as? RSDRoundedButton)?.setDesignSystem(designSystem, with: background)
    }
}

open class PKUTaskTableHeaderView: UIView {
    /// Title label that is associated with this cell.
    @IBOutlet open var titleLabel: UILabel?
}

open class PKUTaskTableFooterView: UIView {
    /// Title label that is associated with this cell.
    @IBOutlet open var titleLabel: UILabel?
}
