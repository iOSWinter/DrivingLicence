/*
    @file FAFDownloadWebImage.h
    @brief 用于后台下载网络图片的类
//  FAFBaseProject
//
    @author Created by iecd on 16/2/25.
    @copyright Copyright © 2016年 FastAndFurious. All rights reserved.
**/

#import <Foundation/Foundation.h>


/**
 *  网络图片下载类
 @brief 提供一个后台下载图片的方法
 */
@interface FAFDownloadWebImage : NSObject

/**
 *  后台下载图片
 *
 *  @param url 网络图片的地址
 */
+ (void)downloadWithURL:(NSURL *)url;
@end
