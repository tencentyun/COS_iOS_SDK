//
//  QCloudUtils.h
//  QCloudDemo
//
//  Created by Tencent on 3/26/15.
//  Copyright (c) 2015 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define DECLARE_WEAK_SELF __typeof(&*self) __weak weakSelf = self
#define DECLARE_STRONG_SELF __typeof(&*self) __strong strongSelf = weakSelf

#define  kScreenWidth   ([UIScreen mainScreen].bounds.size.width)
#define  kScreenHeight  ([UIScreen mainScreen].bounds.size.height)

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

@interface QCloudUtils : NSObject

+ (NSString *)findUUID:(NSString *)path;
+ (NSString *)uuid;

+ (void)showMBTips:(NSString *)tips inView:(UIView *)view;

+ (NSString*)getPathFileName:(NSString*)path;

@end
