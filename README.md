# SCDB

[![CI Status](https://img.shields.io/travis/scshichuan/SCDB.svg?style=flat)](https://travis-ci.org/scshichuan/SCDB)
[![Version](https://img.shields.io/cocoapods/v/SCDB.svg?style=flat)](https://cocoapods.org/pods/SCDB)
[![License](https://img.shields.io/cocoapods/l/SCDB.svg?style=flat)](https://cocoapods.org/pods/SCDB)
[![Platform](https://img.shields.io/cocoapods/p/SCDB.svg?style=flat)](https://cocoapods.org/pods/SCDB)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation



SCDB is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SCDB'
```


## Start, As long as three steps:
### 1.Create table
### 2.Insert models
### 3.Read object


```

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


```

## If you want see the API run,downlod this poriect and run 'Tests'


## Author

scshichuan, 573387383@QQ.COM

## License

SCDB is available under the MIT license. See the LICENSE file for more info.
