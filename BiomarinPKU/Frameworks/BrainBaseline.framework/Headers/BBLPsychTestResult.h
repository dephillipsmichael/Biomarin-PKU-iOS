//
//  BBLPsychTestResultID.h
//  BrainBaseline Framework
//
//  Created by Michael Merickel on 12/15/16.
//  Copyright © 2016 Digital Artefacts LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class BBLContext;
@class BBLUser;

/**
 An opaque handle to a psych test result.
 
 These are unique per `[BBLContext appInstallId]` and uniquely refer to a
 single test result created by a psych test.
 */
@interface BBLPsychTestResultID : NSObject <NSCopying, NSCoding>

@end

/**
 The percentile score is represented by a percentile between 0 and 100,
 inclusive, and a possible error estimate.
 */
@interface BBLPercentileScore : NSObject <NSCopying, NSCoding>

/**
 Create a `BBLPercentileScore` object from a score array.
 
 @param scores A 1- or 3-element list of scores of the format [score, worstScore, bestScore].
 */
- (instancetype)initWithScores:(NSArray *)scores NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)init NS_UNAVAILABLE;

/**
 The computed percentile score for the population.
 */
@property (nonatomic, readonly) float percentile;

/**
 `YES` if an error estimate was able to be computed for this score.
 */
@property (nonatomic, readonly) BOOL hasErrorScores;

/**
 The worst percentile score given the error estimates for the test.
 
 This value is only valid if `hasError` is `YES`.
 */
@property (nonatomic, readonly) float worstPercentile;

/**
 The best percentile score given the error estimates for the test.
 
 This value is only valid if `hasError` is `YES`.
 */
@property (nonatomic, readonly) float bestPercentile;

@end

/**
 A result is computed for a completed psych test and contains the
 percentile scores in various population groups.
 
 The scores may change over time as more data is acquired.
 */
@interface BBLPsychTestResult : NSObject

/**
 Create a new `BBLPsychTestResult` instance from a given `BBLPsychTestResultID`.
 
 @param resultId The `BBLPsychTestResultID` uniquely identifying the result.
 @param context The `BBLContext` containing the result.
 @param error If the result cannot be found for the specified `resultId` then
              the error will contain a `BBLErrorCode` explaining why the result
              is missing.
 */
+ (nullable instancetype)resultWithId:(BBLPsychTestResultID *)resultId inContext:(BBLContext *)context error:(NSError * _Nullable * _Nullable)error;

- (nullable instancetype)init NS_UNAVAILABLE;

/**
 The `BBLPsychTestResultId` that uniquely identifies this result in
 the `BBLContext`.
 */
@property (nonatomic, readonly) BBLPsychTestResultID *resultId;

/**
 The `BBLContext` containing this result.
 */
@property (nonatomic, readonly) BBLContext *context;

/**
 The `BBLUser` assigned to this result.
 */
@property (nonatomic, readonly) BBLUser *user;

/**
 The device's time at which the test was taken.
 */
@property (nonatomic, readonly) NSDate *timestamp;

/**
 A percentile score is computed for a given population.
 
 The population in this case is automatically deciphered from the category
 and user properties.
 
 For example, "everyone", "all males", etc. Populations are grouped into
 categories "gender" with bands for "male" and "female". A user is then
 mapped to a particular band based on various criteria
 (survey responses, characteristics, etc).
 
 The possible populations are defined by the "metrics.json" file in the
 resource bundle.
 
 If the result is `nil`, the user cannot be matched to a particular
 population. This would most likely occur because the `user` is missing
 properties required to match a population in the given category. For example,
 if the gender property is missing from the user, then the score for
 the gender category will be `nil`.
 
 Another reason it may be `nil` is if there is not enough data available
 in the population to generate a score.
 
 @param category The population category such as "overall" or "age" to which
                 the score is compared.
 @param error If a score cannot be computed for the given population category
              then the error will contain a `BBLErrorCode` explaining why the
              score is missing.
 */
- (nullable BBLPercentileScore *)scoreForPopulationCategory:(NSString *)category error:(NSError * _Nullable * _Nullable)error;

/**
 A percentile score for a given population.
 
 The possible populations are defined by the "metrics.json" file in the
 resource bundle.
 
 If the result is `nil`, the most likely reason is that there is not enough
 data available in the population to generate a score.
 
 @param populationId A specific population within a category. For example "male".
 @param category The population category to which the `populationId` belongs.
 @param error If a score cannot be computed for the given population and
              category then the error will contain a `BBLErrorCode` explaining
              why the score is missing.
 
 @see `[BBLPsychTestResult scoreForPopulationCategory:error:]`
 */
- (nullable BBLPercentileScore *)scoreForPopulation:(NSString *)populationId inCategory:(NSString *)category error:(NSError * _Nullable * _Nullable)error;

@end

NS_ASSUME_NONNULL_END
