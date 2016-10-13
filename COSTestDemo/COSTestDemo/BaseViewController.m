//
//  BaseViewController.m
//  QcloudDemoApp
//
//  Created by baronjia on 15/10/14.
//  Copyright (c) 2015年 Myjia. All rights reserved.
//

#import "BaseViewController.h"

@implementation BaseViewController


-(void)showHUDWithText:(NSString *)t detailsLabelText:(NSString *)d
{
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    hud.mode = MBProgressHUDModeText;
//    hud.labelText =t;
//    if (d) hud.detailsLabelText = d;
//    hud.margin = 10.f;
//    hud.yOffset = 150.f;
//    hud.removeFromSuperViewOnHide = YES;
//    [hud hide:YES afterDelay:1.0f];
}

-(void)showHUDLongWithText:(NSString *)t detailsLabelText:(NSString *)d
{
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    hud.mode = MBProgressHUDModeText;
//    hud.labelText =t;
//    if (d) hud.detailsLabelText = d;
//    hud.margin = 10.f;
//    hud.yOffset = 150.f;
//    hud.removeFromSuperViewOnHide = YES;
//    [hud hide:YES afterDelay:3.0f];
}

-(NSString*)convertToLocalTime:(NSUInteger)unixTime
{
    NSTimeInterval _interval=unixTime;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    NSDateFormatter *formatter= [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    //[formatter setDateFormat:@"dd.MM.yyyy"];
    [formatter setDateFormat:@"yyyy.MM.dd"];
    return [formatter stringFromDate:date];
}

- (void)drawBorderWithButton:(UIView *)view {
    
    CALayer * downButtonLayer = [view layer];
    [downButtonLayer setMasksToBounds:YES];
    [downButtonLayer setBorderWidth:1.0];
    [downButtonLayer setBorderColor:[[UIColor grayColor] CGColor]];
}

-(void)showLoadingWithView:(UIView *)v
{
//    _loadingView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    _loadingView.mode = MBProgressHUDModeIndeterminate;
//
////    _loadingView.margin = 10.f;
////    _loadingView.yOffset = 150.f;
//    _loadingView.removeFromSuperViewOnHide = YES;
//    [_loadingView show:YES];
}

-(void)hiddenLoadingWihtView:(UIView *)v
{
    //[MBProgressHUD hideAllHUDsForView:v animated:YES];
}


@end
