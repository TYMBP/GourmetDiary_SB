//
//  TYUtil.m
//  GourmetDiary
//
//  Created by Tomohiko on 2014/11/14.
//  Copyright (c) 2014年 yamatomo. All rights reserved.
//

#import "TYUtil.h"

@implementation TYUtil

+ (NSArray *)levelList
{
  NSArray *ary = @[@"", @"★", @"★★", @"★★★", @"★★★★", @"★★★★★", @"★★殿堂★★"];
  return ary;
}

+ (NSArray *)situationList
{
  NSArray *ary = @[@"", @"朝ごはん", @"昼ごはん", @"夜ごはん", @"お茶のじかん", @"お酒のじかん", @"持ちかえり", @"OTHER"];
  return ary;
}

+ (NSArray *)personList
{
  NSArray *ary = @[@"", @"1人", @"2人", @"3人", @"4人", @"5人〜9人", @"10人以上"];
  return ary;
}

+ (NSArray *)feeList
{
  NSArray *ary = @[@"", @"500円以内", @"500〜1,000円", @"1,000〜2,000円", @"2,000〜3,000円", @"3,000〜4,000円", @"4,000〜5,000円", @"5,000〜10,000円", @"10,000円以上"];
  return ary;
}

+ (NSArray *)genreList
{
  NSArray *ary = @[@"", @"居酒屋", @"ダイニングバー", @"創作料理", @"和食", @"洋食", @"イタリアン・フレンチ", @"中華", @"焼き肉・韓国料理", @"アジアン", @"各国料理", @"カラオケ・パーティー", @"バー・カクテル", @"ラーメン", @"お好み焼・もんじゃ・鉄板焼き", @"カフェ・スイーツ", @"その他グルメ"];
  return ary;
}

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
      text = @"★★殿堂★★";
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
      text = @"★★殿堂★★";
      break;
      
    default:
      break;
  }
  return text;
}

+ (NSString *)setPersonsText:(NSNumber *)para
{
  NSString *text;
  NSInteger i = [para integerValue];
  
  switch (i) {
    case 1:
      text = @"1人";
      break;
    case 2:
      text = @"2人";
      break;
    case 3:
      text = @"3人";
      break;
    case 4:
      text = @"4人";
      break;
    case 5:
      text = @"5人〜9人";
      break;
    case 6:
      text = @"10人以上";
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
      text = @"500円以内";
      break;
    case 2:
      text = @"500円〜1,000円";
      break;
    case 3:
      text = @"1,000円〜2,000円";
      break;
    case 4:
      text = @"2,000円〜3,000円";
      break;
    case 5:
      text = @"3,000円〜4,000円";
      break;
    case 6:
      text = @"4,000円〜5,000円";
      break;
    case 7:
      text = @"5,000円〜10,000円";
      break;
    case 8:
      text = @"10,000円以上";
      break;
      
    default:
      break;
  }
  return text;
}

@end
