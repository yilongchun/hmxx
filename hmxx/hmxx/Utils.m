//
//  Util.m
//  hmjz
//
//  Created by yons on 14-10-23.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+ (NSString *)getHostname{
//    //从资源文件获取请求路径
//    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
//    NSMutableDictionary *infolist = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
//    NSString *hostname = [infolist objectForKey:@"Httpurl"];
    return HOST;
}

+ (NSString *)getImageHostname{
    //从资源文件获取请求路径
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    NSMutableDictionary *infolist = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    NSString *hostname = [infolist objectForKey:@"HttpImageurl"];
    return hostname;
}

+ (NSString *)getVideoHostname{
    //从资源文件获取请求路径
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    NSMutableDictionary *infolist = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    NSString *hostname = [infolist objectForKey:@"HttpVideourl"];
    return hostname;
}

+ (BOOL) isBlankString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

@end
