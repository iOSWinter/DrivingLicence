//
//  NSString+MJExtension.h
//  MJExtensionExample
//
//  Created by MJ Lee on 15/6/7.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJExtensionConst.h"

@interface NSString (MJExtension)
/**
 *  驼峰转下划线（loveYou -> love_you）
 */
- (NSString *)faf_underlineFromCamel;
/**
 *  下划线转驼峰（love_you -> loveYou）
 */
- (NSString *)faf_camelFromUnderline;
/**
 * 首字母变大写
 */
- (NSString *)faf_firstCharUpper;
/**
 * 首字母变小写
 */
- (NSString *)faf_firstCharLower;

- (BOOL)faf_isPureInt;

- (NSURL *)faf_url;
@end

@interface NSString (MJExtensionDeprecated_v_2_5_16)
- (NSString *)underlineFromCamel MJExtensionDeprecated("请在方法名前面加上faf_前缀，使用faf_***");
- (NSString *)camelFromUnderline MJExtensionDeprecated("请在方法名前面加上faf_前缀，使用faf_***");
- (NSString *)firstCharUpper MJExtensionDeprecated("请在方法名前面加上faf_前缀，使用faf_***");
- (NSString *)firstCharLower MJExtensionDeprecated("请在方法名前面加上faf_前缀，使用faf_***");
- (BOOL)isPureInt MJExtensionDeprecated("请在方法名前面加上faf_前缀，使用faf_***");
- (NSURL *)url MJExtensionDeprecated("请在方法名前面加上faf_前缀，使用faf_***");
@end
