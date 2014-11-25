//
//  ViewController.m
//  GourmetDiary
//
//  Created by Tomohiko on 2014/11/20.
//  Copyright (c) 2014年 yamatomo. All rights reserved.
//

#import "TYViewController.h"
//#import "TYApplication.h"
#import "TYGourmetDiaryManager.h"
#import "TYVisitedTableViewCell.h"
#import "VisitData.h"
#import "ShopMst.h"

@implementation TYViewController {
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
  _visitedData = [_dataManager fetchVisitData];
//  [self test];
  
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.backgroundColor = [UIColor colorWithRed:1.0 green:0.4 blue:0.4 alpha:1.0];
  
  self.searchBtn.layer.borderColor = [[UIColor whiteColor] CGColor];
  self.searchBtn.layer.borderWidth = 1;
  self.searchBtn.layer.cornerRadius = 5;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  TYVisitedTableViewCell *cell = (TYVisitedTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"VisitedList" forIndexPath:indexPath];
  if (self.visitedData.count == 0) {
    LOG(@"null")
    cell.date.text = @"";
    cell.name.text = @"";
    cell.genre.text = @"";
    cell.area.text = @"";
  } else {
    NSDictionary *fetchData = [self.visitedData objectAtIndex:indexPath.row];
//    LOG(@"id visited: %@", [fetchData valueForKey:@"visited_at"])
    
    cell.date.text = [_dateFomatter stringFromDate:[fetchData valueForKey:@"visited"]];
    cell.name.text = [fetchData valueForKey:@"shop"];
    cell.area.text = [fetchData valueForKey:@"area"];
    cell.genre.text = [fetchData valueForKey:@"genre"];
  }
  return cell;
}

//タップイベント
#pragma mark - Table view delegate
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//  [tableView deselectRowAtIndexPath:indexPath animated:YES];
//  SearchData *rowData = [_searchData objectAtIndex:indexPath.row];
//  LOG(@"sid: %@", rowData.sid)
//  _sid = rowData.sid;
//  [self performSegueWithIdentifier:@"Detail" sender:self];
//}



- (void)test
{
  LOG()
    _visitedData = [_dataManager fetchVisitData];
    LOG(@"count : %lu", [_visitedData count])
  for (NSArray *obj in _visitedData) {
    LOG(@"visit: %@", [obj valueForKey:@"visited"])
//    NSSet *master = [obj valueForKey:@"diary"];
    LOG(@"name: %@", [obj valueForKey:@"shop"])
    LOG(@"area: %@", [obj valueForKey:@"area"])
    LOG(@"genre: %@", [obj valueForKey:@"genre"])
  }
}

@end
