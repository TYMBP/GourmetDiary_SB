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
#import "TYMasterViewController.h"
#import "TYGourmetDiaryManager.h"

#define TF_GENRE 1

@implementation TYShopViewController {
  TYGourmetDiaryManager *_dataManager;
  NSString *_shopMessage;
  NSString *_areaMessage;
  NSMutableDictionary *_para;
  NSArray *_genreList;
  UIPickerView *_picker;
  NSUInteger _genreNum;
  UIToolbar *_toolbar;
  UIView *_backView;
  BOOL _masterFlg;
}

- (void)viewDidLoad
{
  LOG()
  [super viewDidLoad];
 
  _dataManager = [TYGourmetDiaryManager sharedmanager];
  
  _genreList = [TYUtil genreList];
  self.nextBtn.layer.borderColor = [[UIColor whiteColor] CGColor];
  self.nextBtn.layer.borderColor = [[UIColor colorWithRed:0.60 green:0.80 blue:0.20 alpha:1.0] CGColor];
  self.nextBtn.layer.borderWidth = 1;
  self.nextBtn.layer.cornerRadius = 5;
  self.masterBtn.layer.borderColor = [[UIColor colorWithRed:0.60 green:0.80 blue:0.20 alpha:1.0] CGColor];
  self.masterBtn.layer.borderWidth = 1;
  self.masterBtn.layer.cornerRadius = 5;
  
  if (![_dataManager fetchMasterCount]) {
    LOG()
    self.masterBtn.alpha = 0.3;
    self.masterBtn.enabled = NO;
  }
  
  _genreNum = 0;
  _picker = [self makePicker];
  _toolbar = [self makeToolbar:CGRectMake(0, 0, 320, 44)];
  self.genre.tag = TF_GENRE;
  self.genre.inputView = _picker;
  self.genre.inputAccessoryView = _toolbar;
  _backView = [[UIView alloc] initWithFrame:self.view.frame];
  _backView.backgroundColor = [UIColor clearColor];
  _backView.hidden = YES;
  _backView.userInteractionEnabled = NO;
  [self.view addSubview:_backView];
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

- (void)done:(id)sender
{
  _backView.hidden = YES;
  [self.genre resignFirstResponder];
}
- (IBAction)returnList:(id)sender {
  LOG()
  [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - segue
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
  LOG()
  if ([sender isEqual:self.nextBtn]) { //キーワード検索
    //keyword検索バリデーション
    _shopMessage = nil;
    _areaMessage = nil;
    [self.name resignFirstResponder];
    [self.area resignFirstResponder];
    [self.genre resignFirstResponder];
    _para = [NSMutableDictionary dictionary];
   
    //バリデーション
    if ([self.name.text length] == 0 || [self.area.text length] == 0 || [self.genre.text length] == 0) {
      [self warning:@"未入力の箇所があります"];
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
      [_para setValue:self.genre.text forKey:@"genre"];
      [_para setValue:self.area.text forKey:@"area"];
      [_para setValue:[self setSid] forKey:@"sid"];
      
      return YES;
    }
  }
  return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([[segue identifier] isEqualToString:@"Masterdata"]) {
    LOG()
  } else if ([[segue identifier] isEqualToString:@"Visitdata"]) {
    LOG()
    TYEditorViewController *editorCtr = segue.destinationViewController;
    editorCtr.shopDic = _para;
    editorCtr.masterFlg = YES;
    TYAppDelegate *appDelegate;
    appDelegate = (TYAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.editStatus = 2;
  }
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

#pragma mark - pickerView
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
  self.genre.text = [NSString stringWithFormat:@"%@", _genreList[row]];
  _genreNum = row;
//  LOG(@"_genreNum:%lu %@", _genreNum, [_genreList objectAtIndex:row]);
  
}

#pragma mark - touchesbegan
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
      //LOG()
    }
  }];
}

@end
