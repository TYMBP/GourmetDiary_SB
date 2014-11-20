//
//  TYURLOperation.m
//  GourmetDiary
//
//  Created by Tomohiko on 2014/11/11.
//  Copyright (c) 2014年 yamatomo. All rights reserved.
//

#import "TYURLOperation.h"
#import "TYApplication.h"

@implementation TYURLOperation {
  __unsafe_unretained id _target;
  SEL _selector;
  NSURLConnection *_connection;
  NSString *_name;
  NSMutableData *_data;
}

- (id)initWithTarget:(id)target selector:(SEL)selector
{
  LOG()
  self = [super init];
  if (self) {
    _target = target;
    _selector = selector;
    _name = NSStringFromClass([self class]);
    _isExecuting = NO;
    _isFinished = NO;
    _isCancelled = NO;
    _timeoutInterVal = 15;
  }
  return self;
}

- (void)start
{
  LOG()
  [[NSThread currentThread] setName:_name];
  if (_isCancelled || _isFinished)
    return;
  _isExecuting = YES;
  
  _request.timeoutInterval = _timeoutInterVal;
  _connection = [NSURLConnection connectionWithRequest:_request delegate:self];
  [_connection start];
  NSPort *dummyPort = [NSPort port];
  [[NSRunLoop currentRunLoop] addPort:dummyPort forMode:NSDefaultRunLoopMode];
  do {
    LOG()
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
  } while (self.isExecuting);
  [[NSRunLoop currentRunLoop] removePort:dummyPort forMode:NSDefaultRunLoopMode];
}

- (BOOL)isConcurrent
{
  LOG()
  return YES;
}

- (void)cancel
{
  LOG()
  [_connection cancel];
  
  _isCancelled = YES;
  _isExecuting = NO;
  _isFinished = YES;
  _target = nil;
  _selector = nil;
}

- (void)end
{
  LOG()
  _connection = nil;
  _isExecuting = NO;
  _isFinished = YES;
  if (_target) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if (_target) {
//      LOG()
      [_target performSelectorOnMainThread:_selector withObject:self waitUntilDone:NO];
    }
#pragma clang diagnostic pop
  }
  _target = nil;
  _selector = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
//  LOG(@"response: %@", response)
  if (_isCancelled || _isFinished)
    return;
  _statusCode = [(NSHTTPURLResponse *)response statusCode];
  _data = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
//  LOG(@"data: %@", data)
  if (_isCancelled || _isFinished)
    return;
  [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
//  LOG(@"connection: %@", connection)
  if (_isCancelled || _isFinished)
    return;
//  NSString *str = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
//  LOG(@"str: %@", str)
  [self connectionDidFihish:nil];
  [self end];
  
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
  LOG()
  _error = error;
  [self connectionDidFihish:error];
  [self end];
}

- (void)connectionDidFihish:(NSError *)error
{
  LOG(@"error: %@", error);
}
@end
