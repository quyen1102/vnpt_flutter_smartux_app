//
//  ICInformationRecognizer.h
//  ICSmartUX
//
//  Created by Minh Nguyễn Minh on 11/05/2023.
//  Copyright © 2023 iOS Team IC - VNPT IT. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ICInformationRecognizer : NSObject

//
+ (NSString *) getActionName:(UIGestureRecognizer *)gestureRecognizer;


@end

NS_ASSUME_NONNULL_END
