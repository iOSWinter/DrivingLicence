//
//  SelectView.h
//  DrivingLicence
//
//  Created by WinterChen on 16/9/16.
//  Copyright © 2016年 win. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectViewDelegate <NSObject>

@optional
- (void)selectRightAnswer:(BOOL)right myAnswer:(NSInteger)myAnswer;
- (void)didScrollView;

@end

@interface SelectView : UIView

@property (nonatomic, weak) id<SelectViewDelegate> delegate;
@property (nonatomic, strong) SubjectOneModel *model;

+ (instancetype)loadSelectViewWithModel:(SubjectOneModel *)model answerModel:(BOOL)answerModel exam:(BOOL)exam myAnswer:(NSInteger)myAnswer;

- (void)showAnswerViewWithAnswerModel:(BOOL)answerModel;

@end
