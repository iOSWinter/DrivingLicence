//
//  ExamViewController.m
//  DrivingLicence
//
//  Created by WinterChen on 16/9/22.
//  Copyright © 2016年 win. All rights reserved.
//

#import "ExamViewController.h"
#import "SubjectViewController.h"

@interface ExamViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgHeightConstraints;
@property (weak, nonatomic) IBOutlet UILabel *time;

@end

@implementation ExamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        self.imgHeightConstraints.constant = (Width - 60) / 1.8;
    });
    
    if (self.type == CategoryTypeSubjectFour) {
        self.time.text = @"30分钟";
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    SubjectViewController *vc = segue.destinationViewController;
    vc.tag = self.type == CategoryTypeSubjectOne ? 7 : 15;
    vc.title = vc.tag == 7 ? @"科目一考试剩余 45:00" : @"科目四考试剩余 30:00";
    vc.type = self.type;
}

@end
