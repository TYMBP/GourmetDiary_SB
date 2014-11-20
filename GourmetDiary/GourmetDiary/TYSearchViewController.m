//
//  TYSearchViewController.m
//  GourmetDiary
//
//  Created by Tomohiko on 2014/11/09.
//  Copyright (c) 2014年 yamatomo. All rights reserved.
//

#import "TYSearchViewController.h"
#import "TYLocationSearch.h"
#import "TYApplication.h"
#import "TYGourmetDiaryManager.h"
#import "TYUtil.h"
#import "TYSearchTableViewCell.h"
//#import "TYLocationInfo.h"
#import "SearchData.h"

#define MORE_LABEL 100

@implementation TYSearchViewController {
  NSMutableData *_responseData;
  TYLocationSearch *_connection;
  TYGourmetDiaryManager *_dataManager;
  NSArray *_searchData;
  NSString *_shopMessage;
  NSString *_areaMessage;
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

//検索スタート
//- (void)searchStart
//{
//  LOG()
//  _shopMessage = nil;
//  _areaMessage = nil;
//  [_shopKeyword resignFirstResponder];
//  [_areaStation resignFirstResponder];
//  NSMutableDictionary *para = [NSMutableDictionary dictionary];
// 
//  //バリデーション
//  if ([_shopKeyword.text length] == 0 && [_areaStation.text length] == 0) {
//    [self warning:@"検索ワードを入力してください"];
//  } else {
//    _shopMessage = [TYUtil checkKeyword:_shopKeyword.text];
//    LOG(@"shopMessage %@", _shopMessage)
//    _areaMessage = [TYUtil checkKeyword:_areaStation.text];
//    LOG(@"areaMessage %@", _areaMessage)
//    if ([_shopMessage length] != 0) {
//      LOG(@"message error")
//      [self warning:_shopMessage];
//    } else if ([_areaMessage length] != 0) {
//      LOG(@"message error")
//      [self warning:_areaMessage];
//    }
//    [para setValue:_shopKeyword.text forKey:@"shop"];
//    [para setValue:_areaStation.text forKey:@"area"];
//    
//    TYResultViewController *resultVC = [[TYResultViewController alloc] initWithNibName:nil bundle:nil set:2 para:para];
//    [self.navigationController pushViewController:resultVC animated:YES];
//  }
//}

- (void)warning:(NSString *)mess
{
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"入力エラー" message:mess preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
    LOG(@"OK tap")
  }];
  [alert addAction:ok];
  [self presentViewController:alert animated:YES completion:nil];
}

//もっとみる
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  UITouch *touch = [[event allTouches] anyObject];
//  if (touch.view.tag == _more.tag) {
//    LOG()
//    TYResultViewController *resultVC = [[TYResultViewController alloc] initWithNibName:nil bundle:nil set:1 para:nil];
//    [self.navigationController pushViewController:resultVC animated:YES];
//  }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
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
//  LOG(@"indexPath %lu", indexPath.row)
  SearchData *rowData = [_searchData objectAtIndex:indexPath.row];
  LOG(@"searchdata: %@", rowData.shop)
  TYSearchTableViewCell *cell = (TYSearchTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Shoplist" forIndexPath:indexPath];
  cell.genru.text = rowData.genre;
  cell.name.text = rowData.shop;
  cell.address.text = rowData.address;
  
  return cell;
}

//タップイベント
#pragma mark - Table view delegate
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//  [tableView deselectRowAtIndexPath:indexPath animated:YES];
//  SearchData *rowData = [_searchData objectAtIndex:indexPath.row];
//  LOG(@"sid: %@", rowData.sid)
//  NSString *para = rowData.sid;
//  TYDetailViewController *detailVC = [[TYDetailViewController alloc] initWithNibName:nil bundle:nil para:para];
//  [self.navigationController pushViewController:detailVC animated:YES];
//}


@end
