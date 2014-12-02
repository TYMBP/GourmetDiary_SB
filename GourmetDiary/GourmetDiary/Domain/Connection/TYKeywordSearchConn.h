//
//  TYKeywordSearch.h
//  GourmetDiary
//
//  Created by Tomohiko on 2014/11/14.
//  Copyright (c) 2014年 yamatomo. All rights reserved.
//

#import "TYURLOperation.h"

@interface TYKeywordSearchConn : TYURLOperation

//- (id)initWithTarget:(id)target selector:(SEL)selector para:(NSMutableDictionary *)para;
- (id)initWithTarget:(id)target selector:(SEL)selector para:(NSMutableDictionary *)para set:(NSInteger)set;

@end
