//
//  HttpClient.h
//  QcloudDemoApp
//
//  Created by baronjia on 15/10/14.
//  Copyright (c) 2015年 Myjia. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BaseViewController;
@interface HttpClient : NSObject<NSURLConnectionDelegate>


@property (nonatomic,retain) BaseViewController *vc;

@property (nonatomic) SEL callBack;

-(void)getSignWithUrl:(NSString *)s callBack:(SEL)finish;

@end
