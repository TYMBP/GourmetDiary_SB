//
//  TYResultViewController.m
//  GourmetDiary
//
//  Created by Tomohiko on 2014/11/21.
//  Copyright (c) 2014年 yamatomo. All rights reserved.
//

#import "TYResultViewController.h"
#import "TYDetailViewController.h"
#import "TYGourmetDiaryManager.h"
#import "TYSearchTableViewCell.h"
#import "TYKeywordSearchConn.h"
#import "TYLocationSearch.h"
#import "KeywordSearch.h"
#import "TYApplication.h"
#import "SearchData.h"
#import "TYAppDelegate.h"


@implementation TYResultViewController {
  TYGourmetDiaryManager *_dataManager;
  TYLocationSearch *_location;
  NSArray *_searchData;
  TYKeywordSearchConn *_connection;
  NSString *_sid;
  NSNumber *_results;
  NSInteger _setNum;
  BOOL _isLoading;
  UIActivityIndicatorView *_indicator;
}

- (id)initWithCoder:(NSCoder *)coder
{
  LOG()
  self = [super initWithCoder:coder];
  if (self) {
    _dataManager = [TYGourmetDiaryManager sharedmanager];
   [_dataManager resetKeywordSearchData];
    _setNum = 1;
  }
  return self;
}

- (void)viewDidLoad
{
  LOG()
  [super viewDidLoad];
  
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.backgroundColor = [UIColor colorWithRed:1.0 green:0.98 blue:0.98 alpha:1.0];
  _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
  [_indicator setColor:[UIColor darkGrayColor]];
  [_indicator setHidesWhenStopped:YES];
  [_indicator stopAnimating];
  
  LOG(@"n: %d", self.n)
  if (self.n == 1) {
    _isLoading = YES;
    _setNum += 15;
    _searchData = nil;
    self.resultCount.text = [self.locRs stringValue];
    _results = self.locRs;
    _searchData = [_dataManager fetchData];
    [_tableView reloadData];
  } else if (self.n == 2) {
    if (self.para) {
      //APIよりDATAの取得
      [self runAPI];
    } else {
      //paraが取得できない
      [self warning:@"検索条件に問題があります"];
    }
  }
}

- (void)runAPI
{
  LOG()
  @synchronized (self) {
//    _connection = [[TYKeywordSearchConn alloc] initWithTarget:self selector:@selector(getApiData) para:self.para];
    if (self.n == 1) {
      _location = [[TYLocationSearch alloc] initWithTarget:self selector:@selector(getApiData) set:_setNum];
      [[TYApplication application] addURLOperation:_connection];
    } else {
      _connection = [[TYKeywordSearchConn alloc] initWithTarget:self selector:@selector(getApiData) para:self.para set:_setNum];
      [[TYApplication application] addURLOperation:_connection];
    }
  }
}

- (void)getApiData {
  NSError *error = nil;
  NSString *json_str;
  if (self.n == 1) {
    json_str = [[NSString alloc] initWithData:_location.data encoding:NSUTF8StringEncoding];
  } else {
    json_str = [[NSString alloc] initWithData:_connection.data encoding:NSUTF8StringEncoding];
  }
  NSData *jsonData = [json_str dataUsingEncoding:NSUTF8StringEncoding];
  NSDictionary *data = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
  _results = [[data  objectForKey:@"results"] objectForKey:@"results_available"];
  NSNumber *n = [[data objectForKey:@"results"] objectForKey:@"results_returned"];
//  LOG(@"data_str:%@",json_str)
//  LOG(@"error %@", [[data objectForKey:@"results"] objectForKey:@"error"])
//  LOG(@"error %@", [data valueForKeyPath:@"results.error.message"])
//  LOG(@"data count %@", [[data objectForKey:@"results"] objectForKey:@"results_returned"])

  if (self.n == 1) {
    [_dataManager addData:data];
    _searchData = [_dataManager fetchData];
    _setNum += 15;
    [self.tableView reloadData];
    [self endIndicator];
    _isLoading = YES;
  } else if (self.n == 2) {
    int num = [n intValue];
    if (num == 0) {
      LOG(@"response null")
      [self warning:@"検索条件が正しくないか、もしくは条件を絞り込む必要があります"];
    } else {
      [_dataManager addKeywordSearchData:data];
       _searchData = nil;
      [_dataManager fetchKeywordSearchData:^(NSArray *ary){
        _searchData = ary;
        self.resultCount.text = [_results stringValue];
        _setNum += 15;
//        LOG(@"setNum %lu", _setNum)
        [_tableView reloadData];
        [self endIndicator];
        _isLoading = YES;
      }];
    }
  }
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

//遷移前パラメータセット
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([[segue identifier] isEqualToString:@"Detail"]) {
//    LOG(@"detail %@", segue.identifier)
    TYDetailViewController *detailCtr = segue.destinationViewController;
    detailCtr.para = _sid;
    TYAppDelegate *appDelegate = (TYAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.n = 1;
  }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//  LOG(@"row count %lu", _searchData.count)
  return _searchData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  LOG()
  TYSearchTableViewCell *cell = (TYSearchTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Shoplist" forIndexPath:indexPath];
  if (_searchData.count == 0) {
    LOG(@"null")
    cell.genru.text = @"";
    cell.name.text = @"";
    cell.area.text = @"";
  } else {
    SearchData *rowData = [_searchData objectAtIndex:indexPath.row];
    cell.genruRs.text = rowData.genre;
    cell.areaRs.text = rowData.area;
    CGFloat lineHeight = 20.0f;
    NSString *str = rowData.shop;
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.minimumLineHeight = lineHeight;
    paraStyle.maximumLineHeight = lineHeight;

    NSMutableAttributedString *attributeText = [[NSMutableAttributedString alloc] initWithString:str];
    [attributeText addAttribute:NSParagraphStyleAttributeName value:paraStyle range:NSMakeRange(0, attributeText.length)];
    cell.nameRs.attributedText = attributeText;
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
  SearchData *rowData = [_searchData objectAtIndex:indexPath.row];
  LOG(@"sid: %@", rowData.sid)
  _sid = rowData.sid;
  [self performSegueWithIdentifier:@"Detail" sender:self];
}

//スクロールビューページング
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
  if(self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height))
  {
    if (_isLoading) {
//      LOG(@"setNum: %ld results: %@", _setNum, _results)
      if (_setNum < [_results integerValue]) {
        [self startIndicator];
        _isLoading = NO;
        [self runAPI];
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

@end
