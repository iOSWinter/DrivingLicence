//
//  SubjectDataBaseTool.m
//  DrivingLicence
//
//  Created by WinterChen on 16/9/16.
//  Copyright © 2016年 win. All rights reserved.
//

#import "SubjectDataBaseTool.h"
#import "FMDB.h"

@interface SubjectDataBaseTool ()

@property (nonatomic, strong) FMDatabase *database;
@property (nonatomic, assign) BOOL subjectTypeOneFinish;
@property (nonatomic, assign) BOOL subjectTypeFourFinish;
@property (nonatomic, strong) NSString *finishPath;

@end

static SubjectDataBaseTool *_shareInstance = nil;

@implementation SubjectDataBaseTool


#pragma mark -公开方法
// 查询单个数据模型
+ (SubjectOneModel *)searchSubjectModelWithSequence:(NSInteger)sequence category:(CategoryType)category
{
    SubjectOneModel *subject = nil;
    
    [self initClass];
    if ([_shareInstance.database open]) {
        FMResultSet *resultSet = [_shareInstance.database executeQueryWithFormat:@"SELECT * FROM subject_table WHERE categoryId=%ld AND category=%ld", sequence, category];
        subject = [self getbackModelArrayWithResultSet:resultSet].firstObject;
        [_shareInstance.database close];
    }
    
    return subject;
}

// 查询总数量
+ (NSInteger)searchTotalCountWithCategoryType:(CategoryType)type fetchType:(FetchType)fetchType
{
    NSInteger totalCount = 0;
    [self initClass];
    if ([_shareInstance.database open]) {
        FMResultSet *resultSet = nil;
        switch (fetchType) {
            case FetchTypeAll:
                resultSet = [_shareInstance.database executeQueryWithFormat:@"SELECT COUNT(*) FROM subject_table WHERE category=%ld", type];
                break;
            case FetchTypeError:
                resultSet = [_shareInstance.database executeQueryWithFormat:@"SELECT COUNT(*) FROM subject_table WHERE category=%ld AND result<%d", type, 0];
                break;
            case FetchTypePrefer:
                resultSet = [_shareInstance.database executeQueryWithFormat:@"SELECT COUNT(*) FROM subject_table WHERE category=%ld AND prefer=%d", type, YES];
                break;
        }
        while ([resultSet next]) {
            totalCount = [resultSet intForColumnIndex:0];
        }
        [_shareInstance.database close];
    }
    return totalCount;
}

// 专题练习查询数据模型数组
+ (NSMutableArray *)searchDataListArrayWithCategoryType:(CategoryType)type subjectType:(SubjectType)subjectType keyWord:(NSString *)keyWord
{
    NSMutableArray *resultArray = [NSMutableArray array];
    [self initClass];
    if ([_shareInstance.database open]) {
        FMResultSet *resultSet = nil;
        NSMutableArray *dataArray = [NSMutableArray array];
        NSString *sql = nil;
        if (subjectType >= SubjectTypeSingleSelect && subjectType <= SubjectTypeJudge) {
            sql = [NSString stringWithFormat:@"SELECT DISTINCT mDescription FROM subject_table WHERE category=%ld AND type=%ld", type, subjectType];
        } else {
            if ([keyWord isEqualToString:@"文字"] || [keyWord isEqualToString:@"图片"]) {
                if ([keyWord isEqualToString:@"文字"]) {
                    
                    sql = [NSString stringWithFormat:@"SELECT DISTINCT mDescription FROM subject_table WHERE category=%ld AND imgUrl is null", type];
                } else {
                    
                    sql = [NSString stringWithFormat:@"SELECT DISTINCT mDescription FROM subject_table WHERE category=%ld AND imgUrl is not null", type];
                }
            } else {
                
                sql = [NSString stringWithFormat:@"SELECT DISTINCT mDescription FROM subject_table WHERE category=%ld AND question like '%%%@%%'", type, keyWord];
            }
        }
        resultSet = [_shareInstance.database executeQuery:sql];
        while ([resultSet next]) {
            NSString *mDescription = [resultSet stringForColumnIndex:0];
            [dataArray addObject:mDescription];
        }
        __block NSInteger count = 0;
        for (NSInteger i = 0; i < dataArray.count; i++) {
            NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
            NSString *mDescription = dataArray[i];
            FMResultSet *resultSet = nil;
            
            if (keyWord) {
                // 图片和文字题目
                if ([keyWord isEqualToString:@"文字"] || [keyWord isEqualToString:@"图片"]) {
                    if ([keyWord isEqualToString:@"文字"]) {
                        
                        sql = [NSString stringWithFormat:@"SELECT categoryId FROM subject_table WHERE category=%ld AND mDescription='%@' AND imgUrl is null", type, mDescription];
                    } else {
                        
                        sql = [NSString stringWithFormat:@"SELECT categoryId FROM subject_table WHERE category=%ld AND mDescription='%@' AND imgUrl is not null", type, mDescription];
                    }
                } else{
                    
                    // 其他类型
                    sql = [NSString stringWithFormat:@"SELECT categoryId FROM subject_table WHERE category=%ld AND mDescription='%@' AND question like '%%%@%%'", type, mDescription, keyWord];
                }
            } else {
                // 选择题和判断题
                sql = [NSString stringWithFormat:@"SELECT categoryId FROM subject_table WHERE category=%ld AND mDescription='%@' AND type=%ld", type, mDescription, subjectType];
            }
            resultSet = [_shareInstance.database executeQuery:sql];
            NSMutableArray *resultA = [NSMutableArray array];
            while ([resultSet next]) {
                count++;
                NSInteger cid = [resultSet intForColumnIndex:0];
                [resultA addObject:@{[NSString stringWithFormat:@"%ld", count] : @(cid)}];
            }
            resultDict[mDescription] = resultA;
            [resultArray addObject:resultDict];
        }
        [_shareInstance.database close];
    }
    return resultArray;
}

// 专题练习查询总数量
+ (NSInteger)searchTotalCountWithCategoryType:(CategoryType)type subjectType:(SubjectType)subjectType keyWord:(NSString *)keyWord
{
    NSInteger totalCount = 0;
    [self initClass];
    if ([_shareInstance.database open]) {
        FMResultSet *resultSet = nil;
        if (keyWord) {
            // 图片和文字题目
            if ([keyWord isEqualToString:@"文字"] || [keyWord isEqualToString:@"图片"]) {
                NSString *sql = nil;
                if ([keyWord isEqualToString:@"文字"]) {
                    
                    sql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM subject_table WHERE category=%ld AND imgUrl is null", type];
                } else {
                    
                    sql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM subject_table WHERE category=%ld AND imgUrl is not null", type];
                }
                resultSet = [_shareInstance.database executeQuery:sql];
                while ([resultSet next]) {
                    totalCount = [resultSet intForColumnIndex:0];
                }
            } else{
                
                // 其他类型
                NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM subject_table WHERE category=%ld AND question like '%%%@%%'", type, keyWord];
                resultSet = [_shareInstance.database executeQuery:sql];
                while ([resultSet next]) {
                    totalCount = [resultSet intForColumnIndex:0];
                }
            }
        } else {
            // 选择题和判断题
            resultSet = [_shareInstance.database executeQueryWithFormat:@"SELECT COUNT(*) FROM subject_table WHERE category=%ld AND type=%ld", type, subjectType];
            while ([resultSet next]) {
                totalCount = [resultSet intForColumnIndex:0];
            }
        }
    }
    [_shareInstance.database close];
    return totalCount;
}

// 查询数据模型数组
+ (NSMutableArray *)searchDataListArrayWithCategoryType:(CategoryType)type fetchType:(FetchType)fetchType
{
    NSMutableArray *resultArray = [NSMutableArray array];
    [self initClass];
    if ([_shareInstance.database open]) {
        FMResultSet *resultSet = nil;
        switch (fetchType) {
            case FetchTypeAll:
                resultSet = [_shareInstance.database executeQueryWithFormat:@"SELECT DISTINCT mDescription FROM subject_table WHERE category=%ld", type];
                break;
            case FetchTypeError:
                resultSet = [_shareInstance.database executeQueryWithFormat:@"SELECT DISTINCT mDescription FROM subject_table WHERE category=%ld AND result<%d", type, 0];
                break;
            case FetchTypePrefer:
                resultSet = [_shareInstance.database executeQueryWithFormat:@"SELECT DISTINCT mDescription FROM subject_table WHERE category=%ld AND prefer=%d", type, YES];
                break;
        }
        
        NSMutableArray *dataArray = [NSMutableArray array];
        while ([resultSet next]) {
            NSString *mDescription = [resultSet stringForColumnIndex:0];
            [dataArray addObject:mDescription];
        }
        __block NSInteger count = 0;
        for (NSInteger i = 0; i < dataArray.count; i++) {
            NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
            NSString *mDescription = dataArray[i];
            FMResultSet *resultSet = nil;
            switch (fetchType) {
                case FetchTypeAll:
                    resultSet = [_shareInstance.database executeQueryWithFormat:@"SELECT categoryId FROM subject_table WHERE category=%ld AND mDescription=%@", type, mDescription];
                    break;
                case FetchTypeError:
                    resultSet = [_shareInstance.database executeQueryWithFormat:@"SELECT categoryId FROM subject_table WHERE category=%ld AND mDescription=%@ AND result<%d", type, mDescription, 0];
                    break;
                case FetchTypePrefer:
                    resultSet = [_shareInstance.database executeQueryWithFormat:@"SELECT categoryId FROM subject_table WHERE category=%ld AND mDescription=%@ AND prefer=%d", type, mDescription, YES];
                    break;
            }
            NSMutableArray *resultA = [NSMutableArray array];
            while ([resultSet next]) {
                count++;
                NSInteger cid = [resultSet intForColumnIndex:0];
                [resultA addObject:@{[NSString stringWithFormat:@"%ld", count] : @(cid)}];
            }
            resultDict[mDescription] = resultA;
            [resultArray addObject:resultDict];
        }
        [_shareInstance.database close];
    }
    return resultArray;
}

// 按类别查询正确和错误的数量
+ (NSInteger)searchCountWithResultType:(ResultType)type categoryType:(CategoryType)categoryType
{
    NSInteger count = 0;
    [self initClass];
    if ([_shareInstance.database open]) {
        FMResultSet *resultSet = nil;
        if (type == ResultTypeRight) {
            resultSet = [_shareInstance.database executeQueryWithFormat:@"SELECT COUNT(*) FROM subject_table WHERE category=%ld AND result=%ld", categoryType, type];
        } else {
            resultSet = [_shareInstance.database executeQueryWithFormat:@"SELECT COUNT(*) FROM subject_table WHERE category=%ld AND result<%d", categoryType, 0];
        }
        while ([resultSet next]) {
            count = [resultSet intForColumnIndex:0];
        }
        [_shareInstance.database close];
    }
    return count;
}

// 按类别查询正确和错误的数据
+ (NSMutableArray *)searchModelArrayWithResultType:(ResultType)type categoryType:(CategoryType)categoryType
{
    NSMutableArray *resultArray = [NSMutableArray array];
    [self initClass];
    if ([_shareInstance.database open]) {
        FMResultSet *resultSet = nil;
        if (type == ResultTypeRight) {
            resultSet = [_shareInstance.database executeQueryWithFormat:@"SELECT categoryId FROM subject_table WHERE category=%ld AND result=%ld", categoryType, type];
        } else {
            resultSet = [_shareInstance.database executeQueryWithFormat:@"SELECT categoryId FROM subject_table WHERE category=%ld AND result<%d", categoryType, 0];
        }
        while ([resultSet next]) {
            NSInteger categoryId = [resultSet intForColumnIndex:0];
            [resultArray addObject:@(categoryId)];
        }
        [_shareInstance.database close];
    }
    return resultArray;
}

// 更新答题结果
+ (void)updateResultWithCid:(NSInteger)cid resultType:(ResultType)type
{
    [self initClass];
    if ([_shareInstance.database open]) {
        FMResultSet *resultSet = [_shareInstance.database executeQueryWithFormat:@"SELECT result FROM subject_table WHERE cid=%ld", cid];
        NSInteger resultType = 0;
        while ([resultSet next]) {
            resultType = [resultSet intForColumnIndex:0];
        }
        [_shareInstance.database executeUpdateWithFormat:@"UPDATE subject_table SET result=%ld WHERE cid=%ld", type == ResultTypeError ? (resultType == ResultTypeRight ? 0 : resultType) - 1 : type, cid];
        [_shareInstance.database close];
    }
}

+ (BOOL)updatePreferWithCid:(NSInteger)cid prefer:(BOOL)prefer
{
    BOOL success = NO;
    [self initClass];
    if ([_shareInstance.database open]) {
        success = [_shareInstance.database executeUpdateWithFormat:@"UPDATE subject_table SET prefer=%d WHERE cid=%ld", prefer, cid];
        [_shareInstance.database close];
    }
    return success;
}

+ (NSArray *)generateExaminationPageWithCategoryType:(CategoryType)type
{
    [self initClass];
    if ([_shareInstance.database open]) {
        NSArray *mDescriptionArray = type == CategoryTypeSubjectOne ? @[@"第1章 道路交通安全法律、法规和规章", @"第2章 道路交通信号", @"第3章 安全行车、文明驾驶基础知识", @"第4章 机动车驾驶操作相关基础知识", @"2015年科目一新增试题"] : @[@"第1章 违法行为综合判断与案例分析", @"第2章 安全行车常识", @"第3章 常见交通标志、标线和交警手势信号辨识", @"第4章 驾驶职业道德和文明驾驶常识", @"第5章 恶劣气候和复杂道路条件下驾驶常识", @"第6章 紧急情况下避险常识", @"第7章 交通事故救护及常见危化品处置常识", @"2015年科目四新增加试题"];
        NSArray *limitArray = type == CategoryTypeSubjectOne ? @[@30, @30, @20, @10, @10] : @[@2, @9, @8, @7, @9, @7, @3, @5];
        NSMutableArray *dataArray = [NSMutableArray array];
        for (NSInteger i = 0; i < mDescriptionArray.count; i++) {
            NSString *mDescription = mDescriptionArray[i];
            FMResultSet *resultSet = [_shareInstance.database executeQueryWithFormat:@" SELECT categoryId FROM subject_table WHERE mDescription=%@ ORDER BY RANDOM() LIMIT %ld", mDescription, ((NSNumber *)limitArray[i]).integerValue];
            while ([resultSet next]) {
                NSInteger categoryId = [resultSet intForColumnIndex:0];
                [dataArray addObject:@(categoryId)];
            }
        }
        [_shareInstance.database close];
        [dataArray sortUsingComparator:^NSComparisonResult(NSNumber *obj1, NSNumber *obj2) {
            return [obj1 compare:obj2];
        }];
        NSMutableArray *newDataArray = [NSMutableArray array];
        for (NSInteger i = 0; i < dataArray.count; i++) {
            [newDataArray addObject:@{[NSString stringWithFormat:@"%li", (i + 1)] : dataArray[i]}];
        }
        
        return @[@{type == CategoryTypeSubjectOne ? @"科目一 模拟考试" : @"科目四 模拟考试" : newDataArray}];
    }
    return nil;
}

//+ (void)requestSubjectDataFromServerWithCategory:(CategoryType)type
//{
//    [self initClass];
//    
//    NSString *urlString = type == CategoryTypeSubjectOne ? @"/tiku/kemu1/query" : (type == CategoryTypeSubjectFour ? @"/tiku/kemu4/query" : @"/tiku/shitiku/query");
//    [MobAPI sendRequestWithInterface:urlString param:@{@"key" : AppKey, @"page" : @"1", @"size" : @"1"} onResult:^(MOBAResponse *response) {
//        
//        if (!response.error) {
//            NSString *total = response.responder[@"result"][@"total"];
//            NSInteger localTotal = [self searchTotalCountWithCategoryType:type];
//            if (total.integerValue != localTotal) {
//                
//                [MobAPI sendRequestWithInterface:urlString param:@{@"key" : AppKey, @"page" : @"1", @"size" : @"1500"} onResult:^(MOBAResponse *response) {
//                    
//                    if (!response.error) {
//                        [SubjectOneModel faf_setupReplacedKeyFromPropertyName:^NSDictionary *{ return @{@"cid" : @"id", @"question" : @"title", @"imgUrl" : @"file", @"answer" : @"val"};}];
//                        NSArray *modelArray = [SubjectOneModel faf_objectArrayWithKeyValuesArray:response.responder[@"result"][@"list"]];
//                        for (NSInteger i = 0; i < modelArray.count; i++) {
//                            SubjectOneModel *model = modelArray[i];
//                            [self updateSubjectDataWithModel:model index:(i+1)];
//                        }
//                        
//                        // 更新类别
//                        NSString *categoryUrlString = @"/tiku/shitiku/query";
//                        NSArray *cidArray = type == CategoryTypeSubjectOne ? @[@183, @184, @185, @186, @207] : @[@193, @195, @197, @199, @201, @203, @205, @208];
//                        NSArray *mDescriptionArray = type == CategoryTypeSubjectOne ? @[@"道路交通安全法律、法规和规章", @"道路交通信号", @"安全行车、文明驾驶基础知识", @"机动车驾驶操作相关基础知识", @"2015年科目一新增试题"] : @[@"违法行为综合判断与案例分析", @"安全行车常识", @"常见交通标志、标线和交警手势信号辨识", @"驾驶职业道德和文明驾驶常识", @"恶劣气候和复杂道路条件下驾驶常识", @"紧急情况下避险常识", @"2015年科目四新增加试题"];
//                        for (NSInteger i = 0; i < cidArray.count; i++) {
//                            
//                            NSNumber *cid = cidArray[i];
//                            [MobAPI sendRequestWithInterface:categoryUrlString param:@{@"key" : AppKey, @"cid" : cid, @"page" : @"1", @"size" : @"1000"} onResult:^(MOBAResponse *response) {
//                                [SubjectOneModel faf_setupReplacedKeyFromPropertyName:^NSDictionary *{ return @{@"cid" : @"id", @"question" : @"title", @"imgUrl" : @"file", @"answer" : @"val"};}];
//                                NSArray *modelArray = [SubjectOneModel faf_objectArrayWithKeyValuesArray:response.responder[@"result"][@"list"]];
//                                for (SubjectOneModel *model in modelArray) {
//                                    [self updateMDescriptionWithModelId:model.cid mDescription:mDescriptionArray[i]];
//                                }
//                            }];
//                        }
//                    }
//                    
//                }];
//            }
//        }
//    }];
//}

+ (void)requestSubjectDataFromServerWithCategory:(CategoryType)type index:(NSInteger)index
{
    [self initClass];
    
    /**
     临时代码-----导入正确的问题列表
     */
//    FMResultSet *resultSet = [_shareInstance.database executeQueryWithFormat:@"SELECT cid, question FROM subject_table"];
//    NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
//    while ([resultSet next]) {
//        NSInteger cid = [resultSet intForColumnIndex:0];
//        NSString *question = [resultSet stringForColumnIndex:1];
//        resultDict[[NSString stringWithFormat:@"%ld", cid]] = question;
//    }
//    
//    [resultDict writeToFile:@"/Users/iecd/Desktop/questionList.plist" atomically:YES];
    
    
    NSMutableDictionary *finishDict = [NSMutableDictionary dictionaryWithContentsOfFile:_shareInstance.finishPath] ?: [NSMutableDictionary dictionary];
    NSString *key = (type == CategoryTypeSubjectOne) ? @"kemu1" : @"kemu4";
    if (finishDict[key]) {
        if ([_shareInstance.database open]) {
            
            FMResultSet *resultSet = [_shareInstance.database executeQueryWithFormat:@"SELECT cid FROM subject_table WHERE question like '%%...%%'"];
            NSMutableArray *cidArray = [NSMutableArray array];
            while ([resultSet next]) {
                [cidArray addObject:[NSString stringWithFormat:@"%d", [resultSet intForColumnIndex:0]]];
            }
            if (cidArray.count > 0) {
                NSDictionary *questionListDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"questionList" ofType:@"plist"]];
                for (NSString *cid in cidArray) {
                    NSString *question = questionListDict[cid];
                    if (question) {
                        [_shareInstance.database executeUpdateWithFormat:@"UPDATE subject_table SET question=%@ WHERE cid=%@", question, cid];
                    }
                }
            }
            [_shareInstance.database close];
        }
        return;
    }
    
    NSString *categoryUrlString = @"/tiku/shitiku/query";
    NSArray *cidArray = type == CategoryTypeSubjectOne ? @[@183, @184, @185, @186, @207] : @[@193, @195, @197, @199, @201, @203, @205, @208];
    NSArray *mDescriptionArray = type == CategoryTypeSubjectOne ? @[@"第1章 道路交通安全法律、法规和规章", @"第2章 道路交通信号", @"第3章 安全行车、文明驾驶基础知识", @"第4章 机动车驾驶操作相关基础知识", @"2015年科目一新增试题"] : @[@"第1章 违法行为综合判断与案例分析", @"第2章 安全行车常识", @"第3章 常见交通标志、标线和交警手势信号辨识", @"第4章 驾驶职业道德和文明驾驶常识", @"第5章 恶劣气候和复杂道路条件下驾驶常识", @"第6章 紧急情况下避险常识", @"第7章 交通事故救护及常见危化品处置常识", @"2015年科目四新增加试题"];
    static NSInteger total = 0;
    if (index == cidArray.count) {
        NSString *urlString = type == CategoryTypeSubjectOne ? @"/tiku/kemu1/query" : (type == CategoryTypeSubjectFour ? @"/tiku/kemu4/query" : @"/tiku/shitiku/query");
        
        [MobAPI sendRequestWithInterface:urlString param:@{@"key" : AppKey, @"page" : @"1", @"size" : @"1500"} onResult:^(MOBAResponse *response) {

            if (!response.error) {
                [SubjectOneModel faf_setupReplacedKeyFromPropertyName:^NSDictionary *{ return @{@"cid" : @"id", @"question" : @"title", @"imgUrl" : @"file", @"answer" : @"val"};}];
                NSArray *modelArray = [SubjectOneModel faf_objectArrayWithKeyValuesArray:response.responder[@"result"][@"list"]];
                for (NSInteger i = 0; i < modelArray.count; i++) {
                    if (i == 0) {
                        total++;
                    }
                    SubjectOneModel *model = modelArray[i];
                    BOOL success = [self updateSubjectDataWithModel:model category:type index:(total) mDescription:mDescriptionArray.lastObject];
                    if (success) {
                        total++;
                    }
                }
                finishDict[key] = @(1);
                [finishDict writeToFile:_shareInstance.finishPath atomically:YES];
                [self requestSubjectDataFromServerWithCategory:type index:index + 1];
            }
        }];
        return;
    }
    NSNumber *cid = cidArray[index];
    [MobAPI sendRequestWithInterface:categoryUrlString param:@{@"key" : AppKey, @"cid" : cid, @"page" : @"1", @"size" : @"1000"} onResult:^(MOBAResponse *response) {
        
        if (!response.error) {
            [SubjectOneModel faf_setupReplacedKeyFromPropertyName:^NSDictionary *{ return @{@"cid" : @"id", @"question" : @"title", @"imgUrl" : @"file", @"answer" : @"val"};}];
            NSArray *modelArray = [SubjectOneModel faf_objectArrayWithKeyValuesArray:response.responder[@"result"][@"list"]];
            for (NSInteger i = 0; i < modelArray.count; i++) {
                SubjectOneModel *model = modelArray[i];
                total++;
                [self updateSubjectDataWithModel:model category:type index:(total) mDescription:mDescriptionArray[index]];
            }
            [self requestSubjectDataFromServerWithCategory:type index:index + 1];
        }
    }];
}

#pragma mark -内部方法
+ (BOOL)updateSubjectDataWithModel:(SubjectOneModel *)model category:(CategoryType)category index:(NSInteger)index  mDescription:(NSString *)mDescritpion
{
    BOOL success = NO;
    SubjectOneModel *subject = [self searchDataFromLocalDataBaseWithModel:model];
    
    if (subject) { // 已存在
        
    } else { // 不存在
        success = [self insertOneNewRecordWithModel:model category:category index:index mDescription:mDescritpion];
    }
    
    return success;
    
}

+ (BOOL)insertOneNewRecordWithModel:(SubjectOneModel *)model category:(CategoryType)category index:(NSInteger)index mDescription:(NSString *)mDescritpion
{
    BOOL success = NO;
    
    if ([_shareInstance.database open]) {
        SubjectType type;
        if (category == CategoryTypeSubjectOne) {
            type = model.c.length > 0 ? (model.answer.integerValue > 1 ? SubjectTypeMultiSelect : SubjectTypeSingleSelect) : SubjectTypeJudge;
        } else {
            type = model.answer.length > 1 ? SubjectTypeMultiSelect : SubjectTypeSingleSelect;
            if (model.c == nil) {
                type = SubjectTypeJudge;
                model.a = @"正确";
                model.b = @"错误";
                model.answer = [model.answer isEqualToString:@"0"] ? @"2" : model.answer;
            }
            if (type != SubjectTypeJudge) {
                if (model.answer.integerValue == 0) {
                    BOOL continueWhile = YES;
                    NSInteger index = 0;
                    NSString *answer = @"";
                    while (continueWhile) {
                        NSString *item = [model.answer substringWithRange:NSMakeRange(index++, 1)];
                        NSString *itemAnswer;
                        if ([item isEqualToString:@"A"]) {
                            itemAnswer = @"1";
                        } else if ([item isEqualToString:@"B"]) {
                            itemAnswer = @"2";
                        } else if ([item isEqualToString:@"C"]) {
                            itemAnswer = @"3";
                        } else if ([item isEqualToString:@"D"]) {
                            itemAnswer = @"4";
                        }
                        answer = [answer stringByAppendingString:itemAnswer];
                        if (index >= model.answer.length) {
                            continueWhile = NO;
                        }
                    }
                    model.answer = answer;
                }
            }
        }
        success = [_shareInstance.database executeUpdateWithFormat:@"INSERT INTO subject_table (cid, category, type, question, a, b, c, d, explain, imgUrl, answer, categoryId, mDescription) VALUES(%ld, %ld, %ld, %@, %@, %@, %@, %@, %@, %@, %ld, %ld, %@)", model.cid, category, type, model.question, model.a ?: @"正确", model.b ?: @"错误", model.c, model.d, model.explainText, model.imgUrl, type == SubjectTypeJudge ? 2 - model.answer.integerValue : model.answer.integerValue, index, mDescritpion];
        [_shareInstance.database close];
    }
    
    return success;
}

+ (SubjectOneModel *)searchDataFromLocalDataBaseWithModel:(SubjectOneModel *)model
{
    SubjectOneModel *subject = nil;
    
    if ([_shareInstance.database open]) {
        FMResultSet *resultSet = [_shareInstance.database executeQueryWithFormat:@"SELECT * FROM subject_table WHERE cid=%ld", model.cid];
        NSArray *resultArray = [self getbackModelArrayWithResultSet:resultSet];
        if (resultArray.count > 0) {
            subject = resultArray.firstObject;
        }
        [_shareInstance.database close];
    }
    
    return subject;
}

+ (NSMutableArray *)getbackModelArrayWithResultSet:(FMResultSet *)resultSet
{
    NSMutableArray *resultArray = [NSMutableArray array];
    while ([resultSet next]) {
        SubjectOneModel *model = [[SubjectOneModel alloc] init];
        model.cid = [resultSet intForColumn:@"cid"];
        model.question = [resultSet stringForColumn:@"question"];
        model.imgUrl = [resultSet stringForColumn:@"imgUrl"];
        model.a = [resultSet stringForColumn:@"a"];
        model.b = [resultSet stringForColumn:@"b"];
        model.c = [resultSet stringForColumn:@"c"];
        model.d = [resultSet stringForColumn:@"d"];
        model.explainText = [resultSet stringForColumn:@"explain"];
        model.answer = [resultSet stringForColumn:@"answer"];
        model.type = [resultSet intForColumn:@"type"];
        model.category = [resultSet intForColumn:@"category"];
        model.mDescription = [resultSet stringForColumn:@"mDescription"];
        model.prefer = [resultSet boolForColumn:@"prefer"];
        model.result = [resultSet intForColumn:@"result"];
        model.categoryId = [resultSet intForColumn:@"categoryId"];
        [resultArray addObject:model];
    }
    return resultArray;
}

#pragma mark -私有方法
+ (void)initClass
{
    if (_shareInstance == nil) {
        _shareInstance = [[SubjectDataBaseTool alloc] init];
    }
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareInstance = [super allocWithZone:nil];
        [_shareInstance setupInitValue];
    });
    return _shareInstance;
}

- (void)setupInitValue
{
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"database"];
    [[NSFileManager defaultManager] createDirectoryAtPath:docDir withIntermediateDirectories:YES attributes:nil error:nil];
    _finishPath = [docDir stringByAppendingPathComponent:@"finish.plist"];
    NSString *filePath = [docDir stringByAppendingPathComponent:@"data.sqlite"];
    
    FMDatabase *database = [FMDatabase databaseWithPath:filePath];
    if ([database open]) {
        [database executeUpdate:@"CREATE TABLE IF NOT EXISTS subject_table (cid integer, category integer, type integer, mDescription text, question text, a text, b text, c text, d text, explain text, imgUrl text, answer integer, prefer blean, result integer, categoryId integer);"];
    }
    _shareInstance.database = database;
}

@end
