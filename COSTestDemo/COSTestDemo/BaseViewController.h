//
//  BaseViewController.h
//  QcloudDemoApp
//
//  Created by baronjia on 15/10/14.
//  Copyright (c) 2015年 Myjia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpClient.h"

@interface BaseViewController : UIViewController

@property (nonatomic,strong) HttpClient *client;

-(void)getSignFinish:(NSString *)string;

-(void)getOneSignFinish:(NSString *)string;

-(void)showHUDWithText:(NSString *)t detailsLabelText:(NSString *)d;

-(void)showHUDLongWithText:(NSString *)t detailsLabelText:(NSString *)d;

-(NSString*)convertToLocalTime:(NSUInteger)unixTime;

- (void)drawBorderWithButton:(UILabel *)lable ;

-(void)showLoadingWithView:(UIView *)v;
-(void)hiddenLoadingWihtView:(UIView *)v;


@end
