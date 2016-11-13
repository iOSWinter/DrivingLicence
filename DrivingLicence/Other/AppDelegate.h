//
//  AppDelegate.h
//  DrivingLicence
//
//  Created by WinterChen on 16/9/14.
//  Copyright © 2016年 win. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) NSString *uniqueID;

+ (NSString *)getIdentifier;

@end

