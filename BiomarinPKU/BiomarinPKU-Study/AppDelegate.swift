//
//  AppDelegate.swift
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
import Research
import SafariServices
import BrainBaseline
import UserNotifications

typealias FitbitCompletionHandler = (_ accessToken: String?, _ error: Error?) -> ()

@UIApplicationMain
class AppDelegate: SBAAppDelegate, RSDTaskViewControllerDelegate {
    
    let onboardingTaskId = "signin"
    let haveShownStudyIntroKey = "haveShownStudyIntro"
    
    var deepLinkActivity: ActivityType?
    
    static let colorPalette = RSDColorPalette(version: 1,
                                              primary: RSDColorMatrix.shared.colorKey(for: .palette(.butterscotch),
                                                                                      shade: .medium),
                                              secondary: RSDColorMatrix.shared.colorKey(for: .palette(.lavender),
                                                                                        shade: .dark),
                                              accent: RSDColorMatrix.shared.colorKey(for: .palette(.rose),
                                                                                     shade: .dark))
    static let designSystem = RSDDesignSystem(version: 1,
                                              colorRules: RSDColorRules(palette: colorPalette, version: 1),
                                              fontRules: FontRules(version: 1))
    
    /**
     TODO: mdephillips 5/24/19
     This component of the code that CRF was using, SFAuthenticationSession,
     is now deprecated in iOS 12.  We may need to migrate to Apple’s new component
     for oauth at some point.
     See https://ajkueterman.com/apple/wwdc/sfauthenticationsession-and-aswebauthenticationsession/
     */
    var authSession: SFAuthenticationSession?
    var fitbitCompletionHandler: FitbitCompletionHandler?    

    override func instantiateColorPalette() -> RSDColorPalette? {
        return AppDelegate.colorPalette
    }
    
    func showAppropriateViewController(animated: Bool) {
        let isFitbitConnected = UserDefaults.standard.bool(forKey: FitbitStep.isFitbitConnectedKey)
        let haveShownStudyIntro = UserDefaults.standard.bool(forKey: haveShownStudyIntroKey)
        if BridgeSDK.authManager.isAuthenticated() && isFitbitConnected && haveShownStudyIntro {
            showMainViewController(animated: animated)
        } else {
            showSignInViewController(animated: animated)
        }
    }
    
    override func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Set up localization.
        let mainBundle = LocalizationBundle(bundle: Bundle.main, tableName: "PKU")
        Localization.insert(bundle: mainBundle, at: 0)
        
        // Set up font rules.
        RSDStudyConfiguration.shared.fontRules = FontRules(version: 0)
        
        // Setup reminders
        RSDStudyConfiguration.shared.shouldShowRemindMe = true
        
        // Register for BrainBasline results
        let bblContext = BrainBaselineManager.brainBaselineContext
        NotificationCenter.default.addObserver(forName: NSNotification.Name.BBLContextDidUpdatePsychTestResult, object: bblContext, queue: OperationQueue.main) { (note) in
            guard let resultId = note.userInfo?[BBLContextDidUpdatePsychTestResultNotificationResultIDKey] as? BBLPsychTestResultID
                else { return }
            debugPrint("received update for resultId=\(resultId)")
            
            do {
                let result = try BBLPsychTestResult(id: resultId, in: bblContext)
                debugPrint("received brain baseline result=\(result)")
            }
            catch let error {
                assertionFailure("expecting to find a result for id=\(resultId), error=\(error)")
            }
        }
        
        // Setup reminder manager
        ReminderManager.shared.setupNotifications()
        UNUserNotificationCenter.current().delegate = ReminderManager.shared
        
        return super.application(application, willFinishLaunchingWithOptions: launchOptions)
    }

    override func applicationDidBecomeActive(_ application: UIApplication) {
        super.applicationDidBecomeActive(application)
        
        self.showAppropriateViewController(animated: true)
    }
    
    func showMainViewController(animated: Bool) {
        guard self.rootViewController?.state != .main else {
            setDeepLinkActivityOnViewController()
            return
        }
        guard let storyboard = openStoryboard("Main"),
            let vc = storyboard.instantiateInitialViewController()
            else {
                fatalError("Failed to instantiate initial view controller in the main storyboard.")
        }
        self.transition(to: vc, state: .main, animated: true)
        setDeepLinkActivityOnViewController()
    }
    
    func showSignInViewController(animated: Bool) {
        guard self.rootViewController?.state != .onboarding else { return }
        
        let externalIDStep = ExternalIDRegistrationStep(identifier: "enterExternalID", type: "externalID")
        let fitbitStep = FitbitStep(identifier: "fitbit", type: "connectFitbit")
        
        var navigator = RSDConditionalStepNavigatorObject(with: [externalIDStep, fitbitStep, studyIntroStep1(), studyIntroStep2()])
        navigator.progressMarkers = []
        let task = RSDTaskObject(identifier: onboardingTaskId, stepNavigator: navigator)
        let vc = RSDTaskViewController(task: task)
        vc.delegate = self
        self.transition(to: vc, state: .onboarding, animated: true)
    }
    
    func setDeepLinkActivityOnViewController() {
        guard let activity = self.deepLinkActivity else { return }
        ((self.rootViewController?.children.first(where: { $0 is UITabBarController }) as? UITabBarController)?.children.first(where: { $0 is ActivityViewController }) as? ActivityViewController)?.deepLinkActivity = activity
        self.deepLinkActivity = nil
    }
    
    func studyIntroStep1() -> RSDStep {
        let step = IntroStepObject(identifier: "intro1")
        step.title = Localization.localizedString("STUDY_INTRO_TITLE_1")
        step.text = Localization.localizedString("STUDY_INTRO_TEXT_1")
        step.shouldHideActions = [.navigation(.cancel), .navigation(.goBackward), .navigation(.skip)]
        step.imageTheme = RSDFetchableImageThemeElementObject(imageName: "Intro1Header")
        return step
    }
    
    func studyIntroStep2() -> RSDStep {
        let step = IntroStepObject(identifier: "intro2")
        step.text = Localization.localizedString("STUDY_INTRO_TEXT_2")
        step.shouldHideActions = [.navigation(.cancel), .navigation(.skip)]
        step.imageTheme = RSDFetchableImageThemeElementObject(imageName: "Intro1Header")
        step.actions = [.navigation(.goForward): RSDUIActionObject(buttonTitle: Localization.localizedString("BUTTON_LETS_GO"))]
        return step
    }
    
    func week1CompleteSteps(dayOfStudy: Int) -> [RSDStep] {
        let intro = IntroStepObject(identifier: "intro")
        intro.title = Localization.localizedString("WEEK_1_COMPLETE_TITLE_1")
        intro.text = Localization.localizedString("WEEK_1_COMPLETE_TEXT")
        intro.shouldHideActions = [.navigation(.cancel), .navigation(.goBackward), .navigation(.skip)]
        intro.imageTheme = RSDFetchableImageThemeElementObject(imageName: "Intro1Header")
        intro.actions = [.navigation(.goForward): RSDUIActionObject(buttonTitle: Localization.localizedString("WEEK_1_COMPLETE_NEXT_BUTTON"))]
        
        let reminderPhysicalStep = ReminderType.physical.createReminderStep(identifier: "physicalReminder", dayOfStudy: dayOfStudy, alwaysShow: true)
        reminderPhysicalStep.shouldHideActions?.append(contentsOf: [.navigation(.cancel), .navigation(.goBackward)])
        reminderPhysicalStep.actions?[.navigation(.goForward)] = RSDUIActionObject(buttonTitle: Localization.localizedString("SET_NEXT_REMINDER"))
        
        let reminderCognitiveStep = ReminderType.cognition.createReminderStep(identifier: "cognitiveReminder", dayOfStudy: dayOfStudy, alwaysShow: true)
        reminderPhysicalStep.shouldHideActions?.append(contentsOf: [.navigation(.cancel), .navigation(.goBackward)])
        reminderCognitiveStep.actions?[.navigation(.goForward)] = RSDUIActionObject(buttonTitle: Localization.localizedString("BUTTON_DONE"))
        
        return [intro, reminderPhysicalStep, reminderCognitiveStep]
    }
    
    func openStoryboard(_ name: String) -> UIStoryboard? {
        return UIStoryboard(name: name, bundle: nil)
    }    
    
    // MARK: RSDTaskViewControllerDelegate
    
    func taskController(_ taskController: RSDTaskController, didFinishWith reason: RSDTaskFinishReason, error: Error?) {
        guard BridgeSDK.authManager.isAuthenticated() else { return }
        
        // Once we have shown the user the study intro screen,
        // set the value in local memory so they can proceed to the app
        if reason == .completed &&
            taskController.taskViewModel.identifier == onboardingTaskId {
            UserDefaults.standard.set(true, forKey: haveShownStudyIntroKey)
        }
        
        showAppropriateViewController(animated: true)
    }
    
    func taskController(_ taskController: RSDTaskController, readyToSave taskViewModel: RSDTaskViewModel) {
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        debugPrint("\(String(describing: userActivity.webpageURL))")
        guard let fitbitCompletionURL = userActivity.webpageURL else { return false }
        
        // Close the auth session. This ends up calling its completion handler with an error.
        // emm 2017-11-09 As of iOS SDK 11.1 that behavior no longer applies, so now we call it explicitly.
        self.authSession?.cancel()
        self.authSession = nil
        self.fitbitAuthCompletionHandler(url: fitbitCompletionURL, error: nil)
        debugPrint("Safari auth session ended")
        
        return true
    }
    
    func fitbitAuthCompletionHandler (url: URL?, error: Error?) -> () {
        let completion = self.fitbitCompletionHandler
        
        // reset it in case there's a next time
        self.fitbitCompletionHandler = nil
        
        guard let successURL = url else {
            completion?(nil, error)
            return
        }
        
        let codeArg = NSURLComponents(string: (successURL.absoluteString))?.queryItems?.filter({$0.name == "code"}).first
        let authCode = codeArg?.value
        debugPrint("auth code: \(String(describing: authCode))")
        
        SBBOAuthManager.default()?.getAccessToken(forVendor: "fitbit", authCode: authCode) { (oauthAccessToken, error) in
            DispatchQueue.main.async {
                guard let oauthAccessTokenUnwrapped = oauthAccessToken else {
                    debugPrint("error retrieving access token: \(String(describing: error))")
                    completion?(nil, error)
                    return
                }
                let accessToken = oauthAccessTokenUnwrapped.accessToken
                debugPrint("access token: \(String(describing: accessToken))")
                completion?(accessToken, nil)
            }
        }
    }
    
    func connectToFitbit(completionHandler: FitbitCompletionHandler? = nil) {
        // Fitbit Authorization Code Grant Flow URL
        guard let authURL = URL(string: "https://www.fitbit.com/oauth2/authorize?response_type=code&client_id=22DJ23&redirect_uri=org.sagebase.BiomarinPKU%3A%2F%2Foauth2&scope=activity%20heartrate%20sleep&expires_in=604800") else { return }
        
        fitbitCompletionHandler = completionHandler
        
        debugPrint("Starting Safari auth session: \(authURL)")
        
        // Fitbit only lets us give one callback URL per app, so if we want to use the same Fitbit app for both iOS and Android (and potentially web clients)
        // we need to *not* use a custom URL scheme. But SFAuthenticationSession's completion handler requires it to be a custom URL scheme. So instead we will
        // handle the callback in the place that Universal Links are handled, i.e., application(_:, continue:, restorationHandler:), and close the
        // SFAuthenticationSession from there. emm 2017-11-03
        self.authSession = SFAuthenticationSession(url: authURL, callbackURLScheme: nil, completionHandler: self.fitbitAuthCompletionHandler)
        authSession!.start()
    }
}

class IntroStepObject: RSDUIStepObject, RSDStepViewControllerVendor {
    public func instantiateViewController(with parent: RSDPathComponent?) -> (UIViewController & RSDStepController)? {
        return RSDInstructionStepViewController(step: self, parent: parent)
    }
}
