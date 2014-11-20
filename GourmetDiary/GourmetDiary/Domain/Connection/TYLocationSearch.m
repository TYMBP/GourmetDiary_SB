//
//  TYLocationSearch.m
//  GourmetDiary
//
//  Created by Tomohiko on 2014/11/12.
//  Copyright (c) 2014年 yamatomo. All rights reserved.
//

#import "TYLocationSearch.h"
#import "TYAppDelegate.h"

@implementation TYLocationSearch {
  NSArray *_location;
}

- (id)initWithTarget:(id)target selector:(SEL)selector
{
  LOG()
  self = [super initWithTarget:target selector:selector];
  if (self) {
    _location = [[TYApplication application] getLocation];
//    LOG(@"location %@", _location)
    NSNumber *latObj = [_location objectAtIndex:1];
    NSNumber *lngObj = [_location objectAtIndex:0];
    double lat = fabs(latObj.doubleValue);
    double lng = fabs(lngObj.doubleValue);
//  NSURL *url = [NSURL URLWithString:API_TEST];

    NSString *urlStr = [NSString stringWithFormat:@"%@%@&Latitude=%f&Longitude=%f&order=4&start=1&count=15&format=json", API_BASEURL, API_KEY, lat, lng];
    LOG(@"urlStr: %@", urlStr)
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSURLRequest *request =  [NSURLRequest requestWithURL:url];
    [NSURLConnection connectionWithRequest:request delegate:self];
    
  }
  return self;
}

- (void)connectionDidFinish:(NSError *)error
{
  if (error) {
    LOG(@"error: %@", error)
    return;
  }
  if (200 != self.statusCode) {
    LOG()
    return;
  }
}

@end
