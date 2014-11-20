//
//  TYLocationInfo.m
//  GourmetDiary
//
//  Created by Tomohiko on 2014/11/20.
//  Copyright (c) 2014年 yamatomo. All rights reserved.
//

#import "TYLocationInfo.h"

@implementation TYLocationInfo {
  CLLocationManager *_locationManager;
  double _lat;//緯度
  double _lng;//経度
}

static TYLocationInfo *sharedData = nil;

+ (id)sharedManager
{
  @synchronized(self) {
    if (sharedData == nil) {
      sharedData = [[self alloc] init];
    }
  }
  return self;
}

- (id)init
{
  LOG()
  self = [super init];
  [self start];
  return self;
}

- (void)start
{
  if ([CLLocationManager locationServicesEnabled]) {
    LOG()
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    
    // iOS8未満は、このメソッドは無い
    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
    LOG()
      [_locationManager requestWhenInUseAuthorization];
    }
    [_locationManager startUpdatingLocation];
  }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
  CLLocation *currentLocation = locations.lastObject;
  _lat = currentLocation.coordinate.latitude;//緯度
  _lng = currentLocation.coordinate.longitude;//経度
//  LOG(@"lat %f", _lat)
//  LOG(@"lng %f", _lng)

}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
  LOG(@"error:%@", error)
}

- (NSArray *)getLocationValue
{
  LOG()
  NSArray *ary = @[
                   [[NSNumber alloc] initWithDouble:_lng],
                   [[NSNumber alloc] initWithDouble:_lat],
                   ];
  return ary;
}


@end
