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
#import "TYAppDelegate.h"
#import "TYGourmetDiaryManager.h"
#import "TYUtil.h"
#import "TYSearchTableViewCell.h"
//#import "TYLocationInfo.h"
#import "SearchData.h"

#define MORE_LABEL 100
#define SET_MORE 1
#define SET_SEARCH 2
#define TF_GENRE 3

@implementation TYSearchViewController {
  NSMutableData *_responseData;
  TYLocationSearch *_connection;
  TYGourmetDiaryManager *_dataManager;
  NSArray *_searchData;
  NSString *_shopMessage;
  NSString *_genreMessage;
  NSMutableDictionary *_para;
  NSString *_sid;
  NSInteger _setNum;
  NSNumber *_results;
  UIPickerView *_picker;
  NSUInteger _genreNum;
  NSArray *_genreList;
  UIToolbar *_toolbar;
  UIView *_backView;
}

- (id)initWithCoder:(NSCoder *)coder
{
  self = [super initWithCoder:coder];
  if (self) {
    //picker用
    _genreList = [TYUtil genreList];
    _dataManager = [TYGourmetDiaryManager sharedmanager];
//    _locationManager = [TYLocationInfo sharedManager];
  }
  return self;
}

- (void)viewDidLoad
{
  LOG()
  [super viewDidLoad];
  
  self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.60 green:0.80 blue:0.20 alpha:1.0];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.backgroundColor = [UIColor colorWithRed:1.0 green:0.98 blue:0.98 alpha:1.0];
  self.searchBtn.layer.borderColor = [[UIColor colorWithRed:0.60 green:0.80 blue:0.20 alpha:1.0] CGColor];
  self.searchBtn.layer.borderWidth = 1;
  self.searchBtn.layer.cornerRadius = 5;
  _setNum = 1;
  _genreNum = 0;

  _picker = [self makePicker];
  _toolbar = [self makeToolbar:CGRectMake(0, 0, 320, 44)];
  self.genreSearch.tag = TF_GENRE;
  self.genreSearch.inputView = _picker;
  self.genreSearch.inputAccessoryView = _toolbar;
  _backView = [[UIView alloc] initWithFrame:self.view.frame];
  _backView.backgroundColor = [UIColor clearColor];
  _backView.hidden = YES;
  _backView.userInteractionEnabled = NO;
  [self.view addSubview:_backView];
  
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

- (void)done:(id)sender
{
  _backView.hidden = YES;
  [self.genreSearch resignFirstResponder];
}

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
    _connection = [[TYLocationSearch alloc] initWithTarget:self selector:@selector(getApiData) set:_setNum];
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
  _results = [[data  objectForKey:@"results"] objectForKey:@"results_available"];
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
    _genreMessage = nil;
    [self.shopKeyword resignFirstResponder];
    [self.genreSearch resignFirstResponder];
    _para = [NSMutableDictionary dictionary];
   
    //バリデーション
    if ([self.shopKeyword.text length] == 0 && [self.genreSearch.text length] == 0) {
      [self warning:@"検索ワードを入力してください"];
      return NO;
    } else {
      _shopMessage = [TYUtil checkKeyword:_shopKeyword.text];
      _genreMessage = [TYUtil checkKeyword:_genreSearch.text];
      if ([_shopMessage length] != 0) {
        LOG(@"message error")
        [self warning:_shopMessage];
      } else if ([_genreMessage length] != 0) {
        LOG(@"message error")
        [self warning:_genreMessage];
      }
      
      [_para setValue:self.shopKeyword.text forKey:@"shop"];
      [_para setValue:[NSNumber numberWithInteger:_genreNum] forKey:@"genre"];
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
    resultCtr.locRs = _results;
  } else if ([sender isEqual:self.searchBtn]) { //キーワード検索
    resultCtr.n = SET_SEARCH;
    LOG(@"search %d", resultCtr.n)
    resultCtr.para = _para;
  } else if ([[segue identifier] isEqualToString:@"Detail"]) {
    LOG(@"detail %@", segue.identifier)
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
  return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  TYSearchTableViewCell *cell = (TYSearchTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Shoplist" forIndexPath:indexPath];
  NSInteger n = indexPath.row + 1;
  if (_searchData.count < 4 && _searchData.count < n) {
    cell.genru.text = @"";
    cell.name.text = @"";
    cell.area.text = @"";
  } else {
    SearchData *rowData = [_searchData objectAtIndex:indexPath.row];
//  LOG(@"searchdata: %@", rowData.shop)
    cell.genru.text = rowData.genre;
    cell.area.text = rowData.area;

    CGFloat lineHeight = 20.0f;
    NSString *str = rowData.shop;
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.minimumLineHeight = lineHeight;
    paraStyle.maximumLineHeight = lineHeight;

    NSMutableAttributedString *attributeText = [[NSMutableAttributedString alloc] initWithString:str];
    [attributeText addAttribute:NSParagraphStyleAttributeName value:paraStyle range:NSMakeRange(0, attributeText.length)];
    cell.name.attributedText = attributeText;
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

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
  NSInteger n = [_genreList count];
  return n;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
  return [_genreList objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
  self.genreSearch.text = [NSString stringWithFormat:@"%@", _genreList[row]];
  _genreNum = row;
  LOG(@"_genreNum:%lu %@", _genreNum, [_genreList objectAtIndex:row]);
  
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  //キーボード閉じる
  [self.view.subviews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop){
    if ([obj isKindOfClass:[UITextView class]]) {
      LOG()
      _backView.hidden = YES;
      [obj resignFirstResponder];
    } else if ([obj isKindOfClass:[UITextField class]]) {
      LOG()
      _backView.hidden = YES;
      [obj resignFirstResponder];
    } else {
    }
  }];
}

@end
