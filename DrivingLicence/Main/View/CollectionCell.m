//
//  CollectionCell.m
//  DrivingLicence
//
//  Created by WinterChen on 16/9/17.
//  Copyright © 2016年 win. All rights reserved.
//

#import "CollectionCell.h"

@interface CollectionCell ()


@end

@implementation CollectionCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.title.layer.cornerRadius = 20;
    self.title.layer.masksToBounds = YES;
    self.title.layer.borderWidth = 1;
    self.title.layer.borderColor = [UIColor grayColor].CGColor;
}

@end
