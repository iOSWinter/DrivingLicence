//
//  HomeViewController.m
//  DrivingLicence
//
//  Created by WinterChen on 16/9/14.
//  Copyright © 2016年 win. All rights reserved.
//

#import "HomeViewController.h"
#import "SubjectViewController.h"
#import "ExamViewController.h"
#import "SpecialViewController.h"
#import "RankViewController.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface HomeViewController () <GADBannerViewDelegate>

@property (weak, nonatomic) IBOutlet GADBannerView *adView;
@property (weak, nonatomic) IBOutlet UIImageView *shunxuImgView;
@property (weak, nonatomic) IBOutlet UIImageView *cuotiImgView;
@property (weak, nonatomic) IBOutlet UIImageView *suijiImgView;
@property (weak, nonatomic) IBOutlet UIImageView *collectImgView;
@property (weak, nonatomic) IBOutlet UIImageView *zhuantiImgView;
@property (weak, nonatomic) IBOutlet UIImageView *paimingImgView;
@property (weak, nonatomic) IBOutlet UIImageView *shunxuImgView1;
@property (weak, nonatomic) IBOutlet UIImageView *cuotiImgView1;
@property (weak, nonatomic) IBOutlet UIImageView *suijiImgView1;
@property (weak, nonatomic) IBOutlet UIImageView *collectImgView1;
@property (weak, nonatomic) IBOutlet UIImageView *zhuantiImgView1;
@property (weak, nonatomic) IBOutlet UIImageView *paimingImgView1;
@property (weak, nonatomic) IBOutlet UIButton *centerButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *secodeViewSpaceToTopConstraints;

@property (nonatomic, strong) UIView *launchView;
@property (nonatomic, strong) GADBannerView *rectBannerView;
@property (nonatomic, assign) BOOL adDidShow;
@property (nonatomic, assign) BOOL launchAd;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
    [self setupTintColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterRank:) name:@"enterRank" object:nil];
    
    [self showLaunchView];
    
    [SubjectDataBaseTool requestSubjectDataFromServerWithCategory:CategoryTypeSubjectOne index:0];
    [SubjectDataBaseTool requestSubjectDataFromServerWithCategory:CategoryTypeSubjectFour index:0];
}


- (void)showLaunchView
{
    self.launchAd = YES;
    UIView *launchView = [[UIView alloc] initWithFrame:self.navigationController.view.bounds];
    launchView.backgroundColor = [UIColor whiteColor];
    [self.navigationController.view addSubview:launchView];
    self.launchView = launchView;
    UIView *iconView = [[UIView alloc] initWithFrame:CGRectMake(0, Height, Width, 50)];
    [self.launchView addSubview:iconView];
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake((launchView.width - 80 - 50 - 10) * 0.5, 0, 50, 50)];
    icon.image = [UIImage imageNamed:@"appIcon"];
    icon.layer.cornerRadius = 10;
    icon.layer.masksToBounds = YES;
    [iconView addSubview:icon];
    UILabel *appName = [[UILabel alloc] initWithFrame:CGRectMake(icon.x + icon.width + 10, icon.y, 80, icon.height)];
    appName.text = @"驾考之家";
    appName.textColor = [UIColor grayColor];
    [iconView addSubview:appName];
    [UIView animateWithDuration:0.5 animations:^{
        iconView.y -= 70;
    }];
    [self showRectangleBannerView];
}

- (void)showRectangleBannerView
{
    CGRect frame = CGRectMake((Width - 300) * 0.5, (Height - 70 - 250) * 0.5, 300, 250);
    _rectBannerView = [[GADBannerView alloc] initWithFrame:frame];
    [self.rectBannerView setAdSize:kGADAdSizeMediumRectangle];
    self.rectBannerView.adUnitID = AdMobBannerID;
    self.rectBannerView.rootViewController = self;
    self.rectBannerView.delegate = self;
    GADRequest *request = [GADRequest request];
    [self.rectBannerView loadRequest:request];
    [self.launchView addSubview:self.rectBannerView];
    CGFloat width = 30;
//    [self AddBannerBarViewWihtFrame:CGRectMake(5, 0, width, 15)];
    [self AddBannerBarViewWihtFrame:CGRectMake(0, _rectBannerView.height - 15, width, 15)];
//    [self AddBannerBarViewWihtFrame:CGRectMake(_rectBannerView.width - width, 0, width, 15)];
//    [self AddBannerBarViewWihtFrame:CGRectMake(_rectBannerView.width - width, _rectBannerView.height - 15, width, 15)];
    [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(removeLaunchViewWhenNotShowAd) userInfo:nil repeats:NO];
}

- (void)AddBannerBarViewWihtFrame:(CGRect)frame
{
    UIView *bar = [[UIView alloc] initWithFrame:frame];
    bar.backgroundColor = [UIColor whiteColor];
    [_rectBannerView addSubview:bar];
}

- (void)showAdView
{
    CGRect frame = CGRectMake((Width - 300) * 0.5, (Height - 70 - 250) * 0.5, 300, 250);
    NSInteger sequence = arc4random() % 3 + 1;
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:frame];
    imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"ad%ld.png", sequence]];
    imgView.layer.cornerRadius = 5;
    imgView.layer.masksToBounds = YES;
    imgView.alpha = 0.9;
    [self.launchView addSubview:imgView];
}

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView
{
    if (self.launchAd) {
        
        self.adDidShow = YES;
        self.launchAd = NO;
        [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(removeLaunchView) userInfo:nil repeats:NO];
    } else {
        
        __weak HomeViewController *weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [UIView animateWithDuration:0.3 animations:^{
                weakSelf.secodeViewSpaceToTopConstraints.constant = 10;
                [weakSelf.view layoutIfNeeded];
            }];
            
        });
    }
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error
{
    if (self.launchAd) {
        
        self.adDidShow = YES;
        self.launchAd = NO;
        [self showAdView];
        [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(removeLaunchView) userInfo:nil repeats:NO];
    } else {
        
        __weak HomeViewController *weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 animations:^{
                weakSelf.secodeViewSpaceToTopConstraints.constant = -50;
                [weakSelf.view layoutIfNeeded];
            }];
            
        });
    }
}

- (void)removeLaunchViewWhenNotShowAd
{
    if (!self.adDidShow) {
        [self removeLaunchView];
        
    }
}

- (void)removeLaunchView
{
    [UIView animateWithDuration:0.3 animations:^{
        
        self.launchView.y = Height;
    } completion:^(BOOL finished) {
        
        [self setupBannerView];
        [self.launchView removeFromSuperview];
    }];
}

- (void)setupTintColor
{
    self.shunxuImgView.image = [[UIImage imageNamed:@"shunxu"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.suijiImgView.image = [[UIImage imageNamed:@"suiji"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.zhuantiImgView.image = [[UIImage imageNamed:@"zhuanti"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.cuotiImgView.image = [[UIImage imageNamed:@"cuoti"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.collectImgView.image = [[UIImage imageNamed:@"collect"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.paimingImgView.image = [[UIImage imageNamed:@"paiming"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.shunxuImgView1.image = [[UIImage imageNamed:@"shunxu"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.suijiImgView1.image = [[UIImage imageNamed:@"suiji"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.zhuantiImgView1.image = [[UIImage imageNamed:@"zhuanti"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.cuotiImgView1.image = [[UIImage imageNamed:@"cuoti"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.collectImgView1.image = [[UIImage imageNamed:@"collect"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.paimingImgView1.image = [[UIImage imageNamed:@"paiming"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (void)setupBannerView
{
    self.adView.adUnitID = AdMobBannerID;
    self.adView.rootViewController = self;
    self.adView.delegate = self;
    GADRequest *request = [GADRequest request];
    [self.adView loadRequest:request];    
}

- (void)enterRank:(NSNotification *)noti
{
    [self.navigationController popToRootViewControllerAnimated:NO];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.tag = ((NSNumber *)noti.userInfo.allValues.firstObject).integerValue;
    [self modelButtonClick:button];
}

- (IBAction)modelButtonClick:(UIButton *)sender
{
    if (sender.tag == 7 || sender.tag == 15) {
        [self performSegueWithIdentifier:@"examSegue" sender:sender];
    } else if (sender.tag == 6 || sender.tag == 14) {
        [self performSegueWithIdentifier:@"rankSegue" sender:sender];
    } else if (sender.tag != 5 && sender.tag != 13){
        [self performSegueWithIdentifier:@"listSegue" sender:sender];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UIButton *)sender
{
    CategoryType type = sender.tag < 8 ? CategoryTypeSubjectOne : CategoryTypeSubjectFour;
    if (sender.tag == 7 || sender.tag == 15) {
        ExamViewController *vc = segue.destinationViewController;
        vc.type = type;
        vc.title = [(vc.type == CategoryTypeSubjectOne ? @"科目一" : @"科目四") stringByAppendingFormat:@" %@", @" 模拟考试"];
    } else if (sender.tag == 5 || sender.tag == 13) {
        SpecialViewController *vc = segue.destinationViewController;
        vc.type = type;
        vc.tag = sender.tag;
        vc.title = [(vc.type == CategoryTypeSubjectOne ? @"科目一" : @"科目四") stringByAppendingFormat:@" %@", sender.titleLabel.text];;
    } else if (sender.tag == 6 || sender.tag == 14) {
        RankViewController *vc = segue.destinationViewController;
        vc.title = [(sender.tag == 6 ? @"科目一" : @"科目四") stringByAppendingFormat:@"  考试排名"];
        vc.type = type;
    } else {
        SubjectViewController *vc = segue.destinationViewController;
        vc.tag = sender.tag;
        vc.type = type;
        vc.fetchType = (sender.tag == 1 || sender.tag == 3 || sender.tag == 9 || sender.tag == 11) ? FetchTypeAll : (sender.tag == 2 ? FetchTypeError : FetchTypePrefer);
        vc.title = [(vc.type == CategoryTypeSubjectOne ? @"科目一" : @"科目四") stringByAppendingFormat:@" %@", sender.titleLabel.text];
    }
}

@end
