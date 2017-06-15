//
//  QCloudUtils.m
//  QCloudDemo
//
//  Created by Tencent on 3/26/15.
//  Copyright (c) 2015 Tencent. All rights reserved.
//

#import "QCloudUtils.h"

@implementation QCloudUtils



+ (NSString *)findUUID:(NSString *)path
{
    if (path.length == 0) {
        return [QCloudUtils uuid];
    }
    int begin = 0;
    int end = 0;
    int i = 0;
    const char * p = [path UTF8String];
    while (*p!='\0') {
        if (*p == '=')
        {
            if (begin == 0) {
                begin = i+1;
            }
        }
        if (*p == '&') {
            if (end == 0)
            {
                end = i;
                break;
            }
        }
        i++;
        p++;
    }
    NSString * uuid = [path substringWithRange:NSMakeRange(begin, end - begin)];
    return  uuid;
}

+ (NSString *)uuid
{
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef strUuid = CFUUIDCreateString(kCFAllocatorDefault,uuid);
    NSString * str = [NSString stringWithString:(__bridge NSString *)strUuid];
    CFRelease(strUuid);
    CFRelease(uuid);
    return  str;
}

+ (void)showMBTips:(NSString *)tips inView:(UIView *)view
{
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
//    // Configure for text only and offset down
//    hud.mode = MBProgressHUDModeText;
//    hud.labelText = tips;
//    hud.margin = 30.f;
//    hud.removeFromSuperViewOnHide = YES;
//    
//    [hud hide:YES afterDelay:1.0f];
}

// 从path中获取文件名
+ (NSString*)getPathFileName:(NSString*)path
{
    NSRange range = [path rangeOfString:@"/" options:NSBackwardsSearch];
    if (range.location == NSNotFound) {
        return path;
    }
    
    range.location += 1;
    range.length = path.length - range.location;
    return [path substringWithRange:range];
}


@end
