//
//  TYApplication.h
//  GourmetDiary
//
//  Created by Tomohiko on 2014/11/09.
//  Copyright (c) 2014年 yamatomo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYURLOperation.h"
#import <CoreLocation/CoreLocation.h>
#import "TYGourmetDiaryManager.h"

@interface TYApplication : NSObject <CLLocationManagerDelegate>

@property (strong, readonly, nonatomic) TYGourmetDiaryManager *gourmetDiaryManager;

+ (id)application;
- (void)addURLOperation:(TYURLOperation *)urlOperation;
- (NSArray *)getLocation;
- (void)startLocation;

@end
