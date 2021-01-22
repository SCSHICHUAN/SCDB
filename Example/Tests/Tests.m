//
//  SCDBTests.m
//  SCDBTests
//
//  Created by scshichuan on 01/19/2021.
//  Copyright (c) 2021 scshichuan. All rights reserved.
//

#import "SCdb.h"

@import XCTest;

@interface Tests : XCTestCase

@end

@interface Model : NSObject

@property NSString *name;
@property NSInteger age;

@end

@implementation Model
@end


@implementation Tests

- (void)setUp
{
    [super setUp];
    /*SCDB Example*/
    
    Model *model = [[Model alloc] init];
    model.name = @"石川";
    model.age = 30;
    NSArray *array;
        

    //1. creat db
   [SCdb CreateTableWithClass:[Model class]];
        
   //2. insert oc object
   [SCdb insertModes:@[model]];
                         
   //3. read oc object
   array = [SCdb selectClass:[Model class] andProperty:@"name" andWhere:Nil];
        
        
    for (Model *model in array) {
        NSLog(@"[name:%@,heigit:%ld]",model.name,(long)model.age);
    }
    
    
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
//    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

@end

