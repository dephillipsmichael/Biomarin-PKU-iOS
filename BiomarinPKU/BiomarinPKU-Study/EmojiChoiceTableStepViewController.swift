//
//  EmojiChoiceTableStepViewController.swift
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
import UserNotifications
import BridgeApp
import BridgeAppUI

open class EmojiChoiceFormStepObject: RSDFormUIStepObject, RSDStepViewControllerVendor {
    
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case learnMoreTitle, learnMoreText, emojiImageType
    }
    
    /// The title of the learn more screen
    var learnMoreTitle: String?
    /// The text of the learn more screen
    var learnMoreText: String?
    /// The type of emojis to use for the step
    var emojiImageType: EmojiImageType = .emoji
    
    /// Default type is `.emojiChoice`.
    open override class func defaultType() -> RSDStepType {
        return .emojiChoice
    }
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        learnMoreTitle = try container.decode(String.self, forKey: .learnMoreTitle)
        learnMoreText = try container.decode(String.self, forKey: .learnMoreText)
        emojiImageType = EmojiImageType(rawValue: try container.decode(String.self, forKey: .emojiImageType)) ?? .emoji
    }
    
    required public init(identifier: String, type: RSDStepType?) {
        super.init(identifier: identifier, type: type)
    }
    
    /// Override to set the properties of the subclass.
    override open func copyInto(_ copy: RSDUIStepObject) {
        super.copyInto(copy)
        guard let subclassCopy = copy as? EmojiChoiceFormStepObject else {
            assertionFailure("Superclass implementation of the `copy(with:)` protocol should return an instance of this class.")
            return
        }
        subclassCopy.learnMoreTitle = self.learnMoreTitle
        subclassCopy.learnMoreText = self.learnMoreText
        subclassCopy.emojiImageType = self.emojiImageType
    }    
    
    public func instantiateViewController(with parent: RSDPathComponent?) -> (UIViewController & RSDStepController)? {
        return EmojiChoiceTableStepViewController(step: self, parent: parent)
    }
}

open class EmojiChoiceTableStepViewController: RSDTableStepViewController {
    
    open var emojiStep: EmojiChoiceFormStepObject? {
        return self.step as? EmojiChoiceFormStepObject
    }
    
    open override func setupHeader(_ header: RSDStepNavigationView) {
        super.setupHeader(header)
        
        if let tableHeader = header as? RSDTableStepHeaderView {            
            // Remove detail label text, as it is replaced by learn more
            tableHeader.detailLabel?.text = nil
        }
    }
    
    override open func setupButton(_ button: UIButton?, for actionType: RSDUIActionType, isFooter: Bool) {

        if let detail = uiStep?.detail,
            actionType == .navigation(.learnMore) {
            
            // Switch detail to learn more button
            button?.setTitle(detail, for: .normal)
            button?.addTarget(self, action: #selector(showLearnMore), for: .touchUpInside)
            
        } else {
            super.setupButton(button, for: actionType, isFooter: isFooter)
        }
    }
    
    override open func registerReuseIdentifierIfNeeded(_ reuseIdentifier: String) {
        let reuseId = RSDFormUIHint(rawValue: reuseIdentifier)
        if reuseId == .list {
            // Register our custom emoji cell type
            tableView.register(EmojiChoiceTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
            return
        }
        super.registerReuseIdentifierIfNeeded(reuseIdentifier)
    }
    
    override open func configure(cell: UITableViewCell, in tableView: UITableView, at indexPath: IndexPath) {
        
        // Call before super so that setting table item will have correct image type
        if let emojiCell = cell as? EmojiChoiceTableViewCell {
            emojiCell.emojiImageType = self.emojiStep?.emojiImageType ?? .emoji
        }
        
        super.configure(cell: cell, in: tableView, at: indexPath)
    }
    
    override open func showLearnMore() {
        let step = LearnMoreStep(identifier: "learnMore", type: "learnMore")
        step.title = self.emojiStep?.learnMoreTitle
        step.text = self.emojiStep?.learnMoreText
        
        var navigator = RSDConditionalStepNavigatorObject(with: [step])
        navigator.progressMarkers = []
        let task = RSDTaskObject(identifier: "learnMoreTask", stepNavigator: navigator)
        let vc = RSDTaskViewController(task: task)
        vc.delegate = self
        self.presentModal(vc, animated: true, completion:   nil)
    }
    
    override open func taskController(_ taskController: RSDTaskController, didFinishWith reason: RSDTaskFinishReason, error: Error?) {
        (taskController as? UIViewController)?.dismiss(animated: true, completion: nil)
    }
    
    override open func taskController(_ taskController: RSDTaskController, readyToSave taskViewModel: RSDTaskViewModel) {
    }
    
    // MARK: Reminder notification handling
    
    /// The reminder action associated with this step view controller.
    open private(set) var reminderAction: RSDReminderUIAction?
    
    /// Override skipForward to check if this is a reminder action for the skip button.
    open override func skipForward() {
        // If this is a reminder action then set that and keep a pointer to it.
        self.reminderAction = self.stepViewModel.action(for: .navigation(.skip)) as? RSDReminderUIAction
        if let _ = reminderAction {
            _updateReminderNotification()
        } else {
            super.skipForward()
        }
    }
    
    /// Handle messaging the user that they have previously denied permission to show a local notification.
    open func handleNotificationAuthorizationDenied() {
        let title = Localization.localizedString("REMINDER_AUTH_DENIED_TITLE")
        let message = Localization.localizedString("REMINDER_AUTH_DENIED_MESSAGE")
        self.presentAlertWithOk(title: title, message: message) { (_) in
        }
    }
    
    /// Post an action sheet asking the user how long until they want to be reminded to do this task.
    open func remindMeLater() {
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .hour]
        formatter.unitsStyle = .full
        
        let actionNone = UIAlertAction(title: Localization.localizedString("REMINDER_CHOICE_NONE"), style: .cancel) { (_) in
            // Do nothing.
        }
        
        let action15min = UIAlertAction(title:
        Localization.localizedStringWithFormatKey("REMINDER_CHOICE_IN_DURATION_%@", formatter.string(from: 15 * 60)!), style: .default) { (_) in
            self.addReminder(timeInterval: 15 * 60)
        }
        
        let action1hr = UIAlertAction(title:
        Localization.localizedStringWithFormatKey("REMINDER_CHOICE_IN_DURATION_%@", formatter.string(from: 60 * 60)!), style: .default) { (_) in
            self.addReminder(timeInterval: 60 * 60)
        }
        let action2hr = UIAlertAction(title:
        Localization.localizedStringWithFormatKey("REMINDER_CHOICE_IN_DURATION_%@", formatter.string(from: 2 * 60 * 60)!), style: .default) { (_) in
            self.addReminder(timeInterval: 2 * 60 * 60)
        }
        
        let message = Localization.localizedString("REMINDER_CHOICE_SELECTION_PROMPT")
        
        self.presentAlertWithActions(title: nil, message: message, preferredStyle: .actionSheet, actions: [action2hr, action1hr, action15min, actionNone])
    }
    
    /// Add a reminder to perform this task that is triggered for a time in the future.
    open func addReminder(timeInterval: TimeInterval) {
        guard let reminderIdentifier = reminderAction?.reminderIdentifier else { return }
        
        let content = UNMutableNotificationContent()
        content.title = Localization.localizedString("REMINDER_LATER_CHECK_IN")
        if reminderIdentifier == "\(ReminderType.daily.rawValue)Later" {
            content.title = Localization.localizedString("REMINDER_DAILY_TITLE")
        } else if reminderIdentifier == "\(ReminderType.sleep.rawValue)Later" {
            content.title = Localization.localizedString("REMINDER_SLEEP_TITLE")
        }
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = TaskReminderNotificationCategory
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: reminderIdentifier, content: content, trigger: trigger)
        
        // Schedule the notification.
        UNUserNotificationCenter.current().add(request) { (error) in
            if error != nil {
                print("Failed to add notification for \(reminderIdentifier). \(error!)")
            }
            self.cancel()
        }
    }
    
    fileprivate func _updateReminderNotification() {
        
        // Check if this is the main thread and if not, then call it on the main thread.
        // The expectation is that if calling method is a button push, the response should be inline
        // and *not* at the bottom of the queue.
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self._updateReminderNotification()
            }
            return
        }
        
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] (settings) in
            switch settings.authorizationStatus {
            case .notDetermined:
                self?._requestAuthorization()
            case .denied:
                self?.handleNotificationAuthorizationDenied()
            case .authorized, .provisional:
                self?.remindMeLater()
            @unknown default:
                self?.handleNotificationAuthorizationDenied()
            }
        }
    }
    
    fileprivate func _requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { [weak self] (granted, _) in
            DispatchQueue.main.async {
                if granted {
                    self?.remindMeLater()
                } else {
                    self?.cancel()
                }
            }
        }
    }
}

public enum EmojiImageType: String {
    case emoji = "emoji"
    case sleepEmoji = "sleep"
}

public class EmojiChoiceTableViewCell: RSDSelectionTableViewCell {
    
    internal let kTitleLeadingMargin: CGFloat = 108.0
    
    internal let kImageLeadingMargin: CGFloat = 28.0
    internal let kImageTopMargin: CGFloat = 12.0
    internal let kImageBottomMargin: CGFloat = 20.0
    internal let kImageCenterMargin: CGFloat = -8.0
    internal let kImageSize: CGFloat = 50.0
    
    // The number of emoji image types
    let emojiCount = 5
    
    open var emojiImageType: EmojiImageType = .emoji
    
    @IBOutlet public var emojiImageView: UIImageView?
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        // Setup the emoji image constraints to set the height of the cell
        emojiImageView = UIImageView()
        contentView.addSubview(emojiImageView!)
        emojiImageView?.contentMode = .scaleAspectFit
        emojiImageView?.rsd_alignToSuperview([.leading], padding: kImageLeadingMargin)
        emojiImageView?.rsd_alignToSuperview([.top], padding: kImageTopMargin)
        emojiImageView?.rsd_alignToSuperview([.bottom], padding: kImageBottomMargin)
        emojiImageView?.rsd_makeHeight(.equal, kImageSize)
        emojiImageView?.rsd_makeWidth(.equal, kImageSize)
        emojiImageView?.translatesAutoresizingMaskIntoConstraints = false
        
        // The title label must now be shifted to the right and down,
        // So loop through all its constraints and remove leading and top
        let constraintsToRemove = contentView.constraints.filter { (constraint) -> Bool in
            guard let label = constraint.firstItem as? UILabel, label == titleLabel else { return false }
            return constraint.firstAttribute == .leading || constraint.firstAttribute == .top
        }
        constraintsToRemove.forEach({ $0.isActive = false })
        
        // Reset the constraints to the values we want
        titleLabel?.rsd_alignToSuperview([.leading], padding: kTitleLeadingMargin)
        titleLabel?.rsd_alignCenterVertical(padding: kImageCenterMargin / 2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public var tableItem: RSDTableItem! {
        didSet {
            guard let item = tableItem as? RSDChoiceTableItem else { return }
            titleLabel?.text = item.choice.text
            detailLabel?.text = item.choice.detail
            isSelected = item.selected
            
            // Here we set the emoji image based on the choice value
            // Currently the only values compatible are 1-5
            if let intAnswer = item.choice.answerValue as? Int,
                intAnswer > 0, intAnswer <= emojiCount {
                emojiImageView?.image = UIImage(named: "\(emojiImageType.rawValue.capitalized)\(intAnswer)")
            } else {
                emojiImageView?.image = nil
            }
        }
    }
}

