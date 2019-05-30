//
//  BBLPsychTestInfo.h
//  BrainBaseline Framework
//
//  Created by Michael Merickel on 12/15/16.
//  Copyright © 2016 Digital Artefacts LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class BBLContext;

/**
 A simple value object containing information about a psych test.
 */
@interface BBLPsychTestInfo : NSObject

/**
 A list of all bundled psych tests. Some of the tests may not support
 the current interface idiom and should be ignored.
 
 @param context The context containing the psych tests.
 
 @see `[BBLPsychTestInfo availablePsychTestsInContext:]`
 */
+ (NSSet<BBLPsychTestInfo *> *)allPsychTestsInContext:(BBLContext *)context;

/**
 A list of the psych tests available for use in the current interface idiom.
 
 @param context The context containing the psych tests.
 */
+ (NSSet<BBLPsychTestInfo *> *)availablePsychTestsInContext:(BBLContext *)context;

/**
 Load a `BBLPsychTestInfo` object for a given named psych test.
 
 @param psychTestName The name, such as `PTBlink-Consumer`.
 @param context The context containing the psych tests.
 */
+ (nullable BBLPsychTestInfo *)psychTestInfoNamed:(NSString *)psychTestName inContext:(BBLContext *)context;

/**
 The name of the psych test bundle.
 
 This will be unique per application.
 */
@property (nonatomic, copy) NSString *name;
    
/**
 The version of the psych test bundle assets and configuration.
 */
@property (nonatomic, assign) double bundleVersion;

/**
 The version of the psych test runtime.
 */
@property (nonatomic, assign) double runtimeVersion;

/**
 A localized short title that can be used to display the psych test.
 */
@property (nonatomic, copy) NSString *displayShortTitle;

/**
 A localized title that can be used to display the psych test.
 */
@property (nonatomic, copy) NSString *displayTitle;

/**
 A set of `UIUserInterfaceIdiom`s supported by this psych test.
 */
@property (nonatomic, copy) NSSet<NSNumber *> *supportedUserInterfaceIdioms;

@end

NS_ASSUME_NONNULL_END
