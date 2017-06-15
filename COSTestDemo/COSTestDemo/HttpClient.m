//
//  HttpClient.m
//  QcloudDemoApp
//
//  Created by baronjia on 15/10/14.
//  Copyright (c) 2015年 Myjia. All rights reserved.
//

#import "HttpClient.h"
#import "BaseViewController.h"

@interface HttpClient ()


@property (nonatomic,strong) NSMutableData *dataSign;
@property (nonatomic,copy) NSString *sign;

@end

@implementation HttpClient

#pragma mark －network

-(void)getSignWithUrl:(NSString *)s callBack:(SEL)finish
{
    _dataSign = [NSMutableData new];
    _callBack = finish;
    NSURL *url =  [NSURL URLWithString:s ];//请求的地址请更换成自己业务服务器的地址
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url
                                                 cachePolicy:NSURLRequestUseProtocolCachePolicy
                                             timeoutInterval:10];
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    [connection start];
}

#pragma mark - NSURLConnectionDataDelegate
#pragma mark 接收到服务器返回的数据时调用（如果数据比较多，这个方法可能会被调用多次）

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.dataSign appendData:data];
}

#pragma mark 网络连接出错时调用
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"网络连接出错:%@", [error localizedDescription]);
}

#pragma mark 服务器的数据已经接收完毕时调用
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // 解析成字符串数据
    self.sign= nil;
    NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:_dataSign options:kNilOptions error:nil];
    
    _sign = [responseDic objectForKey:@"sign"] ;
    
    //_sign = [[responseDic objectForKey:@"data"] objectForKey:@"sign"] ;
    
    [_vc performSelector:_callBack withObject:_sign];
}

@end
