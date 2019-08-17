//
//  ReminderManager.swift
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

let TaskReminderNotificationCategory = "TaskReminder"

open class ReminderManager : NSObject, UNUserNotificationCenterDelegate {
    public static var shared = ReminderManager()
    
    fileprivate var timeFormatterPrivate: DateFormatter?
    open var timeFormatter: DateFormatter {
        if let timeFormatterUnwrapped = timeFormatterPrivate {
            return timeFormatterUnwrapped
        }
        let timeFormatterUnwrapped = DateFormatter()
        timeFormatterUnwrapped.locale = Locale(identifier: "en_US_POSIX")
        timeFormatterUnwrapped.dateFormat = "h:mm a"
        timeFormatterUnwrapped.amSymbol = "AM"
        timeFormatterUnwrapped.pmSymbol = "PM"
        timeFormatterPrivate = timeFormatterUnwrapped
        return timeFormatterUnwrapped
    }
    
    open func userNotificationCenter(_ center: UNUserNotificationCenter,
                                     willPresent notification: UNNotification,
                                     withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        // Play sound and show alert to the user
        completionHandler([.alert, .sound])
    }
    
    open func userNotificationCenter(_ center: UNUserNotificationCenter,
                                     didReceive response: UNNotificationResponse,
                                     withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let identifier = response.notification.request.identifier
        guard let reminderType = ReminderType(rawValue: identifier) else {
            debugPrint("Unknown reminder type received \(identifier)")
            return
        }
        
        if let vc = (AppDelegate.shared as? AppDelegate)?.rootViewController?.children.first(where: { $0 is ActivityViewController }) as? ActivityViewController {
            if vc.activitiesLoaded {
                vc.presentTaskViewController(for: reminderType.activity())
            } else {
                vc.deepLinkActivity = reminderType.activity()
            }
        } else {
            (AppDelegate.shared as? AppDelegate)?.deepLinkActivity = reminderType.activity()
        }
        
        completionHandler()
    }
    
    public func setupNotifications() {
        let categories = self.notificationCategories()
        UNUserNotificationCenter.current().setNotificationCategories(categories)
    }
    
    public func cancelAllNotifications() {
        debugPrint("Cancelling all notifications")
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    public func cancelNotification(for type: ReminderType) {
        debugPrint("Cancelling notification for reminder type \(type)")
        UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
            let requestIds: [String] = requests.compactMap {
                guard $0.content.categoryIdentifier == TaskReminderNotificationCategory,
                    $0.identifier == type.rawValue else { return nil }
                return $0.identifier
            }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: requestIds)
        }
    }
    
    open func notificationCategories() -> Set<UNNotificationCategory> {
        let defaultCategory = UNNotificationCategory(identifier: TaskReminderNotificationCategory,
                                              actions: [],
                                              intentIdentifiers: [], options: [])
        
        return [defaultCategory]
    }
    
    public func updateNotifications(for result: RSDTaskResult) {
        ReminderType.allCases.forEach { (type) in
            if let doNotRemindAnswer = self.findDoNotRemindAnswer(for: type, from: result) {
                
                // We have the do not remind answer, which means this reminder
                // type was saved during this task
                // Cancel any existing notifications
                self.cancelNotification(for: type)
                
                // Re-schedule the notification if applicable
                if !doNotRemindAnswer,
                    let timeAnswer = self.findTimeAnswer(for: type, from: result) {
                    
                    if let dayAnswer = self.findDayAnswer(for: type, from: result) {
                        if let weekly = self.weeklyDateComponents(with: timeAnswer, on: dayAnswer) {
                            type.saveReminderInfo(doNotRemind: doNotRemindAnswer, at: timeAnswer, on: dayAnswer)
                            self.scheduleReminderNotification(for: type, dateComponents: weekly)
                        }
                    } else if let daily = self.dailyDateComponents(with: timeAnswer) {
                        type.saveReminderInfo(doNotRemind: doNotRemindAnswer, at: timeAnswer, on: nil)
                        self.scheduleReminderNotification(for: type, dateComponents: daily)
                    }
                } else {
                    type.saveReminderInfo(doNotRemind: doNotRemindAnswer, at: nil, on: nil)
                }
            }
        }
    }
    
    func scheduleReminderNotification(for type: ReminderType, dateComponents: DateComponents) {
        
        debugPrint("Scheduling notification reminder type \(type) at time \(dateComponents.hour ?? 0):\(dateComponents.minute ?? 0) on weekday \(dateComponents.weekday ?? -1)")
        
        // Set up the notification
        let content = UNMutableNotificationContent()
        // TODO: syoung 08/10/2018 Figure out what the wording of the notification should be and localize.
        content.body = type.title()
        content.sound = UNNotificationSound.default
        content.badge = UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber;
        content.categoryIdentifier = TaskReminderNotificationCategory
        // We want all the task reminders to show up in a group
        content.threadIdentifier = "TaskThread"
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Create the request.
        let identifier = type.rawValue
        let request =  UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // use dispatch async to allow the method to return and put updating reminders on the next run loop
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .denied:
                break   // Do nothing. We don't want to pester the user with message.
                case .notDetermined:
                    // The user has not given authorization, but the app has a record of previously requested.
                    // we still don't want to message the user about it
                    break
                case .authorized, .provisional:
                    UNUserNotificationCenter.current().add(request)
                    break
                @unknown default:
                    // Do nothing.
                    break
                }
            }
        }
    }
    
    func dailyDateComponents(with timeStr: String) -> DateComponents? {
        guard let date = timeFormatter.date(from: timeStr) else { return nil }
        return Calendar.current.dateComponents([.hour, .minute], from: date)
    }
    
    func weeklyDateComponents(with timeStr: String, on weekday: RSDWeekday) -> DateComponents? {
        guard let date = timeFormatter.date(from: timeStr) else { return nil }
        var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: date)
        dateComponents.weekday = weekday.rawValue
        return dateComponents
    }
    
    func findDoNotRemindAnswer(for reminderType: ReminderType, from result: RSDTaskResult) -> Bool? {
        let targetIdentifier = "\(reminderType.rawValue)\(ReminderStepObject.doNotRemindResultIdentifier)"
        let result = result.stepHistory.first(where: { $0.identifier == targetIdentifier })
        
        return (result as? RSDAnswerResultObject)?.value as? Bool
    }
    
    func findTimeAnswer(for reminderType: ReminderType, from result: RSDTaskResult) -> String? {
        let targetIdentifier = "\(reminderType.rawValue)\(ReminderStepObject.timeResultIdentifier)"
        let result = result.stepHistory.first(where: { $0.identifier == targetIdentifier })
        
        return (result as? RSDAnswerResultObject)?.value as? String
    }
    
    func findDayAnswer(for reminderType: ReminderType, from result: RSDTaskResult) -> RSDWeekday? {
        let targetIdentifier = "\(reminderType.rawValue)\(ReminderStepObject.dayResultIdentifier)"
        let result = result.stepHistory.first(where: { $0.identifier == targetIdentifier })
        
        guard let intAnswer = (result as? RSDAnswerResultObject)?.value as? Int else {
            return nil
        }
        return RSDWeekday(rawValue: intAnswer)
    }
}

public enum ReminderType: String, CaseIterable, Decodable {
    case daily = "daily"
    case sleep = "sleep"
    case physical = "physical"
    case cognition = "cognition"
    
    func hasBeenScheduled() -> Bool {
        return UserDefaults.standard.object(forKey: self.doNotRemindIdentifier()) != nil
    }
    
    func saveReminderInfo(doNotRemind: Bool, at time: String?, on day: RSDWeekday?) {
        let standard = UserDefaults.standard
        standard.set(doNotRemind, forKey: self.doNotRemindIdentifier())
        if let timeUnwrapped = time {
            standard.set(timeUnwrapped, forKey: self.timeRemindIdentifier())
        }
        if let dayUnwrapped = day {
            standard.set(dayUnwrapped, forKey: self.dayRemindIdentifier())
        }
    }
    
    func doNotRemindIdentifier() -> String {
        return "\(self.rawValue)\(ReminderStepObject.doNotRemindResultIdentifier)"
    }
    
    func timeRemindIdentifier() -> String {
        return "\(self.rawValue)\(ReminderStepObject.timeResultIdentifier)"
    }
    
    func dayRemindIdentifier() -> String {
        return "\(self.rawValue)\(ReminderStepObject.dayResultIdentifier)"
    }
    
    func setHasBeenScheduled() {
        UserDefaults.standard.set(true, forKey: "\(self.rawValue)\(ReminderStepObject.doNotRemindResultIdentifier)")
    }
    
    func title() -> String {
        switch self {
        case .daily:
            return Localization.localizedString("REMINDER_DAILY_TITLE")
        case .sleep:
            return Localization.localizedString("REMINDER_SLEEP_TITLE")
        case .physical:
            return Localization.localizedString("REMINDER_PHYSICAL_TITLE")
        case .cognition:
            return Localization.localizedString("REMINDER_COGNITION_TITLE")
        }
    }
    
    func jsonFileName() -> String {
        return "\(self.rawValue.capitalized) Reminder"
    }
    
    func activity() -> ActivityType {
        switch self {
        case .daily: return .daily
        case .sleep: return .sleep
        case .physical: return .physical
        case .cognition: return .cognition
        }
    }
}

