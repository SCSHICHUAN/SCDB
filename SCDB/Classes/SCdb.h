//
//  SCdb.h
//  VOLVO
//
//  Created by yonyou on 2020/7/28.
//  Copyright © 2020 mac. All rights reserved.
//



#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SCdb : NSObject
/*
创建obj表
 */
+(BOOL)CreateTableWithClass:(Class)modelClass;

/*
插入obj
 */
+(BOOL)insertModes:(NSArray*)models;

/*
筛选obj
 */
+(NSMutableArray*)selectClass:(Class)modelClass andProperty:(NSString*__nullable)pro andWhere:(NSString*__nullable)condition;

/*
 清空obj
 */
+(BOOL)clearTable:(Class)className;
@end

NS_ASSUME_NONNULL_END
