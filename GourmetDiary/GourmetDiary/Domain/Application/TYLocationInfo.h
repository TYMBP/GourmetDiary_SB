//
//  TYLocationInfo.h
//  GourmetDiary
//
//  Created by Tomohiko on 2014/11/20.
//  Copyright (c) 2014年 yamatomo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface TYLocationInfo : NSObject<CLLocationManagerDelegate>

- (NSArray *)getLocationValue;
+ (id)sharedManager;
@end
