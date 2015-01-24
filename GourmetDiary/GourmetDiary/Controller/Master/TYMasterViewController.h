//
//  TYMasterViewController.h
//  GourmetDiary
//
//  Created by Tomohiko on 2014/12/29.
//  Copyright (c) 2014年 yamatomo. All rights reserved.
//

#import "TYBaseViewController.h"

typedef void (^Paging)();

@interface TYMasterViewController : TYBaseViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
