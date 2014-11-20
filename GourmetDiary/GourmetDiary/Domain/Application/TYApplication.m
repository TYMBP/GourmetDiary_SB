//
//  TYApplication.m
//  GourmetDiary
//
//  Created by Tomohiko on 2014/11/09.
//  Copyright (c) 2014年 yamatomo. All rights reserved.
//

#import "TYApplication.h"
#import "TYAppDelegate.h"

@implementation TYApplication {
  NSOperationQueue *_urlOperationQueue;
  CLLocationManager *_locationManager;
  double _lat;//緯度
  double _lng;//経度
}

+ (id)application
{
  LOG()
  return [(TYAppDelegate *)[[UIApplication sharedApplication] delegate] application];
}

- (id)init
{
  LOG()
  self = [super init];
  if (self) {
    _gourmetDiaryManager = [TYGourmetDiaryManager sharedmanager];
    _urlOperationQueue = [[NSOperationQueue alloc] init];
    [_urlOperationQueue addObserver:self forKeyPath:@"operationCount" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
    [self startLocation];
  }
//  //位置情報
//  if ([CLLocationManager locationServicesEnabled]) {
//    LOG()
//    _locationManager = [[CLLocationManager alloc] init];
//    _locationManager.delegate = self;
//    
//    // iOS8未満は、このメソッドは無い
//    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
//    LOG()
//      [_locationManager requestWhenInUseAuthorization];
//    }
//    [_locationManager startUpdatingLocation];
//  }
  return self;
}

- (void)startLocation
{
  //位置情報
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

- (NSArray *)getLocation
{
  LOG()
  NSArray *ary = @[
                   [[NSNumber alloc] initWithDouble:_lng],
                   [[NSNumber alloc] initWithDouble:_lat],
                   ];
  return ary;
}

- (void)addURLOperation:(TYURLOperation *)urlOperation
{
  LOG()
  [_urlOperationQueue addOperation:urlOperation];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
  LOG()
  @synchronized(self) {
//    int operationCount = [_urlOperationQueue operationCount];
    NSInteger operationCount = [_urlOperationQueue operationCount];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = operationCount == 0 ? NO:YES;
  }
}


@end
