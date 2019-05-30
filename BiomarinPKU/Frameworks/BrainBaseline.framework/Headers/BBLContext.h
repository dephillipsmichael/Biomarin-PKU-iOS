//
//  BBLContext.h
//  BrainBaseline Framework
//
//  Created by Michael Merickel on 11/1/16.
//  Copyright © 2016 Digital Artefacts LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class BBLServerInfo;

/**
 Register for this notification on the `[NSNotificationCenter defaultCenter]`
 to be notified when updated result scores are available.
 
 The `userInfo` key `BBLContextDidUpdatePsychTestResultNotificationResultIDKey`
 will contain the `BBLPsychTestResultID` object of the result that was updated.
 
 This notification is dispatched on the main thread.
 */
extern NSString *const BBLContextDidUpdatePsychTestResultNotification;

/**
 The `[NSNotification userInfo]` key for the updated `BBLPsychTestResultID`
 object.
 */
extern NSString *const BBLContextDidUpdatePsychTestResultNotificationResultIDKey;

/**
 `BBLContext` is a handle to the framework's entire lifecycle and is
 required by most APIs. A reference to the context should be created and
 kept for the entire life of the application, usually by hanging onto
 it in your `AppDelegate`.
 */
@interface BBLContext : NSObject

/**
 Create a new context. Only one context should be created per `studyId`
 and should be considered threadsafe.

 @param studyId The identifier provided to you uniquely identifying your
                study on the BrainBaseline platform.
 @param resourceBundle The resource bundle provided for use with the framework.
 @param serverInfo The server information for which the library will be
                   communicating. In most cases this should be
                   [BBLServerInfo defaultServerInfo].
 */
+ (instancetype)contextWithStudyId:(NSString *)studyId
                    resourceBundle:(NSBundle *)resourceBundle
                        serverInfo:(BBLServerInfo *)serverInfo;

- (nullable instancetype)init NS_UNAVAILABLE;

/**
 The study identifier to which this context is coupled.
 */
@property (nonatomic, readonly) NSString *studyId;

/**
 The resource bundle containing study configuration.
 */
@property (nonatomic, readonly) NSBundle *resourceBundle;

/**
 The `appInstallId` will be populated once the application has successfully
 authorized itself with the BrainBaseline platform and should not change
 between instances of the context for the same `studyId`. It may be
 displayed to the user for debugging purposes.
 */
@property (nonatomic, readonly, nullable) NSString *appInstallId;

/**
 A flag indicating whether there remains any dirty user-related data that
 still needs to sync with the server.
 */
@property (nonatomic, readonly, getter = isUserDataSynced) BOOL userDataSynced;

/**
 Whether or not the services associated with the context are allowed to
 access the network.
 
 Services are usually paused during the psych tests.
 
 By default, the context initializes itself with background activity enabled.
 */
@property (nonatomic, readonly, getter = isBackgroundActivityPaused) BOOL backgroundActivityPaused;

/**
 Resume background activity after previously pausing it using
 `pauseBackgroundActivity`.
 */
- (void)resumeBackgroundActivity;

/**
 Pause background activity. Activity will remain paused until either the
 application restarts or another call to `resumeBackgroundActivity`.
 */
- (void)pauseBackgroundActivity;

@end

NS_ASSUME_NONNULL_END
