//
//  SpecialViewController.m
//  DrivingLicence
//
//  Created by WinterChen on 16/10/8.
//  Copyright © 2016年 win. All rights reserved.
//

#import "SpecialViewController.h"
#import "SubjectViewController.h"
#import "SpecialCollectionCell.h"

@interface SpecialViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

//@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation SpecialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupCollectionView];
}

- (void)setupCollectionView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(Width * 0.5, 40);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 20;
    layout.sectionInset = UIEdgeInsetsMake(20, 0, 20, 0);
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
    _collectionView.delegate =self;
    _collectionView.dataSource = self;
    [_collectionView registerClass:[SpecialCollectionCell class] forCellWithReuseIdentifier:@"specialCell"];
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_collectionView];
}

#pragma mark -UICollectionView代理方法
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SpecialCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"specialCell" forIndexPath:indexPath];
    
    [cell setupSequence:(indexPath.row + 1) string:self.dataArray[indexPath.row]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"specialSegue" sender:indexPath];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(NSIndexPath *)sender
{
    NSString *select = self.dataArray[sender.row];
    SubjectType subjectType;
    NSString *keyword = nil;
    if ([select isEqualToString:@"选择题"] || [select isEqualToString:@"单选题"]) {
        subjectType = SubjectTypeSingleSelect;
    } else if ([select isEqualToString:@"多选题"]) {
        subjectType = SubjectTypeMultiSelect;
    } else if ([select isEqualToString:@"判断题"]) {
        subjectType = SubjectTypeJudge;
    } else {
        keyword = [select substringToIndex:2];
    }
    SubjectViewController *vc = segue.destinationViewController;
    vc.subjectType = subjectType;
    vc.keyword = keyword;
    vc.type = self.type;
    vc.tag = self.tag;
    vc.title = self.dataArray[sender.row];
}

- (NSArray *)dataArray
{
    if (self.type == CategoryTypeSubjectOne) {
        
        return @[@"选择题", @"判断题", @"文字题", @"时间题", @"距离题", @"标志题", @"信号等", @"酒驾题", @"灯光题", @"路况题", @"仪表题", @"装置题", @"标线题", @"记分题", @"手势题", @"罚款题", @"速度题", @"图片题"];
    } else {
        
        return @[@"单选题", @"动画题", @"多选题", @"判断题", @"文字题", @"时间题", @"距离题", @"标志题", @"信号等", @"酒驾题", @"灯光题", @"路况题", @"仪表题", @"装置题", @"标线题", @"记分题", @"手势题", @"罚款题", @"速度题", @"图片题"];
    }
}


@end
