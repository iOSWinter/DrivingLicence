//
//  RankCell.m
//  DrivingLicence
//
//  Created by WinterChen on 16/10/9.
//  Copyright © 2016年 win. All rights reserved.
//

#import "RankCell.h"

@interface RankCell ()
@property (weak, nonatomic) IBOutlet UILabel *score;
@property (weak, nonatomic) IBOutlet UILabel *useTime;
@property (weak, nonatomic) IBOutlet UILabel *recordTime;
@property (weak, nonatomic) IBOutlet UILabel *rank;

@end

@implementation RankCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setupData:(NSDictionary *)dict
{
    NSArray *values = [dict.allValues.firstObject componentsSeparatedByString:@" "];
    self.score.text = [values.firstObject stringByAppendingString:@"分"];
    self.useTime.text = values.lastObject;
    NSString *recordTime = dict.allKeys.firstObject;
    NSInteger length = recordTime.length;
    self.recordTime.text = [recordTime substringWithRange:NSMakeRange(length - 20, 17)];
    self.recordTime.adjustsFontSizeToFitWidth = YES;
    if (self.score.text.doubleValue >= 90) {
        self.score.textColor = [UIColor greenColor];
    }
}


@end
