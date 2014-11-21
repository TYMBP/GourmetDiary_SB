//
//  TYResultViewController.h
//  GourmetDiary
//
//  Created by Tomohiko on 2014/11/21.
//  Copyright (c) 2014年 yamatomo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TYResultViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) int n;
@property (nonatomic) NSMutableDictionary *para;
@property (weak, nonatomic) IBOutlet UILabel *resultCount;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
