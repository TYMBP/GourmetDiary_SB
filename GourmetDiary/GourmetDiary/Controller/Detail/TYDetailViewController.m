//
//  TYDetailViewController.m
//  GourmetDiary
//
//  Created by Tomohiko on 2014/11/21.
//  Copyright (c) 2014年 yamatomo. All rights reserved.
//

#import "TYDetailViewController.h"
#import "TYRegisterViewController.h"
#import "TYMapViewController.h"
#import "TYGourmetDiaryManager.h"
#import "TYDetailSearchConn.h"
#import "TYApplication.h"
#import "ShopMst.h"
#import "TYAppDelegate.h"

@implementation TYDetailViewController {
  TYGourmetDiaryManager *_dataManager;
  ShopMst *_shopData;
  TYDetailSearchConn *_connection;
}

- (id)initWithCoder:(NSCoder *)coder
{
  self = [super initWithCoder:coder];
  if (self) {
    LOG()
    _dataManager = [TYGourmetDiaryManager sharedmanager];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  TYAppDelegate *appDelegate;
  appDelegate = (TYAppDelegate *)[[UIApplication sharedApplication] delegate];
  NSString *sid = appDelegate.sid;
  int n = appDelegate.n;
  
  self.mapBtn.layer.borderColor = [[UIColor whiteColor] CGColor];
  self.mapBtn.layer.borderWidth = 1;
  self.mapBtn.layer.cornerRadius = 5;
  self.telBtn.layer.borderColor = [[UIColor whiteColor] CGColor];
  self.telBtn.layer.borderWidth = 1;
  self.telBtn.layer.cornerRadius = 5;
  self.hookBtn.layer.borderColor = [[UIColor whiteColor] CGColor];
  self.hookBtn.layer.borderWidth = 1;
  self.hookBtn.layer.cornerRadius = 5;
  self.nextBtn.layer.borderColor = [[UIColor whiteColor] CGColor];
  self.nextBtn.layer.borderWidth = 1;
  self.nextBtn.layer.cornerRadius = 5;
 
  if (n == 1) {
    if (self.para) {
      LOG(@"para: %@", self.para)
      //APIよりDATAの取得
      [self runAPI];
    } else {
      //paraが取得できない
      [self warning:@"問題発生しました"];
    }
  } else if (n == 2) {
    self.para = sid;
    [self runAPI];
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

//ショップ詳細データ取得
- (void)runAPI
{
  LOG()
  [_dataManager resetKeywordSearchData];
  @synchronized (self) {
    _connection = [[TYDetailSearchConn alloc] initWithTarget:self selector:@selector(getApiData) para:self.para];
    [[TYApplication application] addURLOperation:_connection];
  }
}

- (void)getApiData {
  NSError *error = nil;
  NSString *json_str = [[NSString alloc] initWithData:_connection.data encoding:NSUTF8StringEncoding];
//  LOG(@"data_str:%@",json_str)
  NSData *jsonData = [json_str dataUsingEncoding:NSUTF8StringEncoding];
  NSDictionary *data = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
  if (error) {
    LOG(@"error %@", [[data valueForKeyPath:@"results.error.message"] objectForKey:0])
  }
  LOG(@"data count %@", [[data objectForKey:@"results"] objectForKey:@"results_returned"])
  
  _shopData = nil;
  
  [_dataManager tempShopData:data setData:^(ShopMst *master){
    LOG(@"master: %@", master)
    _shopData = master;
    self.name.text = _shopData.shop;
    //_levelData.text
    self.genre.text = _shopData.genre;
    self.address.text = _shopData.address;
    //visited.text
//    [self.shopImage removeFromSuperview];
    self.shopImage.image = nil;
    NSURL *url = [NSURL URLWithString:_shopData.img_path];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *img = [UIImage imageWithData:data];
    self.shopImage.image = img;
  }];
}

//遷移前パラメータセット
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([[segue identifier] isEqualToString:@"Register"]) {
    LOG()
    TYRegisterViewController *registerCtr = segue.destinationViewController;
    registerCtr.shopMst = _shopData;
  } else if ([[segue identifier] isEqualToString:@"Map"]) {
    LOG()
    TYMapViewController *mapCtr = segue.destinationViewController;
    mapCtr.shopMst = _shopData;
  }
}


@end
