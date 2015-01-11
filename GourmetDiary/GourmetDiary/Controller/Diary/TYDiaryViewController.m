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
#import "TYEditorViewController.h"
#import "TYUtil.h"
#import "TYAppDelegate.h"

@implementation TYDiaryViewController {
  TYGourmetDiaryManager *_dataManager;
  NSDateFormatter *_dateFomatter;
  NSString *_sid;
  UIActivityIndicatorView *_indicator;
  NSInteger _set;
  NSInteger _count;
  NSInteger _sort;
  BOOL _isLoading;
}

- (id)initWithCoder:(NSCoder *)coder
{
  self = [super initWithCoder:coder];
  if (self) {
    LOG()
    _dateFomatter = [[NSDateFormatter alloc] init];
     [_dateFomatter setDateFormat:@"yy/MM/dd"];
    _dataManager = [TYGourmetDiaryManager sharedmanager];
    _isLoading = YES;
  }
  return self;
}

- (void)viewDidLoad
{
  LOG()
  [super viewDidLoad];
  
  self.navigationController.delegate = self;
  self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.60 green:0.80 blue:0.20 alpha:1.0];
  _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
  [_indicator setColor:[UIColor darkGrayColor]];
  [_indicator setHidesWhenStopped:YES];
  [_indicator stopAnimating];
  
  self.visitedList = nil;
  _set = 10;
  _sort = 1;
  
  self.naviTitle.title = @"訪問店";
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.backgroundColor = [UIColor colorWithRed:1.0 green:0.98 blue:0.98 alpha:1.0];
  self.automaticallyAdjustsScrollViewInsets = NO;
  self.visitedList = [_dataManager fetchVisitedList:_sort num:_set];
  
  if (self.visitedList) {
    _count = 0;
    return;
  } else {
    _count = [[[self.visitedList objectAtIndex:0] valueForKey:@"count"] integerValue];
  }
  
}

- (IBAction)pushNew:(id)sender {
  UINavigationController *vc = self.tabBarController.viewControllers[1];
  self.tabBarController.selectedViewController = vc;
  [vc popToRootViewControllerAnimated:NO];
  [vc.viewControllers[0] performSegueWithIdentifier:@"Editor" sender:self];
}

- (IBAction)pushSort:(id)sender {
  LOG()
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"並び替え" message:@"選択してください" preferredStyle:UIAlertControllerStyleActionSheet];
  UIAlertAction *dec = [UIAlertAction actionWithTitle:@"降順" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
    LOG(@"dec tap")
    _set = 10;
    _sort = 1;
    self.visitedList = [_dataManager fetchVisitedList:_sort num:_set];
    [self.tableView reloadData];
    
  }];
  UIAlertAction *asc = [UIAlertAction actionWithTitle:@"昇順" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
    LOG(@"asc tap")
    _set = 10;
    _sort = 2;
    self.visitedList = [_dataManager fetchVisitedList:_sort num:_set];
    [self.tableView reloadData];
  }];
  UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style: UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    LOG()
  }];
  [alert addAction:dec];
  [alert addAction:asc];
  [alert addAction:cancel];
  [self presentViewController:alert animated:YES completion:nil];
}

- (void)warning:(NSString *)mess
{
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"入力エラー" message:mess preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
    LOG(@"OK tap")
    [self.navigationController popToRootViewControllerAnimated:YES];
  }];
  [alert addAction:ok];
  [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - navigationController
- (void) navigationController:(UINavigationController *) navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
  LOG()
  self.visitedList = nil;
  self.visitedList = [_dataManager fetchVisitedList:1 num:_set];
  if ([self.visitedList count] == 0) {
    [self.tableView reloadData];
    return;
  } else {
    _count = [[[self.visitedList objectAtIndex:0] valueForKey:@"count"] integerValue];
    [self.tableView reloadData];
  }
}

#pragma mark - tableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  NSInteger n = [self.visitedList count];
  if (n == 0) {
    return 1;
  } else {
    return [self.visitedList count];
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  TYVisitedTableViewCell *cell = (TYVisitedTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"VisitedList" forIndexPath:indexPath];
  if ([self.visitedList count] == 0) {
    cell.dateList.text = @"";
    cell.nameList.text = @"NO DATA";
    cell.levelList.text = @"";
    cell.areaList.text = @"";
    cell.genreList.text = @"";
    cell.comment.text = @"";
  } else {
    NSDictionary *fetchData = [self.visitedList objectAtIndex:indexPath.row];
    cell.dateList.text = [_dateFomatter stringFromDate:[fetchData valueForKey:@"visited"]];
    cell.nameList.text = [fetchData valueForKey:@"shop"];
    cell.levelList.text = [TYUtil setLevelTableText:[fetchData valueForKey:@"level"]];
    cell.areaList.text = [fetchData valueForKey:@"area"];
    cell.genreList.text = [fetchData valueForKey:@"genre"];
    cell.comment.text = [fetchData valueForKey:@"comment"];
    cell.comment.lineBreakMode = NSLineBreakByTruncatingTail;
//    [cell setClipsToBounds:YES];
  }
  
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  float ht = 120;
  return ht;
}

//タップイベント
#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  NSDictionary *fetchData = [self.visitedList objectAtIndex:indexPath.row];
  _sid = [fetchData valueForKey:@"sid"];
  TYAppDelegate *appDelegate;
  appDelegate = (TYAppDelegate *)[[UIApplication sharedApplication] delegate];
  appDelegate.sid = _sid;
  appDelegate.editStatus = 1;
  appDelegate.oid = [fetchData valueForKey:@"oid"];
  [self performSegueWithIdentifier:@"Editor" sender:self];
  
}

#pragma mark - paging
- (BOOL)pageLoading:(Paging)paging
{
  LOG()
  self.visitedList = [_dataManager fetchVisitedList:_sort num:_set];
  if (!self.visitedList) {
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
      if (_set < _count) {
        LOG()
        _isLoading = NO;
        _set += 10;
        [self startIndicator];
        
        if ([self pageLoading:^{
          [self.tableView reloadData];
          [self endIndicator];
          _isLoading = YES;
        }]) {
        } else {
          LOG()
          [self endIndicator];
        }
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
    LOG(@"sid: %@", [obj valueForKey:@"sid"])
  }
}

@end
