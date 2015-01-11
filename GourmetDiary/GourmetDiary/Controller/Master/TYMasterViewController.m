//
//  TYMasterViewController.m
//  GourmetDiary
//
//  Created by Tomohiko on 2014/12/29.
//  Copyright (c) 2014年 yamatomo. All rights reserved.
//

#import "TYMasterViewController.h"
#import "TYEditorViewController.h"
#import "TYAppDelegate.h"
#import "TYSearchTableViewCell.h"
#import "TYGourmetDiaryManager.h"


@implementation TYMasterViewController {
  TYGourmetDiaryManager *_dataManager;
  NSMutableArray *_masterData;
  NSInteger _limit;
  NSInteger _count;
  BOOL _isLoading;
  UIActivityIndicatorView *_indicator;
}

- (void)viewDidLoad
{
  LOG()
  [super viewDidLoad];
  
  _dataManager = [TYGourmetDiaryManager sharedmanager];
   _limit = 15;
  _masterData = nil;
  
  _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
  [_indicator setColor:[UIColor darkGrayColor]];
  [_indicator setHidesWhenStopped:YES];
  [_indicator stopAnimating];
  
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.backgroundColor = [UIColor colorWithRed:1.0 green:0.98 blue:0.98 alpha:1.0];
  self.automaticallyAdjustsScrollViewInsets = NO;
  
  [self setMasterList];
}

- (void)setMasterList
{
  _masterData = [_dataManager fetchMasterData:_limit];
  LOG(@"masterData:%@", _masterData)
  if (!_masterData) {
    return;
  } else {
    _count = [[[_masterData objectAtIndex:0] valueForKey:@"count"] integerValue];
//    LOG(@"count %lu", _count)
    [self.tableView reloadData];
  }
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  LOG()
  NSInteger n = [self.tableView indexPathForSelectedRow].row;
  NSMutableDictionary *fetchData = [_masterData objectAtIndex:n];
  TYAppDelegate *appDelegate;
  appDelegate = (TYAppDelegate *)[[UIApplication sharedApplication] delegate];
  appDelegate.sid = [fetchData valueForKey:@"sid"];
  appDelegate.editStatus = 2;
  TYEditorViewController *editorCtr = segue.destinationViewController;
  editorCtr.shopDic = fetchData;
  
}

#pragma mark - Table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  NSInteger n = [_masterData count];
  if (n == 0) {
    return 1;
  } else {
    return n;
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  TYSearchTableViewCell *cell = (TYSearchTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Mastercell" forIndexPath:indexPath];
  if ([_masterData count] == 0) {
    cell.genreMst.text = @"";
    cell.nameMst.text = @"";
    cell.areaMst.text = @"";
  } else {
    NSDictionary *data = [_masterData objectAtIndex:indexPath.row];
//    cell.nameRs.text = [data valueForKey:@"shop"];
    cell.areaMst.text = [data valueForKey:@"area"];
    cell.genreMst.text = [data valueForKey:@"genre"];
    
    CGFloat lineHeight = 20.0f;
    NSString *str = [data valueForKey:@"shop"];
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.minimumLineHeight = lineHeight;
    paraStyle.maximumLineHeight = lineHeight;

    NSMutableAttributedString *attributeText = [[NSMutableAttributedString alloc] initWithString:str];
    [attributeText addAttribute:NSParagraphStyleAttributeName value:paraStyle range:NSMakeRange(0, attributeText.length)];
    cell.nameMst.attributedText = attributeText;
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
  LOG()
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
}



@end
