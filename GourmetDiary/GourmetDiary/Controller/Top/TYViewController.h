//
//  ViewController.h
//  GourmetDiary
//
//  Created by Tomohiko on 2014/11/20.
//  Copyright (c) 2014年 yamatomo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYBaseViewController.h"

//@interface TYViewController : UIViewController<UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate>
@interface TYViewController : TYBaseViewController

@property (weak, nonatomic) IBOutlet UIButton *searchBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray *visitedData;

//@property (weak, nonatomic) id delegate;
@end

