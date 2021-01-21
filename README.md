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


How to use it, As long as three steps:


```

    ViewController *vc = [[ViewController alloc] init];
    vc.name = @"石川";
    NSArray *array;
    

    //1. creat db
    [SCdb CreateTableWithClass:[ViewController class]];
    
    //2. insert oc object 
    [SCdb insertModes:@[vc]];
                     
    //3. read oc object
    array = [SCdb selectClass:[ViewController class] andProperty:@"name" andWhere:Nil];
    
    
    for (ViewController *vc in array) {
        NSLog(@"%@",vc.name);
    }


```



## Author

scshichuan, 573387383@QQ.COM

## License

SCDB is available under the MIT license. See the LICENSE file for more info.
