//
//  SelectView.m
//  DrivingLicence
//
//  Created by WinterChen on 16/9/16.
//  Copyright © 2016年 win. All rights reserved.
//

#import "SelectView.h"
#import "UIImageView+WebCache.h"

@interface SelectView () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *img;
@property (weak, nonatomic) IBOutlet UILabel *taskMark;
@property (weak, nonatomic) IBOutlet UILabel *question;
@property (weak, nonatomic) IBOutlet UILabel *a;
@property (weak, nonatomic) IBOutlet UILabel *b;
@property (weak, nonatomic) IBOutlet UILabel *c;
@property (weak, nonatomic) IBOutlet UILabel *d;
@property (weak, nonatomic) IBOutlet UIButton *aButton;
@property (weak, nonatomic) IBOutlet UIButton *bButton;
@property (weak, nonatomic) IBOutlet UIButton *cButton;
@property (weak, nonatomic) IBOutlet UIButton *dButton;
@property (weak, nonatomic) IBOutlet UILabel *answer;
@property (weak, nonatomic) IBOutlet UILabel *explain;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmButtonHeightConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgHeightConstaints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *answerSpaceToTopConstraints;

@property (nonatomic, strong) UIImage *unselectedImg;
@property (nonatomic, strong) UIImage *selectedImg;
@property (nonatomic, assign) SubjectType type;
@property (nonatomic, assign) BOOL exam;

@end

@implementation SelectView

+ (instancetype)loadSelectViewWithModel:(SubjectOneModel *)model answerModel:(BOOL)answerModel exam:(BOOL)exam myAnswer:(NSInteger)myAnswer
{
    SelectView *view = [[NSBundle mainBundle] loadNibNamed:@"SelectView" owner:nil options:nil].lastObject;
    view.width = Width;
    view.tag = model.categoryId;
    view.type = model.type;
    view.model = model;
    view.exam = exam;
    
    if (view.type == SubjectTypeSingleSelect || view.type == SubjectTypeJudge) {
        view.unselectedImg = [UIImage imageNamed:@"singleUnselected"];
        view.selectedImg = [UIImage imageNamed:@"singleSelected"];
        view.confirmButtonHeightConstraints.constant = 0;
    } else {
        view.unselectedImg = [UIImage imageNamed:@"checkBoxUnselected"];
        view.selectedImg = [UIImage imageNamed:@"checkBoxSelected"];
        view.confirmButton.layer.cornerRadius = 5;
        view.confirmButton.layer.masksToBounds = YES;
    }
    [view setupAllSelectButtonUnselectedImage];
    
    if ([model.imgUrl containsString:@"http"]) {
        view.imgHeightConstaints.constant = (Width - 40) / 1.5;
        [view.img sd_setImageWithURL:[NSURL URLWithString:model.imgUrl]];
    } else {
        view.imgHeightConstaints.constant = 0;
    }
    [view setupTaskMarkWithModel:model];
    [view setupTypeStringWithModel:model];
    view.a.text = [@"A. " stringByAppendingString:model.a];
    view.b.text = [@"B. " stringByAppendingString:model.b];
    if (view.type == SubjectTypeSingleSelect || view.type == SubjectTypeMultiSelect) {
        view.c.text = [@"C. " stringByAppendingString:model.c];
        view.d.text = [@"D. " stringByAppendingString:model.d];
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            view.answerSpaceToTopConstraints.constant = -50;
        });
        view.cButton.enabled = NO;
        view.dButton.enabled = NO;
    }
    if (myAnswer > 0) {
        [view setupAllButtonEnable:NO];
        [view showAnswerViewWithResult:YES answerModel:NO];
        switch (myAnswer) {
            case 1:
                [view.aButton setImage:view.selectedImg forState:UIControlStateNormal];
                break;
            case 2:
                [view.bButton setImage:view.selectedImg forState:UIControlStateNormal];
                break;
            case 3:
                [view.cButton setImage:view.selectedImg forState:UIControlStateNormal];
                break;
            case 40:
                [view.dButton setImage:view.selectedImg forState:UIControlStateNormal];
                break;
                
            default:
                break;
        }
    }
    
    if (!answerModel) {
        [view setupAllButtonEnable:NO];
        [view showAnswerViewWithResult:YES answerModel:answerModel];
    }
    
    return view;
}

- (void)showAnswerViewWithAnswerModel:(BOOL)answerModel
{
    // answerModel = YES 答题模式
    if (!self.exam) {
        
        [self showAnswerViewWithResult:YES answerModel:answerModel];
    }
}

- (void)setupTypeStringWithModel:(SubjectOneModel *)model
{
    NSString *typeString = model.type == SubjectTypeJudge ? @"[判断题]  " : (model.type == SubjectTypeSingleSelect ? @"[单选题]  " : @"[多选题]  ");
    NSString *textString = [typeString stringByAppendingString:model.question];
    NSMutableAttributedString *attrs = [[NSMutableAttributedString alloc] initWithString:textString];
    [attrs setAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12], NSForegroundColorAttributeName : [UIColor colorWithRed:0.2 green:0.6 blue:0.3 alpha:1]} range:NSMakeRange(0, typeString.length)];
    [attrs setAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:19], NSForegroundColorAttributeName : [UIColor blackColor]} range:NSMakeRange(typeString.length, model.question.length)];
    self.question.attributedText = attrs;
}

- (void)setupTaskMarkWithModel:(SubjectOneModel *)model
{
    if (self.exam) {
        self.taskMark.text = nil;
        return;
    }
    if (model.result != ResultTypeDefault) {
        self.taskMark.text = @"已作答";
        if (model.result == ResultTypeRight) {
            self.taskMark.textColor = [UIColor colorWithRed:0.2 green:0.6 blue:0.3 alpha:1];
        } else {
            self.taskMark.textColor = [UIColor redColor];
        }
    }
}

- (void)showAnswerViewWithResult:(BOOL)right answerModel:(BOOL)answerModel
{
    [self setupAllSelectButtonUnselectedImage];
    if (answerModel) {
        self.answer.text = nil;
        self.explain.text = nil;
        [self setupAllButtonEnable:YES];
    } else {
        [self getbackAnswerWithModel:self.model result:right answerModel:answerModel];
        self.explain.text = self.model.explainText;
        [self setupAllButtonEnable:NO];
    }
}

- (void)getbackAnswerWithModel:(SubjectOneModel *)model result:(BOOL)right answerModel:(BOOL)answerModel
{
    NSString *answerString = model.answer;
    NSString *rightAnswer = nil;
    if (answerModel) {
        rightAnswer = [right ? @"回答正确   " : @"回答错误   " stringByAppendingString:@"正确答案: "];
    } else {
        rightAnswer = @"正确答案: ";
    }
    
    for (NSInteger i = 0; i < answerString.length; i++) {
        NSString *separate = @"";
        if (i < (answerString.length - 1)) {
            separate = @"、";
        }
        NSString *answerVal = [answerString substringWithRange:NSMakeRange(i, 1)];
        rightAnswer = [rightAnswer stringByAppendingFormat:@"%@%@", [self getbackAnswerWithAnswerValue:answerVal.integerValue], separate];
    }
    self.answer.text = rightAnswer;
    UIColor *color = right ? [UIColor colorWithRed:0 green:128 / 255.0 blue:64 / 255.0 alpha:1] : [UIColor redColor];
    self.answer.textColor = color;
}

- (NSString *)getbackAnswerWithAnswerValue:(NSInteger)val
{
    switch (val) {
        case 1:
            return @"A";
            break;
        case 2:
            return @"B";
            break;
        case 3:
            return @"C";
            break;
        case 4:
            return @"D";
            break;
    }
    return nil;
}

- (void)setupAllSelectButtonUnselectedImage
{
    [self setupButtonUnselectedImage:self.aButton];
    [self setupButtonUnselectedImage:self.bButton];
    if (self.type == SubjectTypeSingleSelect || self.type == SubjectTypeMultiSelect) {
        [self setupButtonUnselectedImage:self.cButton];
        [self setupButtonUnselectedImage:self.dButton];
    }
}

- (void)setupButtonUnselectedImage:(UIButton *)button
{
    [button setImage:self.unselectedImg forState:UIControlStateNormal];
}

- (IBAction)selectButtonClick:(UIButton *)sender
{
    if (self.type == SubjectTypeSingleSelect || self.type == SubjectTypeJudge) { // 单项选择
        if (self.exam) {
            
            [self setupAllButtonEnable:NO];
        } else {
            
            [self setupAllSelectButtonUnselectedImage];
        }
        [sender setImage:self.selectedImg forState:UIControlStateNormal];
        BOOL right = sender.tag == self.model.answer.integerValue ? YES : NO;
        self.model.result = right ? ResultTypeRight : -1;
        [self getbackAnswerWithModel:self.model result:right answerModel:YES];
        self.explain.text = self.model.explainText;
        [self setupTaskMarkWithModel:self.model];
        if ([self.delegate respondsToSelector:@selector(selectRightAnswer:myAnswer:)]) {
            [self.delegate selectRightAnswer:right myAnswer:sender.tag];
        }
    } else { // 多项选择
        sender.tag += (sender.tag  > 10 ? -10 : 10);
        if (sender.tag > 10) {
            [sender setImage:self.selectedImg forState:UIControlStateNormal];
        } else {
            [sender setImage:self.unselectedImg forState:UIControlStateNormal];
        }
    }
}

- (IBAction)confirmButtonClick:(id)sender
{
    NSString *answer = @"";
    answer = [answer stringByAppendingString:[self judgeSelectedWihtButton:self.aButton] ? @"1" : @""];
    answer = [answer stringByAppendingString:[self judgeSelectedWihtButton:self.bButton] ? @"2" : @""];
    answer = [answer stringByAppendingString:[self judgeSelectedWihtButton:self.cButton] ? @"3" : @""];
    answer = [answer stringByAppendingString:[self judgeSelectedWihtButton:self.dButton] ? @"4" : @""];
    
    if (self.exam) {
        
        [self setupAllButtonEnable:NO];
    } else {
        
        [self setupAllSelectButtonUnselectedImage];
    }
    BOOL right = answer.integerValue == self.model.answer.integerValue ? YES : NO;
    self.model.result = right ? ResultTypeRight : -1;
    [self getbackAnswerWithModel:self.model result:right answerModel:YES];
    self.explain.text = self.model.explainText;
    [self setupTaskMarkWithModel:self.model];
    if ([self.delegate respondsToSelector:@selector(selectRightAnswer:myAnswer:)]) {
        [self.delegate selectRightAnswer:right myAnswer:answer.integerValue];
    }
    self.hidden = YES;
}

- (BOOL)judgeSelectedWihtButton:(UIButton *)btn
{
    return btn.tag > 10;
}

- (void)setupAllButtonEnable:(BOOL)enable
{
    self.aButton.enabled = enable;
    self.bButton.enabled = enable;
    self.cButton.enabled = enable;
    self.dButton.enabled = enable;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(didScrollView)]) {
        [self.delegate didScrollView];
    }
}

@end
