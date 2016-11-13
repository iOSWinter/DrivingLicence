//
//  SpecialCollectionCell.m
//  DrivingLicence
//
//  Created by WinterChen on 16/10/8.
//  Copyright © 2016年 win. All rights reserved.
//

#import "SpecialCollectionCell.h"

@interface SpecialCollectionCell ()

@property (nonatomic, strong) UILabel *sequence;
@property (nonatomic, strong) UILabel *title;

@end

@implementation SpecialCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        UILabel *sequence = [[UILabel alloc] initWithFrame:CGRectMake(20, 8, 24, 24)];
        sequence.layer.cornerRadius = 12;
        sequence.layer.masksToBounds = YES;
        sequence.font = [UIFont systemFontOfSize:14];
        sequence.textColor = [UIColor whiteColor];
        sequence.textAlignment = NSTextAlignmentCenter;
        sequence.backgroundColor = [UIColor colorWithRed:(arc4random_uniform(100) + 120) / 255.0 green:(arc4random_uniform(100) + 120) / 255.0 blue:(arc4random_uniform(100) + 120) / 255.0 alpha:1];
        [self.contentView addSubview:sequence];
        _sequence = sequence;
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(sequence.width + 30, sequence.y, 100, sequence.height)];
        title.font = sequence.font;
        title.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        [self.contentView addSubview:title];
        _title = title;
    }
    return self;
}

- (void)setupSequence:(NSInteger)sequence string:(NSString *)string
{
    self.sequence.text = [NSString stringWithFormat:@"%li", sequence];
    self.title.text = string;
}

@end
