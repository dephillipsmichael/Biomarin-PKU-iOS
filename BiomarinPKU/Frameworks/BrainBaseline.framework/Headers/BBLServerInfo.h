//
//  BBLServerInfo.h
//  BrainBaseline Framework
//
//  Created by Michael Merickel on 11/2/16.
//  Copyright © 2016 Digital Artefacts LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Information about the remote endpoints used to communicate with the
 BrainBaseline platform. For production applictions this should always
 be `defaultServerInfo`.
 */
@interface BBLServerInfo : NSObject <NSCopying, NSCoding>

- (nullable instancetype)init NS_UNAVAILABLE;

/**
 These endpoints represent the production server hosting
 https://www.brainbaseline.com.
 */
+ (instancetype)defaultServerInfo;

/**
 This infrastructure is only accessible from within the BrainBaseline
 platform's internal network and should not be used outside.
 */
+ (instancetype)stagingServerInfo;

@end

NS_ASSUME_NONNULL_END
