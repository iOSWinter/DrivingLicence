//
//  SubjectOneModel.h
//  DrivingLicence
//
//  Created by WinterChen on 16/9/14.
//  Copyright © 2016年 win. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    SubjectTypeSingleSelect = 1,
    SubjectTypeMultiSelect,
    SubjectTypeJudge,
} SubjectType;

typedef enum : NSUInteger {
    CategoryTypeSubjectOne = 1,
    CategoryTypeSubjectFour,
} CategoryType;

// 错误用负数表示
typedef enum : NSInteger {
    ResultTypeDefault = 0,
    ResultTypeRight,
    ResultTypeError,
} ResultType;

@interface SubjectOneModel : NSObject

@property (nonatomic, assign) NSInteger cid;
@property (nonatomic, strong) NSString *question;
@property (nonatomic, strong) NSString *imgUrl;
@property (nonatomic, strong) NSString *a;
@property (nonatomic, strong) NSString *b;
@property (nonatomic, strong) NSString *c;
@property (nonatomic, strong) NSString *d;
@property (nonatomic, strong) NSString *explainText;
@property (nonatomic, strong) NSString *answer;

@property (nonatomic, assign) NSInteger mid;
@property (nonatomic, assign) SubjectType type;
@property (nonatomic, assign) CategoryType category;
@property (nonatomic, strong) NSString *mDescription;
@property (nonatomic, assign) BOOL prefer;
@property (nonatomic, assign) ResultType result;
@property (nonatomic, assign) NSInteger categoryId;

@end
