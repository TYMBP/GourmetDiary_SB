//
//  ViewController.m
//  GourmetDiary
//
//  Created by Tomohiko on 2014/11/20.
//  Copyright (c) 2014年 yamatomo. All rights reserved.
//

#import "TYViewController.h"
#import "TYAppDelegate.h"
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
  LOG()
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
  self.tableView.backgroundColor = [UIColor colorWithRed:0.13 green:0.55 blue:0.13 alpha:1.0];
  
  self.searchBtn.layer.borderColor = [[UIColor whiteColor] CGColor];
  self.searchBtn.layer.borderWidth = 1;
  self.searchBtn.layer.cornerRadius = 5;
  
  self.navigationController.delegate = self;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if (self.visitedData.count == 0) {
    return 0;
  } else if (self.visitedData.count < 2) {
    return self.visitedData.count;
  }
  return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  TYVisitedTableViewCell *cell = (TYVisitedTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"VisitedList" forIndexPath:indexPath];
  NSDictionary *fetchData = [self.visitedData objectAtIndex:indexPath.row];
  cell.date.text = [_dateFomatter stringFromDate:[fetchData valueForKey:@"visited"]];
  cell.level.text = [TYUtil setLevelTableText:[fetchData valueForKey:@"level"]];
  cell.area.text = [fetchData valueForKey:@"area"];
  cell.genre.text = [fetchData valueForKey:@"genre"];
  CGFloat lineHeight = 20.0f;
  NSString *str = [fetchData valueForKey:@"shop"];
  
  NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
  paraStyle.minimumLineHeight = lineHeight;
  paraStyle.maximumLineHeight = lineHeight;
  
  NSMutableAttributedString *attributeText = [[NSMutableAttributedString alloc] initWithString:str];
  [attributeText addAttribute:NSParagraphStyleAttributeName value:paraStyle range:NSMakeRange(0, attributeText.length)];
  cell.name.attributedText = attributeText;
  
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  float ht = 100;
  return ht;
}

//タップイベント
#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (!self.visitedData) {
    LOG()
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    return;
  } else {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *fetchData = [self.visitedData objectAtIndex:indexPath.row];
    LOG(@"sid: %@", [fetchData valueForKey:@"sid"])
    _sid = [fetchData valueForKey:@"sid"];
    
    TYAppDelegate *appDelegate;
    appDelegate = (TYAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.sid = _sid;
    appDelegate.editStatus = 1;
    appDelegate.oid = [fetchData valueForKey:@"oid"];
    LOG(@"_sid %@", _sid)
    LOG(@"appdelegate sid %@", appDelegate.sid)
    
    UINavigationController *vc = self.tabBarController.viewControllers[1];
    self.tabBarController.selectedViewController = vc;
    [vc popToRootViewControllerAnimated:NO];
    [vc.viewControllers[0] performSegueWithIdentifier:@"Editor" sender:self];
  //1215  [self performSegueWithIdentifier:@"Diary" sender:self];
  }
}

#pragma mark - navigationController
- (void) navigationController:(UINavigationController *) navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
  LOG()
  _visitedData = nil;
  _visitedData = [_dataManager fetchVisitData];
  [self.tableView reloadData];
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
