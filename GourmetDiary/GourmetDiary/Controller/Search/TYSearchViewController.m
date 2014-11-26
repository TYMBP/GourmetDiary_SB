//
//  TYSearchViewController.m
//  GourmetDiary
//
//  Created by Tomohiko on 2014/11/09.
//  Copyright (c) 2014年 yamatomo. All rights reserved.
//

#import "TYSearchViewController.h"
#import "TYResultViewController.h"
#import "TYDetailViewController.h"
#import "TYLocationSearch.h"
#import "TYApplication.h"
#import "TYGourmetDiaryManager.h"
#import "TYUtil.h"
#import "TYSearchTableViewCell.h"
//#import "TYLocationInfo.h"
#import "SearchData.h"

#define MORE_LABEL 100
#define SET_MORE 1
#define SET_SEARCH 2

@implementation TYSearchViewController {
  NSMutableData *_responseData;
  TYLocationSearch *_connection;
  TYGourmetDiaryManager *_dataManager;
  NSArray *_searchData;
  NSString *_shopMessage;
  NSString *_areaMessage;
  NSMutableDictionary *_para;
  NSString *_sid;
//  TYLocationInfo *_locationManager;
}

- (id)initWithCoder:(NSCoder *)coder
{
  self = [super initWithCoder:coder];
  if (self) {
    LOG()
    _dataManager = [TYGourmetDiaryManager sharedmanager];
//    _locationManager = [TYLocationInfo sharedManager];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.backgroundColor = [UIColor colorWithRed:1.0 green:0.4 blue:0.4 alpha:1.0];

  self.searchBtn.layer.borderColor = [[UIColor whiteColor] CGColor];
  self.searchBtn.layer.borderWidth = 1;
  self.searchBtn.layer.cornerRadius = 5;

//  _more.tag = MORE_LABEL;
//  _more.userInteractionEnabled = YES;
  
//   APIよりDATAの取得
  [self runAPI];
//  [self getLc];
}

/* 位置情報の取得テスト
- (void)getLc
{
  LOG()
  NSArray *ary = [_locationManager getLocationValue];
  NSNumber *latObj = [ary objectAtIndex:1];
  NSNumber *lngObj = [ary objectAtIndex:0];
  double lat = fabs(latObj.doubleValue);
  double lng = fabs(lngObj.doubleValue);
  
  if (lat == 0 && lng == 0) {
    LOG(@"lat: %fu lng: %fu", lat, lng)
  } else {
    LOG(@"lat: %fu lng: %fu", lat, lng)
  }
}
*/


- (void)warning:(NSString *)mess
{
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"入力エラー" message:mess preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
    LOG(@"OK tap")
  }];
  [alert addAction:ok];
  [self presentViewController:alert animated:YES completion:nil];
}

- (void)runAPI
{
  LOG()
  [_dataManager resetData];
  @synchronized (self) {
    _connection = [[TYLocationSearch alloc] initWithTarget:self selector:@selector(getApiData)];
    [[TYApplication application] addURLOperation:_connection];
  }
}

- (void)getApiData {
  LOG_METHOD;
  NSError *error = nil;
  NSString *json_str = [[NSString alloc] initWithData:_connection.data encoding:NSUTF8StringEncoding];
//  LOG(@"data_str:%@",json_str)
  NSData *jsonData = [json_str dataUsingEncoding:NSUTF8StringEncoding];
  NSDictionary *data = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
  [_dataManager addData:data];
  _searchData = [_dataManager fetchData];
  [self.tableView reloadData];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
  LOG()
  if ([sender isEqual:self.searchBtn]) { //キーワード検索
    //keyword検索バリデーション
    _shopMessage = nil;
    _areaMessage = nil;
    [self.shopKeyword resignFirstResponder];
    [self.areaStation resignFirstResponder];
    _para = [NSMutableDictionary dictionary];
   
    //バリデーション
    if ([self.shopKeyword.text length] == 0 && [self.areaStation.text length] == 0) {
      [self warning:@"検索ワードを入力してください"];
      return NO;
    } else {
      _shopMessage = [TYUtil checkKeyword:_shopKeyword.text];
      LOG(@"shopMessage %@", _shopMessage)
      _areaMessage = [TYUtil checkKeyword:_areaStation.text];
      LOG(@"areaMessage %@", _areaMessage)
      if ([_shopMessage length] != 0) {
        LOG(@"message error")
        [self warning:_shopMessage];
      } else if ([_areaMessage length] != 0) {
        LOG(@"message error")
        [self warning:_areaMessage];
      }
      [_para setValue:self.shopKeyword.text forKey:@"shop"];
      [_para setValue:self.areaStation.text forKey:@"area"];
      return YES;
    }
  }
  return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  TYResultViewController *resultCtr = segue.destinationViewController;
  if ([sender isEqual:self.moreBtn]) { //もっとみる
    LOG(@"more")
    resultCtr.n = SET_MORE;
  } else if ([sender isEqual:self.searchBtn]) { //キーワード検索
    resultCtr.n = SET_SEARCH;
    LOG(@"search %d", resultCtr.n)
    resultCtr.para = _para;
  } else if ([[segue identifier] isEqualToString:@"Detail"]) {
    LOG(@"detail %@", segue.identifier)
    TYDetailViewController *detailCtr = segue.destinationViewController;
    detailCtr.para = _sid;
  }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  TYSearchTableViewCell *cell = (TYSearchTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Shoplist" forIndexPath:indexPath];
  NSInteger n = indexPath.row + 1;
  if (_searchData.count < 4 && _searchData.count < n) {
    cell.genru.text = @"";
    cell.name.text = @"";
    cell.address.text = @"";
  } else {
    SearchData *rowData = [_searchData objectAtIndex:indexPath.row];
//  LOG(@"searchdata: %@", rowData.shop)
    cell.genru.text = rowData.genre;
    cell.name.text = rowData.shop;
    cell.address.text = rowData.address;
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


@end
