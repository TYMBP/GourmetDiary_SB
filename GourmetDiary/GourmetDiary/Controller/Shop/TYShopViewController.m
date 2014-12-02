//
//  TYShopViewController.m
//  GourmetDiary
//
//  Created by Tomohiko on 2014/11/29.
//  Copyright (c) 2014年 yamatomo. All rights reserved.
//

#import "TYShopViewController.h"
#import "TYUtil.h"
#import "TYEditorViewController.h"
#import "TYAppDelegate.h"

@implementation TYShopViewController {
  NSString *_shopMessage;
  NSString *_areaMessage;
  NSMutableDictionary *_para;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.nextBtn.layer.borderColor = [[UIColor whiteColor] CGColor];
  self.nextBtn.layer.borderWidth = 1;
  self.nextBtn.layer.cornerRadius = 5;
  
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

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
  LOG()
  if ([sender isEqual:self.nextBtn]) { //キーワード検索
    //keyword検索バリデーション
    _shopMessage = nil;
    _areaMessage = nil;
    [self.name resignFirstResponder];
    [self.kana resignFirstResponder];
    [self.area resignFirstResponder];
    [self.tel resignFirstResponder];
    [self.genre resignFirstResponder];
    _para = [NSMutableDictionary dictionary];
   
    //バリデーション
    if ([self.name.text length] == 0 && [self.area.text length] == 0 && [self.genre.text length] == 0) {
      [self warning:@"検索ワードを入力してください"];
      return NO;
    } else {
      _shopMessage = [TYUtil checkLength:self.name.text];
      if ([_shopMessage length] != 0) {
        LOG(@"message error")
        [self warning:_shopMessage];
      } else if ([_areaMessage length] != 0) {
        LOG(@"message error")
        [self warning:_areaMessage];
      }
      [_para setValue:self.name.text forKey:@"shop"];
      [_para setValue:self.kana.text forKey:@"kana"];
      [_para setValue:self.genre.text forKey:@"genre"];
      [_para setValue:self.area.text forKey:@"area"];
      [_para setValue:self.tel.text forKey:@"tel"];
      [_para setValue:[self setSid] forKey:@"sid"];
     LOG(@"name %@", self.name.text)
      
      
      return YES;
    }
  }
  return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  LOG()
  TYEditorViewController *editorCtr = segue.destinationViewController;
  editorCtr.shopDic = _para;
  TYAppDelegate *appDelegate;
  appDelegate = (TYAppDelegate *)[[UIApplication sharedApplication] delegate];
  appDelegate.n = 2;
  
}

- (NSString *)setSid
{
  NSDate *now = [NSDate date];
  double unix = [now timeIntervalSince1970];
  int time = floor(unix);
  
  NSString *sid = [NSString stringWithFormat:@"S%d", time];
  NSLog(@"sid: %@", sid);
  
  return sid;
}

@end
