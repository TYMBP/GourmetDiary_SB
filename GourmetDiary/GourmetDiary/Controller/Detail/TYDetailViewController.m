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
#import "TYUtil.h"
#import "ShopMst.h"
#import "TYAppDelegate.h"

@implementation TYDetailViewController {
  TYGourmetDiaryManager *_dataManager;
  ShopMst *_shopData;
  TYDetailSearchConn *_connection;
}

- (id)initWithCoder:(NSCoder *)coder
{
  LOG()
  self = [super initWithCoder:coder];
  if (self) {
    _dataManager = [TYGourmetDiaryManager sharedmanager];
  }
  return self;
}

- (void)viewDidLoad
{
  LOG()
  [super viewDidLoad];

  TYAppDelegate *appDelegate;
  appDelegate = (TYAppDelegate *)[[UIApplication sharedApplication] delegate];
  NSString *sid = appDelegate.sid;
  int n = appDelegate.n;
  
  self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.60 green:0.80 blue:0.20 alpha:1.0];
  self.mapBtn.layer.borderColor = [[UIColor colorWithRed:0.60 green:0.80 blue:0.20 alpha:1.0] CGColor];
  self.mapBtn.layer.borderWidth = 1;
  self.mapBtn.layer.cornerRadius = 5;
  self.nextBtn.layer.borderColor = [[UIColor colorWithRed:0.60 green:0.80 blue:0.20 alpha:1.0] CGColor];
  self.nextBtn.layer.borderWidth = 1;
  self.nextBtn.layer.cornerRadius = 5;
 
  if (n == 1) {
    LOG()
    if (self.para) {
      LOG(@"para: %@", self.para)
      //APIよりDATAの取得
      [self runAPI];
    } else {
      //paraが取得できない
      [self warning:@"問題発生しました"];
    }
  } else if (n == 2) {
    LOG()
    self.para = sid;
    [self runAPI];
  } else if (n == 3) {
    LOG()
    if (![_dataManager fetchDetailData:sid detailData:^(NSArray *ary) {
      
      LOG(@"ary:%@",ary)
      NSDictionary *dic = [ary objectAtIndex:0];
      self.name.text = [dic valueForKey:@"shop"];
      self.area.text = [dic valueForKey:@"area"];
      self.genre.text = [dic valueForKey:@"genre"];
      if ([dic valueForKey:@"address"]) {
        self.address.text = [dic valueForKey:@"address"];
      } else {
        self.address.text = @"住所 未登録";
      }
      if ([dic valueForKey:@"img_path"]) {
        self.shopImage.image = nil;
        NSURL *url = [NSURL URLWithString:[dic valueForKey:@"img_path"]];
        LOG(@"url:%@",[dic valueForKey:@"img_path"])
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *img = [UIImage imageWithData:data];
        self.shopImage.image = img;
      } else {
        self.mapBtn.alpha = 0.5;
        self.mapBtn.enabled = NO;
      }
      
      NSString *countNum = [[NSString alloc] initWithFormat:@"%ld", (long)[_dataManager fetchVisitCount:sid]];
      self.visitCount.text = [NSString stringWithFormat:@"%@回", countNum];
      NSInteger n = [_dataManager fetchShopLevel:sid];
      if (n == 0) {
        self.level.text = @"来店記録なし";
      } else {
        self.level.text = [[TYUtil levelList] objectAtIndex:n];
      }
    }]) {
      [self warning:@"データが取得出来ません"];
      [self.navigationController popToRootViewControllerAnimated:YES];
    }
    CGRect posi = self.nextBtn.frame;
    LOG(@"posi:%f", posi.origin.x)
    [self.nextBtn removeFromSuperview];
    UIButton *returnBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    returnBtn.frame = CGRectMake(posi.origin.x-100, posi.origin.y+20, 200, 40);
    [returnBtn setTitle:@"戻る" forState:UIControlStateNormal];
    [returnBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [returnBtn setBackgroundColor:[UIColor colorWithRed:0.60 green:0.80 blue:0.20 alpha:1.0]];
    returnBtn.layer.borderColor = [[UIColor colorWithRed:0.60 green:0.80 blue:0.20 alpha:1.0] CGColor];
    returnBtn.layer.borderWidth = 1;
    returnBtn.layer.cornerRadius = 5;
    returnBtn.titleLabel.font = [UIFont fontWithName:@"HirakakuProN-W6" size:17];
    [returnBtn addTarget:self action:@selector(returnEditor) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:returnBtn];
    
  }
}

//戻る
- (void)returnEditor
{
  UINavigationController *vc = self.tabBarController.viewControllers[1];
  self.tabBarController.selectedViewController = vc;
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
    self.area.text = _shopData.area;
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
  NSString *countNum = [[NSString alloc] initWithFormat:@"%ld", (long)[_dataManager fetchVisitCount:self.para]];
  self.visitCount.text = [NSString stringWithFormat:@"%@回", countNum];
  NSInteger n = [_dataManager fetchShopLevel:self.para];
//  NSArray *ary = [TYUtil levelList];
//  LOG(@"level: %@", [ary objectAtIndex:n])
  if (n == 0) {
    self.level.text = @"来店記録なし";
  } else {
    self.level.text = [[TYUtil levelList] objectAtIndex:n];
  }
}


#pragma mark - segue
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
