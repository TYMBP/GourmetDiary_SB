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

- (id)initWithTarget:(id)target selector:(SEL)selector para:(NSMutableDictionary *)para set:(NSInteger)set
{
  LOG()
  self = [super initWithTarget:target selector:selector];
  if (self) {
//    NSString *str = API_TEST2;
//    LOG(@"url: %@", API_TEST2)
    
    NSMutableArray *ary = [[NSMutableArray alloc] initWithObjects:@"", @"G001", @"G002", @"G003", @"G004", @"G005", @"G006", @"G007", @"G008", @"G009", @"G010", @"G011", @"G012", @"G013", @"G014", @"G015", @"G016", nil];
    NSString *shopWord = [para objectForKey:@"shop"];
    NSInteger num = [[para objectForKey:@"genre"] integerValue];
    NSString *genreCode = [ary objectAtIndex:num];
    NSString *start = [[NSString alloc] initWithFormat:@"%ld", (long)set];
    
    LOG(@"shop: %@ area:%@", shopWord, genreCode)
//    NSString *urlStr = [NSString stringWithFormat:@"%@%@&Keyword=%@ %@&order=4&start=1&count=15&format=json", API_SHOPSEARCH, API_KEY, shopWord, areaWord];
//    NSString *urlStr = [NSString stringWithFormat:@"%@%@&name=%@&Keyword=%@&order=4&start=1&count=15&format=json", API_BASEURL, API_KEY, shopWord, areaWord];
//    NSString *urlStr = [NSString stringWithFormat:@"%@%@&name=%@&Keyword=%@&order=4&start=%@&count=15&format=json", API_BASEURL, API_KEY, shopWord, areaWord, start];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@&Keyword=%@&genre=%@&order=4&start=%@&count=15&format=json", API_BASEURL, API_KEY, shopWord, genreCode, start];
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
