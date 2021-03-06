//
//  TYDiaryViewController.h
//  GourmetDiary
//
//  Created by Tomohiko on 2014/11/25.
//  Copyright (c) 2014年 yamatomo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYBaseViewController.h"

typedef void (^Paging)();

@interface TYDiaryViewController : TYBaseViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSArray *visitedList;
@property (weak, nonatomic) IBOutlet UINavigationItem *naviTitle;

- (BOOL)pageLoading:(Paging)paging;

@end
