//
//  SubjectDataBaseTool.h
//  DrivingLicence
//
//  Created by WinterChen on 16/9/16.
//  Copyright © 2016年 win. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    FetchTypeAll,
    FetchTypeError,
    FetchTypePrefer,
} FetchType;

@interface SubjectDataBaseTool : NSObject

/** 请求服务器数据 */
+ (void)requestSubjectDataFromServerWithCategory:(CategoryType)type index:(NSInteger)index;
/** 按试题编号查询数据 */
+ (SubjectOneModel *)searchSubjectModelWithSequence:(NSInteger)sequence category:(CategoryType)category;
/** 按类别查询数据总条数 */
+ (NSInteger)searchTotalCountWithCategoryType:(CategoryType)type fetchType:(FetchType)fetchType;
/** 查询数据总数及其对应的列表 */
+ (NSMutableArray *)searchDataListArrayWithCategoryType:(CategoryType)type fetchType:(FetchType)fetchType;
/** 按类别查询正确和错误的数量 */
+ (NSInteger)searchCountWithResultType:(ResultType)type categoryType:(CategoryType)categoryType;
/** 按类别查询正确和错误的数据 */
+ (NSMutableArray *)searchModelArrayWithResultType:(ResultType)type categoryType:(CategoryType)categoryType;
/** 更新答题数据 */
+ (void)updateResultWithCid:(NSInteger)cid resultType:(ResultType)type;
/** 更新收藏数据*/
+ (BOOL)updatePreferWithCid:(NSInteger)cid prefer:(BOOL)prefer;
/** 生成模拟考试试卷 */
+ (NSMutableArray *)generateExaminationPageWithCategoryType:(CategoryType)type;
/** 专题练习查询总数量 */
+ (NSInteger)searchTotalCountWithCategoryType:(CategoryType)type subjectType:(SubjectType)subjectType keyWord:(NSString *)keyWord;
// 专题练习查询数据模型数组
+ (NSMutableArray *)searchDataListArrayWithCategoryType:(CategoryType)type subjectType:(SubjectType)subjectType keyWord:(NSString *)keyWord;

@end
