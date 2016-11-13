//
//  FAFDownloadWebImage.m
//  FAFBaseProject
//
//  Created by iecd on 16/2/25.
//  Copyright © 2016年 FastAndFurious. All rights reserved.
//

#import "FAFDownloadWebImage.h"
#import "SDWebImageManager.h"

@implementation FAFDownloadWebImage

+ (void)downloadWithURL:(NSURL *)url
{
    // cmp不能为空
    [[SDWebImageManager sharedManager] downloadImageWithURL:url options:SDWebImageLowPriority|SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        
    }];
}

@end
