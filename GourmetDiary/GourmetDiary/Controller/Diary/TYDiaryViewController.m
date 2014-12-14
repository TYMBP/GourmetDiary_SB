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
  [super viewDidLoad];
  
  self.navigationController.delegate = self;
  
  _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
  [_indicator setColor:[UIColor darkGrayColor]];
  [_indicator setHidesWhenStopped:YES];
  [_indicator stopAnimating];
  
  self.visitedList = nil;
  _set = 15;
  
  self.naviTitle.title = @"最新";
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.backgroundColor = [UIColor colorWithRed:0.00 green:0.60 blue:1.0 alpha:1.0];
  self.automaticallyAdjustsScrollViewInsets = NO;
  self.visitedList = [_dataManager fetchVisitedList:1 num:_set];
  _count = [[[self.visitedList objectAtIndex:0] valueForKey:@"count"] integerValue];
  LOG(@"count %lu", _count)
//  [self test];
  
}

- (IBAction)pushSort:(id)sender {
  LOG()
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"並び替え" message:@"選択してください" preferredStyle:UIAlertControllerStyleActionSheet];
  UIAlertAction *dec = [UIAlertAction actionWithTitle:@"降順" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
    LOG(@"dec tap")
    self.visitedList = [_dataManager fetchVisitedList:1 num:_set];
    [self.tableView reloadData];
    
  }];
  UIAlertAction *asc = [UIAlertAction actionWithTitle:@"昇順" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
    LOG(@"asc tap")
    self.visitedList = [_dataManager fetchVisitedList:2 num:_set];
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

//1202変更
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//  LOG(@"segue %@", segue.identifier)
//  if ([[segue identifier] isEqualToString:@"Editor"]) {
//    TYEditorViewController *editCtr = segue.destinationViewController;
//    editCtr.para = _sid;
//    LOG(@"sid %@", _sid)
//  }
//}

- (void) navigationController:(UINavigationController *) navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
  LOG()
//  [self.tableView reloadData];
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
//  cell.levelList.text = [[fetchData valueForKey:@"level"] stringValue];
  cell.levelList.text = [TYUtil setLevelTableText:[fetchData valueForKey:@"level"]];
  cell.areaList.text = [fetchData valueForKey:@"area"];
  cell.genreList.text = [fetchData valueForKey:@"genre"];
  
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
  NSDictionary *fetchData = [self.visitedList objectAtIndex:indexPath.row];
  _sid = [fetchData valueForKey:@"sid"];
  LOG(@"_sid %@", _sid)
  TYAppDelegate *appDelegate;
  appDelegate = (TYAppDelegate *)[[UIApplication sharedApplication] delegate];
  appDelegate.sid = _sid;
  appDelegate.n = 1;
  
  [self performSegueWithIdentifier:@"Editor" sender:self];
}

- (BOOL)pageLoading:(Paging)paging
{
  self.visitedList = [_dataManager fetchVisitedList:1 num:_set];
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
        _set += 15;
        [self startIndicator];
        
        if ([self pageLoading:^{
          [self.tableView reloadData];
          [self endIndicator];
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
  [_indicator startAnimating];
  CGRect footerFrame = self.tableView.tableFooterView.frame;
  footerFrame.size.height += 70.0f;
  
  [_indicator setFrame:footerFrame];
  [self.tableView setTableFooterView:_indicator];
}

- (void)endIndicator
{
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
