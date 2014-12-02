//
//  ViewController.m
//  GourmetDiary
//
//  Created by Tomohiko on 2014/11/20.
//  Copyright (c) 2014年 yamatomo. All rights reserved.
//

#import "TYViewController.h"
#import "TYAppDelegate.h"
//#import "TYApplication.h"
#import "TYGourmetDiaryManager.h"
#import "TYVisitedTableViewCell.h"
#import "VisitData.h"
#import "ShopMst.h"
#import "TYUtil.h"

@implementation TYViewController {
  TYGourmetDiaryManager *_dataManager;
  NSDateFormatter *_dateFomatter;
  NSString *_sid;
}

- (id)initWithCoder:(NSCoder *)coder
{
  self = [super initWithCoder:coder];
  if (self) {
    _dateFomatter = [[NSDateFormatter alloc] init];
     [_dateFomatter setDateFormat:@"yy/MM/dd"];
    _dataManager = [TYGourmetDiaryManager sharedmanager];
    
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  LOG()
//  [self test];
  _visitedData = nil;
  _visitedData = [_dataManager fetchVisitData];
  
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.backgroundColor = [UIColor colorWithRed:1.0 green:0.39 blue:0.39 alpha:1.0];
  
  self.searchBtn.layer.borderColor = [[UIColor whiteColor] CGColor];
  self.searchBtn.layer.borderWidth = 1;
  self.searchBtn.layer.cornerRadius = 5;
}

//- (void)viewWillAppear:(BOOL)animated
//{
//  LOG()
//  [super viewWillAppear:animated];
//}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  LOG()
  
//  if ([[segue identifier] isEqualToString:@"Diary"]) {
//    LOG(@"diary %@", segue.identifier)
//    TYEditorViewController *editCtr = segue.destinationViewController;
//    TYDiaryViewController *diaCtr = segue.destinationViewController;
//    editCtr.para = _sid;
//    diaCtr.para = _sid;
//  }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  TYVisitedTableViewCell *cell = (TYVisitedTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"VisitedList" forIndexPath:indexPath];
  NSInteger n = indexPath.row + 1;
  if (self.visitedData.count < 4 && self.visitedData.count < n) {
      LOG(@"null")
      cell.date.text = @"";
      cell.level.text = @"";
      cell.name.text = @"";
      cell.genre.text = @"";
      cell.area.text = @"";
  } else {
    NSDictionary *fetchData = [self.visitedData objectAtIndex:indexPath.row];
    cell.date.text = [_dateFomatter stringFromDate:[fetchData valueForKey:@"visited"]];
    cell.name.text = [fetchData valueForKey:@"shop"];
    cell.level.text = [TYUtil setLevelTableText:[fetchData valueForKey:@"level"]];
    cell.area.text = [fetchData valueForKey:@"area"];
    cell.genre.text = [fetchData valueForKey:@"genre"];
  }
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  float ht = 60;
  return ht;
}

//タップイベント
#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  NSDictionary *fetchData = [self.visitedData objectAtIndex:indexPath.row];
  LOG(@"sid: %@", [fetchData valueForKey:@"sid"])
  _sid = [fetchData valueForKey:@"sid"];
  
  TYAppDelegate *appDelegate;
  appDelegate = (TYAppDelegate *)[[UIApplication sharedApplication] delegate];
  appDelegate.sid = _sid;
  appDelegate.n = 1;
  LOG(@"_sid %@", _sid)
  LOG(@"appdelegate sid %@", appDelegate.sid)
  
  UINavigationController *vc = self.tabBarController.viewControllers[1];
  self.tabBarController.selectedViewController = vc;
  [vc popToRootViewControllerAnimated:NO];
  [vc.viewControllers[0] performSegueWithIdentifier:@"Editor" sender:self];
//  [self performSegueWithIdentifier:@"Diary" sender:self];
}

/* test */
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
