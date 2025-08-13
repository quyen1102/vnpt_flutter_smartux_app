//
//  ICRequestService.h
//  ICSmartUX
//
//  Created by Minh Nguyễn Minh on 03/01/2023.
//  Copyright © 2023 iOS Team IC - VNPT IT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


# pragma mark - OnLoad/OnError Block
typedef void (^OnSuccessBlock)(NSDictionary* value);
typedef void (^OnFailureBlock)(NSError* error);


@interface ICRequestService : NSObject

+ (void) sendRequestUploadImageData:(NSData *)data
                                url:(NSString *)url
                             appKey:(NSString *)appKey
                           deviceId:(NSString *)deviceId
                           deviceOs:(NSString *)deviceOs
                    deviceModelName:(NSString *)deviceModelName
                        vcClassName:(NSString *)vcClassName
                             screen:(CGSize)screen
                          timestamp:(NSInteger)timestamp
                          onSuccess:(OnSuccessBlock )onSuccess
                          onFailure:(OnFailureBlock)onFailure;

// url: String, appKey: String, deviceId: String, deviceOs: String, deviceModelName: String, screen: CGSize
+ (void) sendRequestUploadEventWithSelectorEvents:(NSArray *)selector_events
                  multiTouches:(NSArray *)multi_touches
                            url:(NSString *)url
                         appKey:(NSString *)appKey
                       deviceId:(NSString *)deviceId
                       deviceOs:(NSString *)deviceOs
                deviceModelName:(NSString *)deviceModelName
                         screen:(CGSize)screen
                      onSuccess:(OnSuccessBlock )onSuccess
                      onFailure:(OnFailureBlock)onFailure;

+ (void) sendRequestUploadUserFlow:(NSString *)domain
                            appKey:(NSString *)appKey
                          deviceId:(NSString *)deviceId
                           metrics:(NSString *)metrics
                              view:(NSString *)view
                              from:(NSString *)from
                         timestamp:(NSInteger)timestamp
                         onSuccess:(OnSuccessBlock)onSuccess
                         onFailure:(OnFailureBlock)onFailure;

+ (void) sendRequestGetSurveyConfig:(NSString *)url 
                          onSuccess:(OnSuccessBlock )onSuccess
                          onFailure:(OnFailureBlock)onFailure;

+ (void) sendRequestSubmitSurvey:(NSString *)url
                          appKey:(NSString *)appKey
                        surveyId:(NSString *)surveyId
                        deviceId:(NSString *)deviceId
                        platform:(NSString *)platform
                       timestamp:(NSInteger)timestamp
                            path:(NSString *)path
                         answers:(NSArray *)answers
                       onSuccess:(OnSuccessBlock )onSuccess
                       onFailure:(OnFailureBlock)onFailure;

+ (void) sendRequestPostUserData:(NSString *)url
                          appKey:(NSString *)appKey
                          userId:(NSString *)userId
                        deviceId:(NSString *)deviceId
                        platform:(NSString *)platform
                       timestamp:(NSInteger)timestamp
                        userData:(NSDictionary *)userData
                      versionSDK:(NSString *)versionSDK
                       onSuccess:(OnSuccessBlock )onSuccess
                       onFailure:(OnFailureBlock)onFailure;

+ (void) sendRequestPostUserFlow:(NSString *)url
                      userFlowId:(NSString *)userFlowId
                          appKey:(NSString *)appKey
                        deviceId:(NSString *)deviceId
                        platform:(NSString *)platform
                         startTs:(NSInteger)startTs
                           endTs:(NSInteger)endTs
                            flow:(NSArray *)flow
                         referer:(NSString *)referer
                          domain:(NSString *)domain
                       userAgent:(NSString *)userAgent
                      versionSDK:(NSString *)versionSDK
                       onSuccess:(OnSuccessBlock )onSuccess
                       onFailure:(OnFailureBlock)onFailure;


+ (void) sendRequestGeneral:(NSString *)url
                    headers:(NSDictionary *)headers
                     method:(NSString *)method
                    payload:(NSDictionary *)payload
                  onSuccess:(OnSuccessBlock )onSuccess
                  onFailure:(OnFailureBlock)onFailure;

@end

NS_ASSUME_NONNULL_END
