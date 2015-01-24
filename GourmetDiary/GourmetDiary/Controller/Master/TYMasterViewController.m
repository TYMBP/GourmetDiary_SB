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
  NSInteger _masterCount;
  BOOL _isLoading;
  UIActivityIndicatorView *_indicator;
}

- (void)viewDidLoad
{
  LOG()
  [super viewDidLoad];
  
  _dataManager = [TYGourmetDiaryManager sharedmanager];
   _limit = 10;
  _masterData = nil;
  _isLoading = NO;
  
  _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
  [_indicator setColor:[UIColor darkGrayColor]];
  [_indicator setHidesWhenStopped:YES];
  [_indicator stopAnimating];
  
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.backgroundColor = [UIColor colorWithRed:1.0 green:0.98 blue:0.98 alpha:1.0];
  self.automaticallyAdjustsScrollViewInsets = NO;
 
  
  
  _masterCount = [_dataManager fetchMasterCount];
  [self setMasterList];
}

- (void)setMasterList
{
  LOG()
  _masterData = [_dataManager fetchMasterData:_limit];
  LOG(@"masterData:%@", _masterData)
  LOG(@"masterCount:%lu", _masterCount)
  if (!_masterData) {
    LOG(@"master null")
    return;
  } else if (_masterCount < _limit) {
    LOG()
    _count = _masterCount;
    [self.tableView reloadData];
  } else {
    LOG()
//0112    _count = [[[_masterData objectAtIndex:0] valueForKey:@"count"] integerValue];
    _count = _limit;
    _isLoading = YES;
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

#pragma mark - paging
- (BOOL)pageLoading:(Paging)paging
{
  LOG()
  _masterData = [_dataManager fetchMasterData:_limit];
  if (!_masterData) {
    LOG(@"data get error")
    return NO;
  }
  if (paging){
    paging();
  }
  return YES;
}

//スクロールビューページング
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
  if(self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height))
  {
    if (_isLoading) {
      if (_masterCount > _count) {
        _isLoading = NO;
        _limit += 10;
        [self startIndicator];
        
        if ([self pageLoading:^{
          [self.tableView reloadData];
          [self endIndicator];
        }]) {
          if (_masterCount < _limit) {
            _isLoading = NO;
          } else {
            _isLoading = YES;
          }
        } else {
          _isLoading = NO;
          [self endIndicator];
        }
      } else {
        _isLoading = NO;
      }
    }
  }
}

- (void)startIndicator
{
  LOG()
  [_indicator startAnimating];
  CGRect footerFrame = self.tableView.tableFooterView.frame;
  footerFrame.size.height += 70.0f;
  
  [_indicator setFrame:footerFrame];
  [self.tableView setTableFooterView:_indicator];
}

- (void)endIndicator
{
  LOG()
  [_indicator stopAnimating];
  [_indicator removeFromSuperview];
  [self.tableView setTableFooterView:nil];
}

@end