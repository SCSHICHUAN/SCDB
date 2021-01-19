//
//  SCdb.m
//  VOLVO
//
//  Created by yonyou on 2020/7/28.
//  Copyright © 2020 mac. All rights reserved.
//

#import "SCdb.h"
#import "FMDB.h"


@interface SCdb()
@property (nonatomic,strong)FMDatabaseQueue *dbQ;
@end

@implementation SCdb

+(instancetype)shareSCdb{
    static dispatch_once_t onceToken;
    static SCdb *db;
    dispatch_once(&onceToken, ^{
        db = [[SCdb alloc] init];
    });
    return db;
}

/*
 获取数据库
 */
+ (FMDatabase *)getDatabase
{
    return [FMDatabase databaseWithPath:[SCdb dbPath]];
}


/*
 创建obj表
 根据model创建表
 以model的类名为表名
 以model的属性作为列
 */
+(BOOL)CreateTableWithClass:(Class)modelClass
{
    
    NSString *sqlStr = [SCdb CreateTableSqlString:modelClass];
    
    FMDatabase *db = [SCdb getDatabase];
    if ([db open]) {
        BOOL result = [db executeUpdate:sqlStr];
        [db close];
        if (result) {
            NSLog(@"建表成功");
            return YES;
        } else {
            NSLog(@"建表失败");
            return NO;
        }
    }else{
        return NO;
    }
}


/*
 插入obj
 */
+(BOOL)insertModes:(NSArray*)models
{
    __block BOOL b = NO;
    if (models) {
        
        SCdb *db = [SCdb shareSCdb];
        __block SCdb *dbB = db;
        
        if (models.count>0 && [db dbOpen]) {
            
            [db.dbQ inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
                
                for (id obj in models) {
                    
                    NSString *sqlStr =[SCdb insterSqlStr:obj][@"sqlStr"];
                    NSArray *valuesArray =[SCdb insterSqlStr:obj][@"values"];
                    
                    BOOL success = [db executeUpdate:sqlStr withArgumentsInArray:valuesArray];
                    if (success) {
                        NSLog(@"sc插入成功");
                        b = YES;
                    }else{
                        NSLog(@"sc插入失败");
                        b = NO;
                    }
                }
            }];
            [dbB dbClose];
        }
    }
    return b;
}



/*
 筛选obj
 */
+(NSMutableArray*)selectClass:(Class)modelClass andProperty:(NSString*__nullable)pro andWhere:(NSString*__nullable)condition
{
    NSMutableArray *array = [NSMutableArray array];
    NSString *tableName = NSStringFromClass(modelClass);
    
    if (!tableName || [tableName isEqualToString:@""]) {
        return array;
    }
    
    SCdb *db = [SCdb shareSCdb];
    
    NSString *sqlStr = [NSString stringWithFormat:@"select * from %@",tableName];
    
    if (!(pro == nil || condition == nil ||
          [pro isEqualToString:@""] ||
          [condition isEqualToString:@""])) {
        
        sqlStr = [NSString stringWithFormat:@"select * from %@ where %@ = %@",tableName,pro,condition];
    }
    
    
    
    __block SCdb *dbB = db;
    if ([db dbOpen]) {
        
        [db.dbQ inDatabase:^(FMDatabase * _Nonnull db) {
            FMResultSet *resultSet = [db executeQuery:sqlStr];
            while ([resultSet next]) {
                
                unsigned int count = 0;
                objc_property_t *propertyList =  class_copyPropertyList(modelClass, &count);
                NSString *key = @"key";
                NSString *value = @"value";
                
                id obj = [[modelClass alloc] init];
                for(int i=0;i<count;i++)
                {
                    //取出每一个属性
                    objc_property_t property = propertyList[i];
                    const char* propertyName = property_getName(property);
                    key = [[NSString alloc] initWithCString:propertyName encoding:NSUTF8StringEncoding];
                    value = [resultSet stringForColumn:key];
                    
                    if (value) {
                        [obj setValue:value forKey:key];
                    }
                    
                }
                [array addObject:obj];
            }
        }];
        [dbB dbClose];
        return array;
    }else{
        return array;
    }
}


/*
 清空表
 */
+(BOOL)clearTable:(Class)className
{
    NSString *tableName = NSStringFromClass(className);
    NSString *sqlStr = [NSString stringWithFormat:@"DELETE FROM %@",tableName];
    NSString *sqlStr2 = [NSString stringWithFormat:@"UPDATE sqlite_sequence set seq=0 where name='%@'",tableName];
    BOOL b = NO;
    FMDatabase *db = [self getDatabase];
    
    
    if ([db open]) {
        b =  [db executeUpdate:sqlStr];
        b =  [db executeUpdate:sqlStr2];
        [db close];
        return b;
    }else{
        return b;
    }
}
-(BOOL)dbOpen
{
    __block BOOL b;
    [self.dbQ inDatabase:^(FMDatabase * _Nonnull db) {
        b = [db open];
    }];
    return b;
}
-(BOOL)dbClose
{
    __block BOOL b;
    [self.dbQ inDatabase:^(FMDatabase * _Nonnull db) {
        b = [db close];
    }];
    return b;
}

-(FMDatabaseQueue *)dbQ
{
    if (!_dbQ) {
        _dbQ = [FMDatabaseQueue databaseQueueWithPath:[SCdb dbPath]];
    }
    return _dbQ;
}





/*
 数据库path
 */
+(NSString*)dbPath
{
    //获取程序的名字
    NSString *dbName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    dbName =  [dbName stringByAppendingString:@".sqlite"];
    //拼接数据库存储路径
    NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = docPaths.firstObject;
    NSString *filePath = [docPath stringByAppendingPathComponent:dbName];
    NSLog(@"docpath = %@",docPath);
    return filePath;
}
/*
 建表sql
 */
+(NSString*)CreateTableSqlString:(Class)class
{
    NSString *tableName = NSStringFromClass(class);
    unsigned int count = 0;
    //获取属性的列表
    objc_property_t *propertyList =  class_copyPropertyList(class, &count);
    NSString *sqlStr = [NSString stringWithFormat:@"create table if not exists %@ (id integer primary key autoincrement,",tableName];
    for(int i=0;i<count;i++)
    {
        //取出每一个属性
        objc_property_t property = propertyList[i];
        const char* propertyName = property_getName(property);
        NSString *proName = [[NSString alloc] initWithCString:propertyName encoding:NSUTF8StringEncoding];
        
        //获取属性类型
        char *attr = property_copyAttributeValue(property, "T");
        NSString *type =  [NSString stringWithUTF8String:attr];
        //oc 类型转换为 sql 类型的
        if ([type isEqualToString:@"q"]||[type isEqualToString:@"i"]||[type isEqualToString:@"I"]) {
            type = @"integer";
        }else if([type isEqualToString:@"f"] || [type isEqualToString:@"d"]){
            type = @"real";
        }else if([type isEqualToString:@"B"]){
            type = @"boolean";
        }else{
            type = @"text";
        }
        
        sqlStr = [sqlStr stringByAppendingFormat:@"%@ %@,",proName,type];
    }
    sqlStr = [sqlStr substringToIndex:[sqlStr length]-1];
    sqlStr = [sqlStr stringByAppendingString:@")"];
    return sqlStr;
}



/*
 插入的sqlStr
 */
+(NSDictionary*)insterSqlStr:(id)obj
{
    Class modelClass = object_getClass(obj);
    NSString *tableName = NSStringFromClass(modelClass);
    unsigned int count = 0;
    objc_property_t *pros = class_copyPropertyList(modelClass, &count);
    
    //拼接sql
    NSString *sqlStr = [NSString stringWithFormat:@" insert into %@ (",tableName];
    NSString *valueStr = @" values(";
    NSMutableArray *valuesArray = [NSMutableArray array];
    
    //获取obj的属性和value
    for (int i = 0; i < count; i++) {
        
        objc_property_t pro = pros[i];
        NSString *proName = [NSString stringWithFormat:@"%s", property_getName(pro)];
        id value = [obj valueForKey:proName];
        if (value == nil) {
            value = @"";
        }
        [valuesArray addObject:value];
        sqlStr =  [sqlStr stringByAppendingFormat:@"%@,",proName];
        valueStr = [valueStr stringByAppendingString:@"?,"];
        
    }
    free(pros);
    
    sqlStr = [sqlStr substringToIndex:[sqlStr length]-1];
    sqlStr = [sqlStr stringByAppendingString:@")"];
    valueStr = [valueStr substringToIndex:[valueStr length]-1];
    valueStr = [valueStr stringByAppendingString:@")"];
    
    sqlStr = [sqlStr stringByAppendingString:valueStr];
    
    return @{@"sqlStr":sqlStr,@"values":valuesArray};
}
@end
