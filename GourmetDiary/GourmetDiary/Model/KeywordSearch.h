//
//  KeywordSearch.h
//  GourmetDiary
//
//  Created by Tomohiko on 2014/11/20.
//  Copyright (c) 2014年 yamatomo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface KeywordSearch : NSManagedObject

@property (nonatomic, retain) NSString * area;
@property (nonatomic, retain) NSString * genre;
@property (nonatomic, retain) NSString * shop;
@property (nonatomic, retain) NSString * sid;

@end
