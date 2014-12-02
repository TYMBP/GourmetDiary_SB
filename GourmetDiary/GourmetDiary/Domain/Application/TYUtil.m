//
//  TYUtil.m
//  GourmetDiary
//
//  Created by Tomohiko on 2014/11/14.
//  Copyright (c) 2014年 yamatomo. All rights reserved.
//

#import "TYUtil.h"

@implementation TYUtil

+ (NSString *)checkKeyword:(NSString *)keyword
{
  if (keyword.length >= 20) {
    return @"キーワードは 20文字までで入力してください";
  }
  return nil;
}

+ (NSString *)checkLength:(NSString *)word
{
  if (word.length >= 100) {
    return @"キーワードは 100文字までで入力してください";
  }
  return nil;
}

+ (NSString *)checkInputTextMax:(NSString *)keyword
{
  if (keyword.length >= 256) {
    return @"キーワードは 256文字までで入力してください";
  }
  return nil;
}

+ (NSString *)setSituationPickerText:(NSNumber *)para
{
  NSString *text;
  NSInteger i = [para integerValue];
  
  switch (i) {
    case 1:
      text = @"朝ごはん";
      break;
    case 2:
      text = @"昼ごはん";
      break;
    case 3:
      text = @"夜ごはん";
      break;
    case 4:
      text = @"お茶のじかん";
      break;
    case 5:
      text = @"お酒のじかん";
      break;
    case 6:
      text = @"持ちかえり";
      break;
    case 7:
      text = @"OTHER";
      break;
      
    default:
      break;
  }
  return text;
}

+ (NSString *)setLevelPickerText:(NSNumber *)para
{
  NSString *text;
  NSInteger i = [para integerValue];
  
  switch (i) {
    case 1:
      text = @"うーん1点";
      break;
    case 2:
      text = @"もうちょい2点";
      break;
    case 3:
      text = @"まあまあ3点";
      break;
    case 4:
      text = @"まずまず4点";
      break;
    case 5:
      text = @"うまい！5点";
      break;
    case 6:
      text = @"殿堂入り店！";
      break;
      
    default:
      break;
  }
  return text;
}

+ (NSString *)setLevelTableText:(NSNumber *)para
{
  NSString *text;
  NSInteger i = [para integerValue];
  
  switch (i) {
    case 1:
      text = @"★";
      break;
    case 2:
      text = @"★★";
      break;
    case 3:
      text = @"★★★";
      break;
    case 4:
      text = @"★★★★";
      break;
    case 5:
      text = @"★★★★★";
      break;
    case 6:
      text = @"殿堂店";
      break;
      
    default:
      break;
  }
  return text;
}

+ (NSString *)setFeePickerText:(NSNumber *)para
{
  NSString *text;
  NSInteger i = [para integerValue];
  
  switch (i) {
    case 1:
      text = @"500円しない";
      break;
    case 2:
      text = @"500円〜1,000円くらい";
      break;
    case 3:
      text = @"1,000円〜2,000円くらい";
      break;
    case 4:
      text = @"2,000円〜3,000円くらい";
      break;
    case 5:
      text = @"3,000円〜4,000円くらい";
      break;
    case 6:
      text = @"4,000円〜5,000円くらい";
      break;
    case 7:
      text = @"5,000円〜10,000円だったかな";
      break;
    case 8:
      text = @"10,000円以上だった...";
      break;
      
    default:
      break;
  }
  return text;
}

@end
