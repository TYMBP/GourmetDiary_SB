//
//  AppDelegate.h
//  GourmetDiary
//
//  Created by Tomohiko on 2014/11/20.
//  Copyright (c) 2014年 yamatomo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYApplication.h"

@interface TYAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
//@property (strong, nonatomic) UIWindow *windowOld;
@property (strong, readonly, nonatomic) TYApplication *application;
@property (nonatomic) NSString *sid;
@property (nonatomic) id oid;
@property (nonatomic) int n;
@property (nonatomic) int editStatus; //編集or追加

@end

