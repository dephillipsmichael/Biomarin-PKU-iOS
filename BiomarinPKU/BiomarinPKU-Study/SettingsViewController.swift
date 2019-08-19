//
//  SettingsController.swift
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

class SettingsViewController: UITableViewController, RSDTaskViewControllerDelegate {
    
    // Title of the view controller
    @IBOutlet public var titleLabel: UILabel!
    // Text of the view controller
    @IBOutlet public var textLabel: UILabel!
    // The header background behind the title and text
    @IBOutlet public var headerBackground: UIView!
    
    var scheduleManager: ActivityScheduleManager {
        return ActivityScheduleManager.shared
    }
    
    var reminderManager: ReminderManager {
        return ReminderManager.shared
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let tabBar = self.tabBarController {
            let adjustForTabbarInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: tabBar.tabBar.frame.height, right: 0)
            self.tableView.contentInset = adjustForTabbarInsets
            self.tableView.scrollIndicatorInsets = adjustForTabbarInsets
        }
        self.updateDesignSystem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
    }
    
    func updateDesignSystem() {
        let designSystem = AppDelegate.designSystem
        
        let backgroundHeader = designSystem.colorRules.backgroundPrimary
        let backgroundLight = designSystem.colorRules.backgroundLight
        
        self.view.backgroundColor = backgroundLight.color
        self.headerBackground.backgroundColor = backgroundHeader.color
        
        self.titleLabel.font = designSystem.fontRules.font(for: .largeHeader)
        self.titleLabel.textColor = designSystem.colorRules.textColor(on: backgroundHeader, for: .largeHeader)
        self.titleLabel.text = Localization.localizedString("SETTINGS_TITLE")
        
        self.textLabel.font = designSystem.fontRules.font(for: .body)
        self.textLabel.textColor = designSystem.colorRules.textColor(on: backgroundHeader, for: .body)
        self.textLabel.text = Localization.localizedString("SETTINGS_TEXT")
    }
    
    func presentTaskViewController(for type: ReminderType) {
        let task = type.taskViewModel(dayOfStudy: self.scheduleManager.dayOfStudy(), alwaysShow: true)
        let taskViewController = RSDTaskViewController(task: task)
        taskViewController.delegate = self
        self.present(taskViewController, animated: true, completion: nil)
    }
    
    func reminderSettingText(for type: ReminderType) -> String {
        // The text label shows the reminder setting
        if !self.reminderManager.hasReminderBeenScheduled(type: type) ||
            self.reminderManager.doNotRemindSetting(for: type) {
            return Localization.localizedString("NO_REMINDER_HAS_BEEN_SET")
        } else if let timeStr = self.reminderManager.timeSetting(for: type) {
            let weekdayInt = self.reminderManager.daySetting(for: type)
            if weekdayInt == 0 { // daily
                return Localization.localizedStringWithFormatKey("REMINDER_DAILY_%@", timeStr)
            } else if let weekday = RSDWeekday(rawValue: weekdayInt) {  // weekly
                return Localization.localizedStringWithFormatKey("REMINDER_WEEKLY_%@_%@", weekday.text ?? "", timeStr)
            }
        }
        return ""
    }
    
    func taskController(_ taskController: RSDTaskController, didFinishWith reason: RSDTaskFinishReason, error: Error?) {
        
        // Let the schedule manager handle the cleanup.
        scheduleManager.taskController(taskController, didFinishWith: reason, error: error)
        
        // Dismiss the view controller
        (taskController as? UIViewController)?.dismiss(animated: true, completion: nil)
        
        // Check if the task was completed successfully
        if error == nil && reason == .completed {
            // The result may contain reminder information
            // Send it to the reminder manager for processing
            ReminderManager.shared.updateNotifications(for: taskController.taskViewModel.taskResult)
        }
    }
    
    func taskController(_ taskController: RSDTaskController, readyToSave taskViewModel: RSDTaskViewModel) {
        // No need to upload the results
    }
    
    /// UITableViewDelegate and UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ReminderType.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsTableViewCell
        
        let type = ReminderType.allCases[indexPath.row]
        cell.setReminderType(type, settingsText: self.reminderSettingText(for: type))
        cell.setDesignSystem(AppDelegate.designSystem, with: AppDelegate.designSystem.colorRules.backgroundLight)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.presentTaskViewController(for: ReminderType.allCases[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
}

class SettingsTableViewCell: UITableViewCell {
    /// Title label that is associated with this cell.
    @IBOutlet open var titleLabel: UILabel?
    
    /// Text label that is associated with this cell.
    @IBOutlet open var titleDetailLabel: UILabel?
    
    /// Detail label that is associated with this cell.
    @IBOutlet open var detailLabel: UILabel?
    
    /// Divider view that is associated with this cell.
    @IBOutlet open var dividerView: UIView?
    
    func setReminderType(_ type: ReminderType, settingsText: String) {
        self.titleLabel?.text = type.activity().title()
        setDetailText(text: Localization.localizedString("BUTTON_EDIT_DETAILS"))
        self.titleDetailLabel?.text = settingsText
    }
    
    open func setDesignSystem(_ designSystem: RSDDesignSystem, with background: RSDColorTile) {
        let cellBackground = designSystem.colorRules.backgroundLight
        updateColorsAndFonts(designSystem, cellBackground, background)
    }
    
    func updateColorsAndFonts(_ designSystem: RSDDesignSystem, _ background: RSDColorTile, _ tableBackground: RSDColorTile) {
        
        self.titleLabel?.textColor = designSystem.colorRules.textColor(on: background, for: .mediumHeader)
        self.titleLabel?.font = designSystem.fontRules.font(for: .mediumHeader)

        self.titleDetailLabel?.textColor = designSystem.colorRules.textColor(on: background, for: .bodyDetail)
        self.titleDetailLabel?.font = designSystem.fontRules.font(for: .bodyDetail)
        
        self.detailLabel?.textColor = designSystem.colorRules.textColor(on: background, for: .body)
        self.detailLabel?.font = designSystem.fontRules.font(for: .body)
        
        dividerView?.backgroundColor = designSystem.colorRules.palette.grayScale.lightGray.color
    }
    
    func setDetailText(text: String?) {
        guard let textUnwrapped = text else {
            self.detailLabel?.text = nil
            return
        }
        // Add underline attribute
        let textRange = NSMakeRange(0, textUnwrapped.count)
        let attributedText = NSMutableAttributedString(string: textUnwrapped)
        attributedText.addAttribute(NSAttributedString.Key.underlineStyle , value: NSUnderlineStyle.single.rawValue, range: textRange)
        self.detailLabel?.attributedText = attributedText
    }
}

