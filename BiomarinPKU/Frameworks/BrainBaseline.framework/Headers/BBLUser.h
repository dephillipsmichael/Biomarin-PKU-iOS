//
//  BBLUser.h
//  BrainBaseline Framework
//
//  Created by Michael Merickel on 11/2/16.
//  Copyright © 2016 Digital Artefacts LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class BBLContext;
@class BBLPsychTestResultID;

/**
 A `BBLUser` object exists for each user created on a context.
 
 Existing user objects should be loaded via
 `[BBLUser existingUserWithName:inContext:]`. New users can be created using
 `[BBLUser newUserWithName:inContext:]`.
 */
@interface BBLUser : NSObject

/**
 Create a new user. It is an error to use this method if the user
 already exists.
 
 @param name The name of the user in this study. This name will show up
             in reports and be the primary identifier for the user.
 @param context The study context to which this user will belong.
 */
+ (instancetype)newUserWithName:(NSString *)name inContext:(BBLContext *)context;

/**
 Load an existing `BBLUser` object.
 
 @param name The name of the user.
 @param context The study context to which this user will belong.
 */
+ (nullable instancetype)existingUserWithName:(NSString *)name inContext:(BBLContext *)context;

- (nullable instancetype)init NS_UNAVAILABLE;

/**
 The `BBLContext` to which this user object belongs.
 */
@property (nonatomic, readonly) BBLContext *context;

/**
 The name of the user. This will show up in reports, etc.
 */
@property (nonatomic, readonly) NSString *name;

/**
 Set a property value for the user. For example, `BBLUserProperty_Gender`.
 Many properties have specific values they support, so be sure the value
 conforms to the specific property's contract.
 
 @param property The property key.
 @param value The value should be JSON serializable.
 */
- (void)setProperty:(NSString *)property value:(nullable id)value;

/**
 Query for the value of a user property.
 
 @param property The property key.
 
 @see `[BBLUser setProperty:value:]`
 */
- (nullable id)valueForProperty:(NSString *)property;

/**
 A list of all `BBLPsychTestResultID` objects for the user.
 */
- (NSArray<BBLPsychTestResultID *> *)allPsychTestResultIds;

@end

NS_ASSUME_NONNULL_END
