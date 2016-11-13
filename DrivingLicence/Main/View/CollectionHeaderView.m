//
//  CollectionHeaderView.m
//  DrivingLicence
//
//  Created by WinterChen on 16/9/19.
//  Copyright © 2016年 win. All rights reserved.
//

#import "CollectionHeaderView.h"

@implementation CollectionHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, frame.size.width - 15, frame.size.height)];
        title.font = [UIFont systemFontOfSize:14];
        title.textColor = [UIColor grayColor];
        [self addSubview:title];
        _title = title;
        self.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    }
    return self;
}

@end
