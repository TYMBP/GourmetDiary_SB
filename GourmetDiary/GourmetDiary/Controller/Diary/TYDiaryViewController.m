//
//  TYDiaryViewController.m
//  GourmetDiary
//
//  Created by Tomohiko on 2014/11/25.
//  Copyright (c) 2014年 yamatomo. All rights reserved.
//

#import "TYDiaryViewController.h"
#import "TYVisitedTableViewCell.h"
#import "TYGourmetDiaryManager.h"

@implementation TYDiaryViewController {
  TYGourmetDiaryManager *_dataManager;
  NSDateFormatter *_dateFomatter;
}

- (id)initWithCoder:(NSCoder *)coder
{
  self = [super initWithCoder:coder];
  if (self) {
    LOG()
    _dateFomatter = [[NSDateFormatter alloc] init];
     [_dateFomatter setDateFormat:@"yy/MM/dd"];
    _dataManager = [TYGourmetDiaryManager sharedmanager];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.naviTitle.title = @"最新";
  self.visitedList = [_dataManager fetchVisitedList];
  [self test];
  
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.backgroundColor = [UIColor colorWithRed:0.00 green:0.60 blue:1.0 alpha:1.0];
  self.automaticallyAdjustsScrollViewInsets = NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [self.visitedList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  TYVisitedTableViewCell *cell = (TYVisitedTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"VisitedList" forIndexPath:indexPath];
  
  NSDictionary *fetchData = [self.visitedList objectAtIndex:indexPath.row];
//    LOG(@"id visited: %@", [fetchData valueForKey:@"visited_at"])
  
  cell.dateList.text = [_dateFomatter stringFromDate:[fetchData valueForKey:@"visited"]];
  cell.nameList.text = [fetchData valueForKey:@"shop"];
  cell.levelList.text = [[fetchData valueForKey:@"level"] stringValue];
  cell.areaList.text = [fetchData valueForKey:@"area"];
  cell.genreList.text = [fetchData valueForKey:@"genre"];
  
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  float ht = 60;
  return ht;
}



/* test */
- (void)test
{
  LOG()
  for (NSArray *obj in self.visitedList) {
    LOG(@"visit: %@", [obj valueForKey:@"visited"])
//    NSSet *master = [obj valueForKey:@"diary"];
    LOG(@"name: %@", [obj valueForKey:@"shop"])
    LOG(@"area: %@", [obj valueForKey:@"area"])
    LOG(@"genre: %@", [obj valueForKey:@"genre"])
  }
}

@end
