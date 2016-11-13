//
//  SubjectViewController.m
//  DrivingLicence
//
//  Created by WinterChen on 16/9/14.
//  Copyright © 2016年 win. All rights reserved.
//

#import "SubjectViewController.h"
#import "UIImageView+WebCache.h"
#import "CollectionCell.h"
#import "CollectionHeaderView.h"
#import "SelectView.h"
#import "WinCollectionViewLayout.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface SubjectViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SelectViewDelegate, UIAlertViewDelegate, GADBannerViewDelegate>

@property (weak, nonatomic) IBOutlet GADBannerView *adView;

@property (weak, nonatomic) IBOutlet UIView *toolBar;
@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *preferItem;


@property (nonatomic, strong) UIView *lastView;
@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UIView *nextView;
@property (nonatomic, strong) UILabel *errorMark;
@property (nonatomic, strong) UILabel *correctMark;
@property (nonatomic, strong) UILabel *rightRate;
@property (nonatomic, strong) UIControl *control;
@property (nonatomic, strong) UILabel *currentIndex;
@property (nonatomic, strong) UIButton *showButton;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UISwitch *autoSwitch;
@property (weak, nonatomic) IBOutlet UILabel *duration;
@property (weak, nonatomic) IBOutlet UISlider *slider;

@property (nonatomic, strong) UIView *movingView;
@property (nonatomic, assign) CGFloat movingViewOriginalX;
@property (nonatomic, assign) BOOL successSwitchView;
@property (nonatomic, assign) NSInteger currentMainViewSequence;
@property (nonatomic, assign) NSInteger totalCount;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *rightArray;
@property (nonatomic, strong) NSMutableArray *errorArray;
@property (nonatomic, strong) NSString *cachesPath;
@property (nonatomic, strong) NSString *examPath;
@property (nonatomic, strong) NSMutableDictionary *cachesDict;
@property (nonatomic, strong) NSMutableDictionary *answerDict;
@property (nonatomic, strong) NSMutableArray *examErrorArray;
@property (nonatomic, strong) NSTimer *timer;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *adViewSpaceToBottomViewConstraints;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewHeightConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuViewSpaceToTopConstraints;

@end

@implementation SubjectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.collectionView registerClass:[CollectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"collectionViewHeader"];        
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backIcon"] style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    _cachesDict = [NSMutableDictionary dictionaryWithContentsOfFile:self.cachesPath];
    NSNumber *lastSelectedIndex = self.cachesDict[@"model"];
    self.segmentControl.selectedSegmentIndex = lastSelectedIndex.integerValue;
    if ([self.cachesDict.allKeys containsObject:@"autoSwitch"]) {
        NSNumber *autoSwitchOn = self.cachesDict[@"autoSwitch"];
        self.autoSwitch.on = autoSwitchOn.boolValue;
    }
    [self setupBottomView];
    NSNumber *duration = self.cachesDict[@"duration"];
    if (duration) {
        self.duration.text = [NSString stringWithFormat:@"%0.2f", duration.floatValue];
        self.slider.value = duration.floatValue;
    }
    if (self.tag == 7 || self.tag == 15) {
        self.dataArray = [SubjectDataBaseTool generateExaminationPageWithCategoryType:self.type];
        self.totalCount = self.tag == 7 ? 100 : 50;
        self.preferItem.title = @"交卷";
        self.preferItem.image = nil;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(setupTitle:) userInfo:[NSDate dateWithTimeIntervalSinceNow:(self.tag == 7 ? 45 : 30) * 60] repeats:YES];
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"] style:UIBarButtonItemStyleDone target:self action:@selector(menuItemClick:)];
        if (!(self.tag == 5 || self.tag == 13)) {
            // 非专题练习
            self.dataArray = [SubjectDataBaseTool searchDataListArrayWithCategoryType:self.type fetchType:self.fetchType];
            self.totalCount = [SubjectDataBaseTool searchTotalCountWithCategoryType:self.type fetchType:self.fetchType];
        } else {
            // 专题练习
            self.dataArray = [SubjectDataBaseTool searchDataListArrayWithCategoryType:self.type subjectType:self.subjectType keyWord:self.keyword];
            self.totalCount = [SubjectDataBaseTool searchTotalCountWithCategoryType:self.type subjectType:self.subjectType keyWord:self.keyword];
        }
    }
    [self setupViews];
    [self addDragGesture];
    [self updateResult];
    
    [self setupBannerView];
    
    NSArray *keyValue = ((NSDictionary *)self.dataArray.firstObject).allValues.firstObject;
    NSInteger sequence = ((NSNumber *)((NSDictionary *)keyValue.firstObject).allValues.firstObject).integerValue;
    NSInteger lastMainViewSequence;
    if (self.tag == 1) {
        if (self.cachesDict[[NSString stringWithFormat:@"%ld", self.type]]) {
            lastMainViewSequence = ((NSNumber *)self.cachesDict[[NSString stringWithFormat:@"%ld", self.type]]).integerValue;
        } else {
            lastMainViewSequence = sequence;
        }
    } else if (self.tag == 3 || self.tag == 11) {
      lastMainViewSequence = [self getbackRandomSequence];
    } else {
        lastMainViewSequence = sequence;
    }
    self.currentMainViewSequence = lastMainViewSequence;
    [self loadDataWithMainViewModelSequence:self.currentMainViewSequence];
    
    self.lastView.hidden = YES;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.lastView.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.lastView.hidden = YES;
}

- (void)setupBannerView
{
    self.adView.adUnitID = AdMobBannerID;
    self.adView.rootViewController = self;
    self.adView.delegate = self;
    GADRequest *request = [GADRequest request];
    [self.adView loadRequest:request];    
    
    __weak SubjectViewController *weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.adViewSpaceToBottomViewConstraints.constant = -100;
        
    });
}

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView
{
    __weak SubjectViewController *weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.adViewSpaceToBottomViewConstraints.constant = 0;
            [weakSelf.view layoutIfNeeded];
        }];
        
    });
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error
{
    __weak SubjectViewController *weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.adViewSpaceToBottomViewConstraints.constant = -100;
            [weakSelf.view layoutIfNeeded];
        }];
        
    });
}

- (void)back
{
    if (self.tag == 7 || self.tag == 15) {
        [[[UIAlertView alloc] initWithTitle:@"考试提示" message:@"考试进行中,想要放弃本次考试么??" delegate:self cancelButtonTitle:nil otherButtonTitles:@"放弃", @"取消", nil] show];
    } else {
        [self.cachesDict writeToFile:self.cachesPath atomically:YES];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)setupTitle:(NSTimer *)timer
{
    NSDate *dueDate = timer.userInfo;
    NSTimeInterval interval = [dueDate timeIntervalSinceDate:[NSDate date]];
    
    if (interval > 0) {
        
        NSInteger minute = interval / 60;
        NSInteger second = interval - minute * 60;
        NSString *minuteString = [NSString stringWithFormat:minute < 10 ? @"0%ld" : @"%ld", minute];
        NSString *secondString = [NSString stringWithFormat:second < 10 ? @"0%ld" : @"%ld", second];
        self.title = [NSString stringWithFormat:@"%@ %@:%@", [self.title componentsSeparatedByString:@" "].firstObject, minuteString, secondString];
    } else {
        [timer invalidate];
        [[[UIAlertView alloc] initWithTitle:nil message:@"你已用完所有考生时间,系统已自动提交试卷!" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil] show];
    }
}

- (void)loadDataWithMainViewModelSequence:(NSInteger)sequence
{
    if (self.tag == 3 || self.tag == 11) {
        // 随机练习
        [self prepareView:self.lastView requestSequence:[self getbackRandomSequence]];
        [self prepareView:self.mainView requestSequence:sequence];
        [self prepareView:self.nextView requestSequence:[self getbackRandomSequence]];
    } else if (self.tag == 1 || self.tag == 9) {
        // 顺序练习
        [self prepareView:self.lastView requestSequence:sequence - 1];
        [self prepareView:self.mainView requestSequence:sequence];
        [self prepareView:self.nextView requestSequence:sequence + 1];
    } else {
        for (NSInteger i = 0; i < self.dataArray.count; i++) {
            NSDictionary *dict = self.dataArray[i];
            NSArray *array = dict.allValues.firstObject;
            BOOL end = NO;
            for (NSInteger j = 0; j < array.count; j++) {
                NSDictionary *dic = array[j];
                NSNumber *contentSequence = dic.allValues.firstObject;
                if (contentSequence.integerValue == sequence) {
                    NSInteger lastSequence;
                    NSInteger nextSequence;
                    if (j == 0) {
                        // 当前分类数组的第一个元素
                        if (i > 0) {
                            // 非第一个分类数组
                            NSDictionary *dict = self.dataArray[i - 1];
                            NSArray *array = dict.allValues.firstObject;
                            NSDictionary *dic = array.lastObject;
                            NSNumber *last = dic.allValues.firstObject;
                            lastSequence = last.integerValue;
                        } else {
                            lastSequence = 100000;
                        }
                        if (array.count > 1) {
                            // 当前分类所包含的数组元素个数大于1个
                            NSDictionary *dic = array[j + 1];
                            NSNumber *next = dic.allValues.firstObject;
                            nextSequence = next.integerValue;
                        } else if (i < (self.dataArray.count - 1)) {
                            // 当前数组不是dataArray数组的最后一个分类
                            NSDictionary *dict = self.dataArray[i + 1];
                            NSArray *array = dict.allValues.firstObject;
                            NSDictionary *dic = array.firstObject;
                            NSNumber *next = dic.allValues.firstObject;
                            nextSequence = next.integerValue;
                        }
                    } else if (j == (array.count - 1)) {
                        // 当前分类数组中最后一个元素
                        if (i < (self.dataArray.count - 1)) {
                            // 当前分类数组不是dataArray的最后一个分类
                            NSDictionary *dict = self.dataArray[i + 1];
                            NSArray *array = dict.allValues.firstObject;
                            NSDictionary *dic = array.firstObject;
                            NSNumber *next = dic.allValues.firstObject;
                            nextSequence = next.integerValue;
                        } else {
                            nextSequence = 100000;
                        }
                        if (array.count > 1) {
                            NSDictionary *dic = array[j - 1];
                            NSNumber *last = dic.allValues.firstObject;
                            lastSequence = last.integerValue;
                        } else if (i > 0) {
                            NSDictionary *dict = self.dataArray[i - 1];
                            NSArray *array = dict.allValues.lastObject;
                            NSDictionary *dic = array[j - 1];
                            NSNumber *last = dic.allValues.firstObject;
                            lastSequence = last.integerValue;
                        }
                    } else {
                        // 当前sequence在当前分类数组的中间
                        NSDictionary *lastDic = array[j - 1];
                        NSDictionary *nextDic = array[j + 1];
                        NSNumber *last = lastDic.allValues.firstObject;
                        NSNumber *next = nextDic.allValues.firstObject;
                        lastSequence = last.integerValue;
                        nextSequence = next.integerValue;
                    }
                    [self prepareView:self.lastView requestSequence:lastSequence];
                    [self prepareView:self.mainView requestSequence:sequence];
                    [self prepareView:self.nextView requestSequence:nextSequence];
                    end = YES;
                    break;
                }
            }
            if (end) {
                break;
            }
        }
    }
    self.currentMainViewSequence = sequence;
    [self updateSummaryDataWithSequence:sequence];
}

- (void)setupBottomView
{
    if (!(self.tag == 7 || self.tag == 15)) {
        
        self.preferItem.image = [UIImage imageNamed:@"collect"];
    }
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(55, 3, Width - 60, 44)];
    [self.toolBar addSubview:rightView];
    if (self.tag % 2 == 1) {
        self.errorMark = [self createSummaryViewOnView:rightView iconX:0 iconImage:[UIImage imageNamed:@"error"] textColor:[UIColor colorWithRed:244 / 255.0 green:110 / 255.0 blue:104 / 255.0 alpha:1]];
        self.correctMark = [self createSummaryViewOnView:rightView iconX:60 iconImage:[UIImage imageNamed:@"correct"] textColor:[UIColor colorWithRed:26 / 255.0 green:200 / 255.0 blue:46 * 255.0 alpha:1]];
        self.rightRate = [self createSummaryViewOnView:rightView iconX:100 iconImage:nil textColor:[UIColor purpleColor]];
    } else {
        self.progress.hidden = YES;
    }
    self.currentIndex = [self createSummaryViewOnView:rightView iconX:(rightView.width - 90) iconImage:[UIImage imageNamed:@"selectSubject"] textColor:[UIColor blackColor]];
    UIButton *backTopButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    backTopButton.frame = CGRectMake(0, 0, self.rightRate.centerX ?: 200, rightView.height);
    [rightView addSubview:backTopButton];
    [backTopButton addTarget:self action:@selector(backTopButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *showButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    showButton.frame = CGRectMake(backTopButton.width, 0, rightView.width - backTopButton.width, rightView.height);
    showButton.tag = 1;
    [rightView addSubview:showButton];
    _showButton = showButton;
    [showButton addTarget:self action:@selector(showButtonClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)showButtonClick:(UIButton *)showButton
{
    if (self.navigationItem.rightBarButtonItem.tag) {
        [self menuItemClick:self.navigationItem.rightBarButtonItem];
    }
    __weak SubjectViewController *weakSelf = self;
    [UIView animateWithDuration:0.35 animations:^{
        weakSelf.bottomViewHeightConstraints.constant = showButton.tag == 0 ? 47 : Height * 0.7;
        if (showButton.tag == 0) {
            [weakSelf.control removeFromSuperview];
            weakSelf.control = nil;
            weakSelf.progress.trackTintColor = [UIColor whiteColor];
        } else {
            [weakSelf showCoverView];
            weakSelf.progress.trackTintColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        }
        [weakSelf.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        showButton.tag = !showButton.tag;
        [weakSelf.collectionView scrollToItemAtIndexPath:[weakSelf getbackIndexPathWithSequence:weakSelf.currentMainViewSequence] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
    }];
}

- (void)backTopButtonClick:(UIButton *)backTopButton
{
    __weak SubjectViewController *weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.collectionView.contentOffset = CGPointMake(0, 0);
    }];
}

- (void)showCoverView
{
    UIControl *control = [[UIControl alloc] initWithFrame:self.mainView.frame];
    control.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [self.mainView addSubview:control];
    _control = control;
    [control addTarget:self action:@selector(coverViewClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)coverViewClick:(UIControl *)control
{
    [self showButtonClick:self.showButton];
}

- (UILabel *)createSummaryViewOnView:(UIView *)rightView iconX:(CGFloat)x iconImage:(UIImage *)iconImage textColor:(UIColor *)textColor
{
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(x, 15, 14, 14)];
    icon.image = iconImage;
    [rightView addSubview:icon];
    UILabel *mark = [[UILabel alloc] initWithFrame:CGRectMake(icon.x + icon.width + 5, icon.y, 100, icon.height)];
    mark.font = [UIFont systemFontOfSize:12];
    mark.textColor = textColor;
    mark.textAlignment = NSTextAlignmentLeft;
    [rightView addSubview:mark];
    return mark;
}

// 菜单按钮
- (void)menuItemClick:(UIBarButtonItem *)item
{
    if (!self.showButton.tag) {
        [self showButtonClick:self.showButton];
    }
    item.tag = !item.tag;
    __weak SubjectViewController *weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^{
        
        if (item.tag) {
            weakSelf.menuViewSpaceToTopConstraints.constant = 0;
        } else {
            weakSelf.menuViewSpaceToTopConstraints.constant = -202;
        }
        [weakSelf.view layoutIfNeeded];
    }];
}

// 收藏按钮
- (IBAction)preferClick:(id)sender
{
    if (self.tag == 7 || self.tag == 15) {
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"你确定现在就提交试卷完成考试吗??" delegate:self cancelButtonTitle:nil otherButtonTitles:@"交卷", @"取消", nil] show];
        return;
    }
    SelectView *view = self.mainView.subviews.firstObject;
    SubjectOneModel *model = view.model;
    BOOL success = [SubjectDataBaseTool updatePreferWithCid:model.cid prefer:!model.prefer];
    if (success) {
        self.preferItem.image = [UIImage imageNamed:(!model.prefer == YES ? @"collectDone" : @"collect")];
        [FAFProgressHUD showSuccess:!model.prefer == YES ? @"已添加收藏" : @"已取消收藏" toView:self.mainView];
        model.prefer = !model.prefer;
    }
}

- (void)prepareView:(UIView *)view requestSequence:(NSInteger)sequence
{
    SubjectOneModel *subject = [SubjectDataBaseTool searchSubjectModelWithSequence:sequence category:self.type];
    
    if (subject) {
        NSInteger index = 0;
        for (NSDictionary *dict in ((NSDictionary *)self.dataArray.firstObject).allValues.firstObject) {
            if ([@(sequence) compare:dict.allValues.firstObject] == NSOrderedSame) {
                index = ((NSNumber *)dict.allKeys.firstObject).integerValue;
                break;
            }
        }
        NSInteger answer = ((NSString *)(self.answerDict[[NSString stringWithFormat:@"%li", index]])).integerValue;
        SelectView *selectView = [SelectView loadSelectViewWithModel:subject answerModel:self.segmentControl.selectedSegmentIndex == 0 exam:(self.tag == 7 || self.tag == 15) myAnswer:answer];
        selectView.delegate = self;
        [view addSubview:selectView];
    }
}

- (void)updateSummaryDataWithSequence:(NSInteger)sequence
{
    NSInteger index = 0;
    if (self.tag == 1 || self.tag == 3) {
        index = sequence;
    } else {
        for (NSDictionary *dict in self.dataArray) {
            BOOL end = NO;
            for (NSArray *array in dict.allValues) {
                for (NSDictionary *dic in array) {
                    NSNumber *contentSequence = dic.allValues.firstObject;
                    if (contentSequence.integerValue == sequence) {
                        index = ((NSString *)dic.allKeys.firstObject).integerValue;
                        end = YES;
                        break;
                    }
                }
                if (end) {
                    break;
                }
            }
            if (end) {
                break;
            }
        }
    }
    NSString *textString = [NSString stringWithFormat:@"%ld / %ld", index, self.totalCount];
    
    NSMutableAttributedString *attrs = [[NSMutableAttributedString alloc] initWithString:textString];
    NSRange range = [textString rangeOfString:@"/"];
    [attrs setAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12], NSForegroundColorAttributeName : [UIColor blackColor]} range:NSMakeRange(0, range.location)];
    [attrs setAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12], NSForegroundColorAttributeName : [UIColor grayColor]} range:NSMakeRange(range.location, textString.length - range.location)];
    self.currentIndex.attributedText = attrs;
    self.progress.progress = (CGFloat)(self.errorArray.count + self.rightArray.count) / self.totalCount;
    if (!(self.tag == 7 || self.tag == 15)) {
        SelectView *view = self.mainView.subviews.lastObject;
        SubjectOneModel *model = view.model;
        self.preferItem.image = [UIImage imageNamed:(model.prefer == YES ? @"collectDone" : @"collect")];
    }
    
    if (self.tag == 1) {
        self.cachesDict[[NSString stringWithFormat:@"%ld", self.type]] = @(sequence);
    }
}

- (void)updateResult
{
    if (!(self.tag == 7 || self.tag == 15)) {
        
        self.rightArray = [SubjectDataBaseTool searchModelArrayWithResultType:ResultTypeRight categoryType:self.type];
        self.errorArray = [SubjectDataBaseTool searchModelArrayWithResultType:ResultTypeError categoryType:self.type];
        self.errorMark.text = [NSString stringWithFormat:@"%ld", self.errorArray.count];
        self.correctMark.text = [NSString stringWithFormat:@"%ld", self.rightArray.count];
        NSInteger finishTotal =  (self.rightArray.count + self.errorArray.count);
        if (finishTotal > 0) {
            self.rightRate.text = [NSString stringWithFormat:@"%0.2f分", (float)self.rightArray.count / finishTotal * 100];
        }
    } else {
        NSInteger rightCount = self.answerDict.allKeys.count - self.examErrorArray.count;
        NSInteger standardCount = self.tag == 7 ? 10 : 5;
        if (self.examErrorArray.count > standardCount) {
            [[[UIAlertView alloc] initWithTitle:nil message:[@"你已经答错" stringByAppendingFormat:@" %li 题,考试得分为 %li 分,成绩不合格！", self.examErrorArray.count, rightCount] delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil] show];
            [self.timer invalidate];
        }
        self.correctMark.text = [NSString stringWithFormat:@"%li", rightCount];
        self.errorMark.text = [NSString stringWithFormat:@"%li", self.examErrorArray.count];
    }
}

#pragma mark SelectView的代理方法
- (void)selectRightAnswer:(BOOL)right myAnswer:(NSInteger)myAnswer
{
    if (self.tag == 1 || self.tag == 3) {
        SelectView *view = self.mainView.subviews.firstObject;
        SubjectOneModel *model = view.model;
        ResultType type = right ? ResultTypeRight : ResultTypeError;
        [SubjectDataBaseTool updateResultWithCid:model.cid resultType:type];
    }
    if (!right) {
        if (self.tag == 7 || self.tag == 15) {
            [self.examErrorArray addObject:@(right)];
        }
    }
    [self.answerDict setObject:@(myAnswer) forKey:[self.currentIndex.text componentsSeparatedByString:@" / "].firstObject];
    [self updateResult];
    NSInteger standardCount = self.tag == 7 ? 10 : 5;
    if (self.examErrorArray.count > standardCount) {
        return;
    }
    
    if ((self.nextView.subviews.count > 0) && ((right && self.autoSwitch.on) || (self.tag == 7 || self.tag == 15))) {
        [self switchToNextView];
    }
}
- (void)didScrollView
{
    if (self.navigationItem.rightBarButtonItem.tag) {
        [self menuItemClick:self.navigationItem.rightBarButtonItem];
    }
}

- (void)switchToNextView
{
    __weak SubjectViewController *weakSelf = self;
    [UIView animateWithDuration:0.25 delay:self.slider.value options:UIViewAnimationOptionCurveLinear animations:^{
        
        weakSelf.mainView.x = -Width - 2;
    } completion:^(BOOL finished) {
        
        // 将nextView传给mainView
        [weakSelf.mainView addSubview:weakSelf.nextView.subviews.firstObject];
        // 将mainView传给lastView
        [weakSelf.lastView.subviews.firstObject removeFromSuperview];
        [weakSelf.lastView addSubview:weakSelf.mainView.subviews.firstObject];
        // 重新显示mainView
        weakSelf.mainView.x = 0;
        // 重新加载nextView
        SelectView *mainView = weakSelf.mainView.subviews.firstObject;
        NSInteger nextSequence = 0;
        if (self.tag == 1 || self.tag == 3) {
            nextSequence = weakSelf.tag == 1 ? mainView.tag + 1 : [weakSelf getbackRandomSequence];
        } else {
            for (NSInteger i = 0; i < self.dataArray.count; i++) {
                NSDictionary *dict = self.dataArray[i];
                NSArray *array = dict.allValues.firstObject;
                BOOL end = NO;
                for (NSInteger j = 0; j < array.count; j++) {
                    NSDictionary *dic = array[j];
                    NSNumber *contentSequence = dic.allValues.firstObject;
                    if (contentSequence.integerValue == mainView.tag) {
                        if (j == 0) {
                            if (array.count > 1) {
                                NSDictionary *dic = array[j + 1];
                                NSNumber *next = dic.allValues.firstObject;
                                nextSequence = next.integerValue;
                            } else if (i < (self.dataArray.count - 1)) {
                                NSDictionary *dict = self.dataArray[i + 1];
                                NSArray *array = dict.allValues.firstObject;
                                NSDictionary *dic = array[j + 1];
                                NSNumber *next = dic.allValues.firstObject;
                                nextSequence = next.integerValue;
                            }
                        } else if (j == (array.count - 1)) {
                            if (i < (self.dataArray.count - 1)) {
                                NSDictionary *dict = self.dataArray[i + 1];
                                NSArray *array = dict.allValues.firstObject;
                                NSDictionary *dic = array[0];
                                NSNumber *next = dic.allValues.firstObject;
                                nextSequence = next.integerValue;
                            }
                        } else {
                            NSDictionary *dic = array[j + 1];
                            NSNumber *next = dic.allValues.firstObject;
                            nextSequence = next.integerValue;
                        }
                        end = YES;
                        break;
                    }
                }
                if (end) {
                    break;
                }
            }
        }
        [weakSelf prepareView:weakSelf.nextView requestSequence:nextSequence];
        [weakSelf updateSummaryDataWithSequence:mainView.tag];
        weakSelf.currentMainViewSequence = mainView.tag;
        // 重置nextView的答案和解释
        SelectView *view = weakSelf.lastView.subviews.firstObject;
        [view showAnswerViewWithAnswerModel:weakSelf.segmentControl.selectedSegmentIndex == 0];
    }];
}

// 添加手势
- (void)addDragGesture
{
    UIPanGestureRecognizer *dragGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragGestureDidDraged:)];
    [self.mainView addGestureRecognizer:dragGesture];
}
// 手势监听方法
- (void)dragGestureDidDraged:(UIPanGestureRecognizer *)dragGesture
{
    __weak SubjectViewController *weakSelf = self;
    CGPoint velocity = [dragGesture velocityInView:self.mainView];
    if (velocity.y < 0) {
        [UIView animateWithDuration:0.2 animations:^{
            weakSelf.menuViewSpaceToTopConstraints.constant = -202;
            weakSelf.navigationItem.rightBarButtonItem.tag = 0;
            [weakSelf.view layoutIfNeeded];
        }];
    }
    if (self.showButton.tag == 1) {
        CGFloat autoRate = 0.2;
        CGPoint translation = [dragGesture translationInView:self.mainView];
        CGFloat sentiveValue = Width * autoRate;
        
        if (dragGesture.state == UIGestureRecognizerStateBegan) {
            
            if (velocity.x > 0) {
                if (self.lastView.subviews.count > 0) {
                    self.movingView = self.lastView;
                    self.movingViewOriginalX = self.lastView.x;
                } else {
                    [FAFProgressHUD show:@"已经是第一页" icon:nil view:self.mainView color:nil];
                }
            } else {
                if (self.nextView.subviews.count > 0) {
                    self.movingView = self.mainView;
                    self.movingViewOriginalX = self.mainView.x;
                } else {
                    [FAFProgressHUD show:@"已经是最后一页" icon:nil view:self.mainView color:nil];
                }
            }
            
        } else if (dragGesture.state == UIGestureRecognizerStateChanged) {
            
            CGFloat currentX = self.movingViewOriginalX + translation.x;
            if (self.movingViewOriginalX == 0) {
                currentX = currentX > 0 ? 0 : currentX;
            }
            self.movingView.x = currentX;
            
        } else if (dragGesture.state == UIGestureRecognizerStateEnded) {
            
            [UIView animateWithDuration:0.2 animations:^{
                
                if (fabs((weakSelf.movingViewOriginalX - weakSelf.movingView.x)) > sentiveValue) {
                    weakSelf.movingView.x = weakSelf.movingViewOriginalX == 0 ? -Width - 2 : 0;
                    weakSelf.successSwitchView = YES;
                } else {
                    weakSelf.movingView.x = weakSelf.movingViewOriginalX;
                    weakSelf.successSwitchView = NO;
                }
                
            } completion:^(BOOL finished) {
                
                if (weakSelf.successSwitchView) {
                    
                    if (weakSelf.movingViewOriginalX == 0) {
                        
                        // 将nextView传给mainView
                        [weakSelf.mainView addSubview:weakSelf.nextView.subviews.firstObject];
                        // 将mainView传给lastView
                        [weakSelf.lastView.subviews.firstObject removeFromSuperview];
                        [weakSelf.lastView addSubview:weakSelf.mainView.subviews.firstObject];
                        // 重新显示mainView
                        weakSelf.mainView.x = 0;
                        // 重新加载nextView
                        SelectView *mainView = weakSelf.mainView.subviews.firstObject;
                        NSInteger nextSequence = 0;
                        if (self.tag == 1 || self.tag == 3) {
                            nextSequence = weakSelf.tag == 1 ? mainView.tag + 1 : [weakSelf getbackRandomSequence];
                        } else {
                            for (NSInteger i = 0; i < self.dataArray.count; i++) {
                                NSDictionary *dict = self.dataArray[i];
                                NSArray *array = dict.allValues.firstObject;
                                BOOL end = NO;
                                for (NSInteger j = 0; j < array.count; j++) {
                                    NSDictionary *dic = array[j];
                                    NSNumber *contentSequence = dic.allValues.firstObject;
                                    if (contentSequence.integerValue == mainView.tag) {
                                        if (j == 0) {
                                            if (array.count > 1) {
                                                NSDictionary *dic = array[j + 1];
                                                NSNumber *next = dic.allValues.firstObject;
                                                nextSequence = next.integerValue;
                                            } else if (i < (self.dataArray.count - 1)) {
                                                NSDictionary *dict = self.dataArray[i + 1];
                                                NSArray *array = dict.allValues.firstObject;
                                                NSDictionary *dic = array[j + 1];
                                                NSNumber *next = dic.allValues.firstObject;
                                                nextSequence = next.integerValue;
                                            }
                                        } else if (j == (array.count - 1)) {
                                            if (i < (self.dataArray.count - 1)) {
                                                NSDictionary *dict = self.dataArray[i + 1];
                                                NSArray *array = dict.allValues.firstObject;
                                                NSDictionary *dic = array.firstObject;
                                                NSNumber *next = dic.allValues.firstObject;
                                                nextSequence = next.integerValue;
                                            }
                                        } else {
                                            NSDictionary *dic = array[j + 1];
                                            NSNumber *next = dic.allValues.firstObject;
                                            nextSequence = next.integerValue;
                                        }
                                        end = YES;
                                        break;
                                    }
                                }
                                if (end) {
                                    break;
                                }
                            }
                        }
                        [weakSelf prepareView:weakSelf.nextView requestSequence:nextSequence];
                        weakSelf.currentMainViewSequence = mainView.tag;
                        [weakSelf updateSummaryDataWithSequence:mainView.tag];
                        // 重置nextView的答案和解释
                        SelectView *view = weakSelf.lastView.subviews.firstObject;
                        [view showAnswerViewWithAnswerModel:weakSelf.segmentControl.selectedSegmentIndex == 0];
                        
                    } else if (weakSelf.movingViewOriginalX == -Width - 2) {
                        
                        // 将mainView传给nextView
                        [weakSelf.nextView.subviews.firstObject removeFromSuperview];
                        [weakSelf.nextView addSubview:weakSelf.mainView.subviews.lastObject];
                        // 将lastView传给mainView
                        [weakSelf.mainView addSubview:weakSelf.lastView.subviews.firstObject];
                        // 重新显示mainView
                        weakSelf.lastView.x = -Width - 2;
                        // 重新加载lastView
                        SelectView *mainView = weakSelf.mainView.subviews.firstObject;
                        NSInteger lastSequence = 0;
                        if (self.tag == 1 || self.tag == 3) {
                            lastSequence = weakSelf.tag == 1 ? mainView.tag - 1 : [weakSelf getbackRandomSequence];
                        } else {
                            for (NSInteger i = 0; i < self.dataArray.count; i++) {
                                NSDictionary *dict = self.dataArray[i];
                                NSArray *array = dict.allValues.firstObject;
                                BOOL end = NO;
                                for (NSInteger j = 0; j < array.count; j++) {
                                    NSDictionary *dic = array[j];
                                    NSNumber *contentSequence = dic.allValues.firstObject;
                                    if (contentSequence.integerValue == mainView.tag) {
                                        if (j == 0) {
                                            if (i > 0) {
                                                NSDictionary *dict = self.dataArray[i - 1];
                                                NSArray *array = dict.allValues.firstObject;
                                                NSDictionary *dic = array.lastObject;
                                                NSNumber *last = dic.allValues.firstObject;
                                                lastSequence = last.integerValue;
                                            }
                                        } else if (j == (array.count - 1)) {
                                            if (array.count > 1) {
                                                NSDictionary *dic = array[j - 1];
                                                NSNumber *last = dic.allValues.firstObject;
                                                lastSequence = last.integerValue;
                                            } else if (i > 0) {
                                                NSDictionary *dict = self.dataArray[i - 1];
                                                NSArray *array = dict.allValues.lastObject;
                                                NSDictionary *dic = array[j - 1];
                                                NSNumber *last = dic.allValues.firstObject;
                                                lastSequence = last.integerValue;
                                            }
                                        } else {
                                            NSDictionary *dic = array[j - 1];
                                            NSNumber *last = dic.allValues.firstObject;
                                            lastSequence = last.integerValue;
                                        }
                                        end = YES;
                                        break;
                                    }
                                }
                                if (end) {
                                    break;
                                }
                            }
                        }
                        [weakSelf prepareView:weakSelf.lastView requestSequence:lastSequence];
                        [weakSelf updateSummaryDataWithSequence:mainView.tag];
                        weakSelf.currentMainViewSequence = mainView.tag;
                        // 重置nextView的答案和解释
                        SelectView *view = weakSelf.nextView.subviews.firstObject;
                        [view showAnswerViewWithAnswerModel:weakSelf.segmentControl.selectedSegmentIndex == 0];
                    }
                    weakSelf.successSwitchView = NO;
                    weakSelf.movingView = nil;
                    weakSelf.movingViewOriginalX = 100;
                }
            }];
        }
    }
}

// 创建3个显示视图
- (void)setupViews
{
    self.lastView = [self createViewWithXValue:-Width - 2];
    self.mainView = [self createViewWithXValue:0];
    self.nextView = [self createViewWithXValue:0];
}

// 创建显示视图
- (UIView *)createViewWithXValue:(CGFloat)x
{
    UIView *view = [[UIView alloc] initWithFrame:self.view.frame];
    view.x = x;
    view.layer.shadowOffset = CGSizeMake(2, 0);
    view.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor;
    view.layer.shadowOpacity = 0.5;
    [self.view insertSubview:view atIndex:0];
    return view;
}

#pragma mark -UICollectionView代理方法
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.dataArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSDictionary *dict = self.dataArray[section];
    NSArray *sectionDataArray = dict.allValues.firstObject;
    return sectionDataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    NSDictionary *dict = self.dataArray[indexPath.section];
    NSArray *sectionDataArray = dict.allValues.firstObject;
    NSInteger index = ((NSString *)((NSDictionary *)sectionDataArray[indexPath.row]).allKeys.firstObject).integerValue;
    NSInteger value = ((NSString *)((NSDictionary *)sectionDataArray[indexPath.row]).allValues.firstObject).integerValue;
    cell.title.text = [NSString stringWithFormat:@"%ld", index];
    if (self.tag == 7 || self.tag == 15) {
        
        if (self.currentMainViewSequence == value) {
            cell.title.backgroundColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.3];
        } else if ([self.answerDict.allKeys containsObject:[NSString stringWithFormat:@"%li",(indexPath.row + 1)]]) {
            cell.title.backgroundColor = [UIColor colorWithRed:0 green:1 blue:0.5 alpha:0.9];
        } else {            
            cell.title.backgroundColor = [UIColor whiteColor];
        }
    } else {
        
        if (self.currentMainViewSequence == value) {
            
            cell.title.backgroundColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.3];
        } else if ([self.rightArray containsObject:@(value)]) {
            
            cell.title.backgroundColor = [UIColor colorWithRed:0 green:1 blue:0.5 alpha:0.9];
        } else if ([self.errorArray containsObject:@(value)]) {
            
            cell.title.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.5];
        } else {
            
            cell.title.backgroundColor = [UIColor whiteColor];
        }
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(Width, 30);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        CollectionHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"collectionViewHeader" forIndexPath:indexPath];
        NSDictionary *dict = self.dataArray[indexPath.section];
        header.title.text = dict.allKeys.firstObject;
        return header;
    }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = self.dataArray[indexPath.section];
    NSArray *sectionDataArray = dict.allValues.firstObject;
    NSInteger select = ((NSNumber *)((NSDictionary *)sectionDataArray[indexPath.row]).allValues.firstObject).integerValue;
    [self.mainView.subviews.firstObject removeFromSuperview];
    [self.lastView.subviews.firstObject removeFromSuperview];
    [self.nextView.subviews.firstObject removeFromSuperview];
    [self loadDataWithMainViewModelSequence:select];
    [self.collectionView reloadData];
    __weak SubjectViewController *weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf showButtonClick:self.showButton];
    });
}

- (NSString *)cachesPath
{
    if (_cachesPath == nil) {
        NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"caches"];
        [[NSFileManager defaultManager] createDirectoryAtPath:docDir withIntermediateDirectories:YES attributes:nil error:nil];
        _cachesPath = [docDir stringByAppendingPathComponent:@"caches.dat"];
    }
    return _cachesPath;
}

- (NSString *)examPath
{
    if (_examPath == nil) {
        
        NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"caches"];
        [[NSFileManager defaultManager] createDirectoryAtPath:docDir withIntermediateDirectories:YES attributes:nil error:nil];
        _examPath = [docDir stringByAppendingPathComponent:@"exam.dat"];
    }
    return _examPath;
}

- (NSMutableDictionary *)cachesDict
{
    if (_cachesDict == nil) {
        _cachesDict = [NSMutableDictionary dictionary];
    }
    return _cachesDict;
}

- (NSMutableDictionary *)answerDict
{
    if (_answerDict == nil) {
        _answerDict = [NSMutableDictionary dictionary];
    }
    return _answerDict;
}

- (NSMutableArray *)examErrorArray
{
    if (_examErrorArray == nil) {
        _examErrorArray = [NSMutableArray array];
    }
    return _examErrorArray;
}

- (void)updateViewAnswerModelWithView:(UIView *)view
{
    SelectView *view1 = view.subviews.firstObject;
    [view1 showAnswerViewWithAnswerModel:self.segmentControl.selectedSegmentIndex == 0];
}

- (NSIndexPath *)getbackIndexPathWithSequence:(NSInteger)sequence
{
    NSMutableArray *countArray = [NSMutableArray array];
    NSInteger currentIndex = 0;
    for (NSInteger i = 0; i < self.dataArray.count; i++) {
        NSDictionary *dict = self.dataArray[i];
        NSArray *sectionDataArray = dict.allValues.firstObject;
        [countArray addObject:@(sectionDataArray.count)];
        for (NSDictionary *dict in sectionDataArray) {
            if ([dict.allValues.firstObject compare:@(sequence)] == NSOrderedSame){
                currentIndex = ((NSNumber *)dict.allKeys.firstObject).integerValue;
            }
        }
    }
    
    __block NSInteger count = 0;
    for (NSInteger i = 0; i < countArray.count; i++) {
        NSNumber *number = countArray[i];
        count += number.integerValue;
        if (currentIndex <= count) {
            return [NSIndexPath indexPathForRow:(currentIndex - (count - number.integerValue) - 1) inSection:i];
            break;
        }
    }
    return nil;
}

- (NSInteger)getbackRandomSequence
{
    NSInteger sequence = arc4random() % self.totalCount + 1;
    
    return sequence;
}

- (IBAction)segmentControlClick:(UISegmentedControl *)sender
{
    self.cachesDict[@"model"] = @(sender.selectedSegmentIndex);
    [self updateViewAnswerModelWithView:self.mainView];
    [self updateViewAnswerModelWithView:self.lastView];
    [self updateViewAnswerModelWithView:self.nextView];
}

- (IBAction)autoSwitchClick:(UISwitch *)sender
{
    self.cachesDict[@"autoSwitch"] = @(sender.on);
}

- (IBAction)sliderClicked:(UISlider *)sender
{
    self.duration.text = [NSString stringWithFormat:@"%0.2f", sender.value];
    self.cachesDict[@"duration"] = @(sender.value);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.title.length > 0) {
        // 放弃考试
        if (buttonIndex == 0) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        // 提交考试
        if (buttonIndex == 0) {            
            NSString *time = [self.title componentsSeparatedByString:@" "].lastObject;
            NSArray *times = [time componentsSeparatedByString:@":"];
            NSInteger timeSecond = ((NSString *)times.firstObject).integerValue * 60 + ((NSString *)times.lastObject).integerValue;
            NSInteger totalSecond = self.tag == 7 ? 45 * 60 : 30 * 60;
            NSInteger leaveTime = totalSecond - timeSecond;
            NSInteger leaveMinute = leaveTime / 60;
            NSInteger leaveSecond = leaveTime - leaveMinute * 60;
            NSString *leaveMinuteString = [NSString stringWithFormat:leaveMinute < 10 ? @"0%ld" : @"%ld", leaveMinute];
            NSString *leaveSecondString = [NSString stringWithFormat:leaveSecond < 10 ? @"0%ld" : @"%ld", leaveSecond];
            NSString *uploadTimeString = [NSString stringWithFormat:@"%@:%@", leaveMinuteString, leaveSecondString];
            NSInteger rightCount = self.answerDict.allKeys.count - self.examErrorArray.count;
            NSString *score = [NSString stringWithFormat:@"%ld", rightCount];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy.MM.dd HH:mm:ss"];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:self.examPath];
            if (dict == nil) {
                dict = [NSMutableDictionary dictionary];
            }
            NSString *outKey = [NSString stringWithFormat:@"%li", self.type];
            NSMutableDictionary *innerDict = [NSMutableDictionary dictionaryWithDictionary:dict[outKey]];
            innerDict[[[AppDelegate getIdentifier] stringByAppendingFormat:@" %@", [dateFormatter stringFromDate:[NSDate date]]]] = [score stringByAppendingFormat:@" %@", uploadTimeString];
            
            dict[outKey] = innerDict;
            [dict writeToFile:self.examPath atomically:YES];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"enterRank" object:nil userInfo:@{@"1" : @(self.tag == 7 ? 6 : 14)}];
        }
    }
}

@end
