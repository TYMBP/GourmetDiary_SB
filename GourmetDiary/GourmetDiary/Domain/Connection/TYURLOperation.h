//
//  TYURLOperation.h
//  GourmetDiary
//
//  Created by Tomohiko on 2014/11/11.
//  Copyright (c) 2014年 yamatomo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TYURLOperation : NSOperation

@property (assign, nonatomic) BOOL isFinished;
@property (assign, nonatomic) BOOL isExecuting;
@property (assign, nonatomic) BOOL isCancelled;
//@property (strong, readonly) NSString *name;
@property (nonatomic, strong) NSMutableURLRequest *request;
@property (strong, readonly) NSData *data;
@property (nonatomic, strong) NSError *error;
@property (unsafe_unretained, readonly) NSInteger statusCode;
@property (nonatomic) NSTimeInterval timeoutInterVal;

- (id)initWithTarget:(id)target selector:(SEL)selector;

@end
