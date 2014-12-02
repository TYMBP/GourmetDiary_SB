//
//  TYUtil.h
//  GourmetDiary
//
//  Created by Tomohiko on 2014/11/14.
//  Copyright (c) 2014年 yamatomo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TYUtil : NSObject

+ (NSString *)checkKeyword:(NSString *)keyword;
+ (NSString *)checkInputTextMax:(NSString *)keyword;
+ (NSString *)checkLength:(NSString *)word;
+ (NSString *)setSituationPickerText:(NSNumber *)para;
+ (NSString *)setLevelPickerText:(NSNumber *)para;
+ (NSString *)setFeePickerText:(NSNumber *)para;
+ (NSString *)setLevelTableText:(NSNumber *)para;

@end
