//
//  SubjectViewController.h
//  DrivingLicence
//
//  Created by WinterChen on 16/9/14.
//  Copyright © 2016年 win. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubjectViewController : UIViewController

@property (nonatomic, assign) CategoryType type;

@property (nonatomic, assign) NSInteger tag;

@property (nonatomic, assign) FetchType fetchType;

@property (nonatomic, assign) SubjectType subjectType;

@property (nonatomic, strong) NSString *keyword;

@end
