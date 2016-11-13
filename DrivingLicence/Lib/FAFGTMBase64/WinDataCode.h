//
//  SecurityUtil.h
//  Smile
//
//  Created by 蒲晓涛 on 12-11-24.
//  Copyright (c) 2012年 BOX. All rights reserved.
//

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com

#import <Foundation/Foundation.h>
#import "GTMDefines.h"
#import "GTMBase64.h"
#import "NSData+AES.h"
#import "NSData+Hash.h"
#import "NSString+Hash.h"

@interface WinDataCode : NSObject

#pragma mark - base64
+ (NSString*)win_EncodeBase64String:(NSString *)input;
+ (NSString*)win_DecodeBase64String:(NSString *)input;

+ (NSString*)win_EncodeBase64Data:(NSData *)data;
+ (NSString*)win_DecodeBase64Data:(NSData *)data;

#pragma mark - AES加密
//将string转成带密码的data
+ (NSString*)win_EncryptAESData:(NSString*)string app_key:(NSString*)key ;
//将带密码的data转成string
+(NSString*)win_DecryptAESData:(NSData*)data app_key:(NSString*)key ;


@end
