//
//  TYKeywordSearch.m
//  GourmetDiary
//
//  Created by Tomohiko on 2014/11/14.
//  Copyright (c) 2014年 yamatomo. All rights reserved.
//

#import "TYKeywordSearchConn.h"
#import "TYAppDelegate.h"

@implementation TYKeywordSearchConn {
  NSArray *_location;
}

- (id)initWithTarget:(id)target selector:(SEL)selector para:(NSMutableDictionary *)para
{
  LOG()
  self = [super initWithTarget:target selector:selector];
  if (self) {
//    NSString *str = API_TEST2;
//    LOG(@"url: %@", API_TEST2)
    NSString *shopWord = [para objectForKey:@"shop"];
    NSString *areaWord = [para objectForKey:@"area"];
    
    LOG(@"shop: %@ area:%@", shopWord, areaWord)
    NSString *urlStr = [NSString stringWithFormat:@"%@%@&Keyword=%@ %@&order=4&start=1&count=15&format=json", API_SHOPSEARCH, API_KEY, shopWord, areaWord];
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
