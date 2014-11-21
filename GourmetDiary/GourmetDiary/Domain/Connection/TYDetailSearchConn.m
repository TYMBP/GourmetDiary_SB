//
//  TYDetailSearchConn.m
//  GourmetDiary
//
//  Created by Tomohiko on 2014/11/16.
//  Copyright (c) 2014年 yamatomo. All rights reserved.
//

#import "TYDetailSearchConn.h"
#import "TYAppDelegate.h"

@implementation TYDetailSearchConn {
  NSArray *_location;
}

- (id)initWithTarget:(id)target selector:(SEL)selector para:(NSString *)para
{
  LOG()
  self = [super initWithTarget:target selector:selector];
  if (self) {
//test
//    NSString *str = API_TEST3;
//    LOG(@"url: %@", str)
//    NSURL *url = [NSURL URLWithString:[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@&id=%@&format=json", API_BASEURL, API_KEY, para];
    LOG(@"urlStr: %@", urlStr)
    NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

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
