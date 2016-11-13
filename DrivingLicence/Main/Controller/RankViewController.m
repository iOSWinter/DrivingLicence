//
//  RankViewController.m
//  DrivingLicence
//
//  Created by WinterChen on 16/10/9.
//  Copyright © 2016年 win. All rights reserved.
//

#import "RankViewController.h"
#import "RankCell.h"

@interface RankViewController ()

@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation RankViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (UIView *)createTableViewHeader
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Width, 40)];
    view.backgroundColor = [UIColor orangeColor];
    [view addSubview:[self createLabelWithFrame:CGRectMake(0, 0, 60, view.height) text:@"成绩"]];
    [view addSubview:[self createLabelWithFrame:CGRectMake(65, 0, 60, view.height) text:@"耗时(分)"]];
    [view addSubview:[self createLabelWithFrame:CGRectMake(130, 0, Width - 80 - 130, view.height) text:@"考试时间"]];
    [view addSubview:[self createLabelWithFrame:CGRectMake(Width - 80, 0, 80, view.height) text:@"全国排名"]];
    return view;
}

- (UILabel *)createLabelWithFrame:(CGRect)frame text:(NSString *)text
{
    UILabel *lb = [[UILabel alloc] initWithFrame:frame];
    lb.text = text;
    lb.textColor = [UIColor whiteColor];
    lb.textAlignment = NSTextAlignmentCenter;
    lb.font = [UIFont boldSystemFontOfSize:16];
    return lb;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RankCell *cell = [tableView dequeueReusableCellWithIdentifier:@"rankListCell" forIndexPath:indexPath];
    
    [cell setupData:self.dataArray[indexPath.row]];
    
    if (indexPath.row % 2 == 0) {
        cell.backgroundColor = [UIColor colorWithRed:0 green:0.1 blue:1 alpha:0.2];
    } else {
        cell.backgroundColor = [UIColor colorWithRed:0.5 green:0.9 blue:0.3 alpha:0.5];
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self createTableViewHeader];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSArray *)dataArray
{
    if (_dataArray == nil) {
        
        NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"caches"];
        [[NSFileManager defaultManager] createDirectoryAtPath:docDir withIntermediateDirectories:YES attributes:nil error:nil];
        NSString *examPath = [docDir stringByAppendingPathComponent:@"exam.dat"];
        NSDictionary *outDict = [NSDictionary dictionaryWithContentsOfFile:examPath];
        NSDictionary *innerDict = outDict[[NSString stringWithFormat:@"%li", self.type]];
        NSMutableArray *array = [NSMutableArray array];
        for (NSString *key in innerDict) {
            [array addObject:@{key : innerDict[key]}];
        }
        _dataArray = [array sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
            NSString *key1 = obj1.allKeys.firstObject;
            NSString *key2 = obj2.allKeys.firstObject;
            return [key2 compare:key1];
        }];
    }
    return _dataArray;
}

@end
