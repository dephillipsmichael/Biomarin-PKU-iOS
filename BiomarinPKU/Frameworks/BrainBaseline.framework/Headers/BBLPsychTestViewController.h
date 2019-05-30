//
//  BBLPsychTestViewController.h
//  BrainBaseline Framework
//
//  Created by Michael Merickel on 11/1/16.
//  Copyright © 2016 Digital Artefacts LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class BBLContext;
@class BBLPsychTestInfo;
@class BBLPsychTestResultID;
@class BBLPsychTestViewController;
@class BBLUser;


/**
 The delegate receives information on the lifecycle of the `BBLPsychTestViewController`.
 */
@protocol BBLPsychTestViewControllerDelegate <NSObject>

/**
 When this method is invoked it's expected that the
 `BBLPsychTestViewController` is relinquishing control and the application is
 responsible for removing it from the screen and continuing with its logic.
 
 This method is always invoked after `psychTestViewControllerDidEndExperiment:`.
 
 @param controller The `BBLPsychTestViewController` object for this delegate.
 */
- (void)psychTestViewControllerDidFinish:(BBLPsychTestViewController *)controller;

@optional

/**
 The background activity will be paused prior to invoking this delegate method.
 
 @param controller The `BBLPsychTestViewController` object for this delegate.
 */
- (void)psychTestViewControllerWillBeginExperiment:(BBLPsychTestViewController *)controller;

/**
 The background activity will be resumed and the
 `[BBLPsychTestViewController psychTestResultID]` will be set prior to
 invoking this delegate method.
 
 @param controller The `BBLPsychTestViewController` object for this delegate.
 */
- (void)psychTestViewControllerDidEndExperiment:(BBLPsychTestViewController *)controller;

@end


/**
 The `BBLPsychTestViewController` is a `UIViewController` for presenting and
 administering a psych test.
 
 It is expected that the controller will always be displayed in landscape mode
 on top of a navigation controller. The `navigationItem` will contain the
 button required for quitting the psych test.
 */
@interface BBLPsychTestViewController : UIViewController

/**
 A helper to initialize a controller for a particular psych test.
 
 @param name The name of a psych test bundle as returned by
             [BBLPsychTestInfo availablePsychTestsInContext:].
 @param context The `BBLContext` in which the test will execute.
 @param error If the psych test cannot be found or is not supported on this
              device then the appropriate `BBLErrorCode` will indicate the issue.
 */
+ (nullable instancetype)controllerWithPsychTestNamed:(NSString *)name inContext:(BBLContext *)context error:(NSError * _Nullable * _Nullable)error;

/**
 Create an instance of a `BBLPsychTestViewController`.
 
 @param info A `BBLPsychTestInfo` object.
 @param context The `BBLContext` in which the test will execute.
 */
- (instancetype)initWithPsychTestInfo:(BBLPsychTestInfo *)info inContext:(BBLContext *)context
    NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)init NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

/**
 The `BBLContext` used to load and store the psych test results.
 */
@property (nonatomic, readonly) BBLContext *context;

/**
 The instance of `BBLPsychTestInfo` representing the psych test loaded into
 the controller.
 */
@property (nonatomic, readonly) BBLPsychTestInfo *psychTestInfo;

/**
 The `BBLPsychTestViewControllerDelegate` which will receive information about
 lifecycle changes within the psych test.
 */
@property (nonatomic, weak, nullable) id<BBLPsychTestViewControllerDelegate> delegate;

/**
 Should the "Skip Practice" button be displayed for this task?
 
 Default: `NO`.
 */
@property (nonatomic, assign) BOOL hideSkipPracticeButton;

/**
 Should the "Quit" button be displayed?
 
 Default: `NO`.
 */
@property (nonatomic, assign) BOOL hideQuitButton;

/**
 Should the progress bar be displayed?
 
 Default: `NO`.
 */
@property (nonatomic, assign) BOOL hideProgressBar;

/**
 Should the "Test Complete" view be displayed for this task?
 
 Default: `NO`.
 */
@property (nonatomic, assign) BOOL hideSummaryView;

/**
 If the `user` is `nil` then no psych test result will be recorded.
 
 This user will show up in the reports.
 */
@property (nonatomic, nullable) BBLUser *user;
/**
 The `sessionId` may be set here to affect the session that shows up in the
 reports.
 */
@property (nonatomic, copy) NSString *sessionId;

/**
 This attribute will only be populated if the test was successfully completed
 and the `userId` is not `nil`. It will be populated before
 `[BBLPsychTestViewControllerDelegate psychTestViewControllerDidEndExperiment:]`
 is invoked.
 */
@property (nonatomic, readonly, nullable) BBLPsychTestResultID *psychTestResultID;

@end

NS_ASSUME_NONNULL_END
