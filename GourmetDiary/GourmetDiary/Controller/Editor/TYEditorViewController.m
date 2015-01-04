//
//  TYEditorViewController.m
//  GourmetDiary
//
//  Created by Tomohiko on 2014/11/26.
//  Copyright (c) 2014年 yamatomo. All rights reserved.
//

#import "TYEditorViewController.h"
#import "TYGourmetDiaryManager.h"
#import "TYAppDelegate.h"
#import "TYUtil.h"
#import "ShopMst.h"

#define SET_TOP 1
#define SET_SHOP 2
#define TF_CALENDAR 1
#define TF_SITUATION 2
#define TF_LEVEL 3
#define TF_PERSON 4
#define TF_FEE 5

@implementation TYEditorViewController {
  TYAppDelegate *_appDelegate;
  TYGourmetDiaryManager *_dataManager;
  NSDateFormatter *_dateFomatter;
  NSMutableDictionary *_dic;
  NSString *_sid;
  int _n;
  UIDatePicker *_picker;
  UIPickerView *_picker2;
  UIPickerView *_picker3;
  UIPickerView *_picker4;
  UIPickerView *_picker5;
  NSUInteger _levelNum;
  NSUInteger _situNum;
  NSUInteger _personNum;
  NSUInteger _feeNum;
  NSArray *_levelList;
  NSArray *_situList;
  NSArray *_personList;
  NSArray *_feeList;
  NSUInteger _tagNum;
  UIToolbar *_toolbar;
  UIToolbar *_toolbar2;
  UIToolbar *_toolbar3;
  UIToolbar *_toolbar4;
  UIToolbar *_toolbar5;
  UIView *_backView;
  BOOL _observing;
  BOOL _newFlag;
  BOOL _pickerFlag;
  BOOL _tapFlg;
  id _oid;
}

- (id)initWithCoder:(NSCoder *)coder
{
  LOG()
  self = [super initWithCoder:coder];
  
  if (self) {
    _observing = NO;
    _dateFomatter = [[NSDateFormatter alloc] init];
     [_dateFomatter setDateFormat:@"yy/MM/dd"];
    _dataManager = [TYGourmetDiaryManager sharedmanager];
    //picker用
    _levelList = [TYUtil levelList];
    _situList = [TYUtil situationList];
    _personList = [TYUtil personList];
    _feeList = [TYUtil feeList];
  }
  return self;
}

- (void)viewDidLoad
{
  LOG()
  [super viewDidLoad];
 
  _dic = nil;
  _sid = nil;
  _pickerFlag = NO;
  _tapFlg = NO;
  
  self.editBtn.layer.borderColor = [[UIColor colorWithRed:0.60 green:0.80 blue:0.20 alpha:1.0] CGColor];
  self.editBtn.layer.borderWidth = 1;
  self.editBtn.layer.cornerRadius = 5;
  self.deleteBtn.layer.borderColor = [[UIColor colorWithRed:0.60 green:0.80 blue:0.20 alpha:1.0] CGColor];
  self.deleteBtn.layer.borderWidth = 1;
  self.deleteBtn.layer.cornerRadius = 5;
  
  _appDelegate = (TYAppDelegate *)[[UIApplication sharedApplication] delegate];
  _sid = _appDelegate.sid;
  _n = _appDelegate.editStatus;
  _oid = _appDelegate.oid;
  LOG(@"oid:%@", _oid)
  
  _dateFomatter = [[NSDateFormatter alloc] init];
  [_dateFomatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"JST"]];
  [_dateFomatter setDateFormat:@"yyyy/MM/dd"];
  
  if (_n == 1) {
    LOG()
    _dic = [[_dataManager fetchDiaryData:_oid] objectAtIndex:0];
    self.naviTitle.title = [_dic valueForKey:@"shop"];
    self.dou.text = [_dateFomatter stringFromDate:[_dic valueForKey:@"visited_at"]];
    self.dou.enabled = NO;
    self.situation.text = [TYUtil setSituationPickerText:[_dic valueForKey:@"situation"]];
    self.situation.enabled = NO;
    _situNum = [[_dic valueForKey:@"situation"] integerValue];
    self.level.text = [TYUtil setLevelPickerText:[_dic valueForKey:@"level"]];
    self.level.enabled = NO;
    _levelNum = [[_dic valueForKey:@"level"] integerValue];
    self.persons.text = [TYUtil setPersonsText:[_dic valueForKey:@"persons"]];
    self.persons.enabled = NO;
    _personNum = [[_dic valueForKey:@"persons"] integerValue];
    self.fee.text = [TYUtil setFeePickerText:[_dic valueForKey:@"fee"]];
    self.fee.enabled = NO;
    _feeNum = [[_dic valueForKey:@"fee"] integerValue];
    self.comment.text = [_dic valueForKey:@"memo"];
    self.comment.editable = NO;
    self.comment.delegate = self;
    
  } else if (_n == 2) {
    if (self.shopDic) {
      LOG(@"shopDic:%d", self.masterFlg)
      _newFlag = YES;
      self.naviTitle.title = [self.shopDic valueForKey:@"shop"];
      [self.editBtn setTitle:@"登録する" forState:UIControlStateNormal];
      self.deleteBtn.enabled = NO;
      self.deleteBtn.alpha = 0.3;
      self.dou.text = [_dateFomatter stringFromDate:[NSDate date]];
    } else {
      [self warning:@"登録エラーがあります"];
    }
  }
  self.dou.tag = TF_CALENDAR;
  self.situation.tag = TF_SITUATION;
  self.level.tag = TF_LEVEL;
  self.persons.tag = TF_PERSON;
  self.fee.tag = TF_FEE;
  self.dou.delegate = self;
  self.situation.delegate = self;
  self.level.delegate = self;
  self.persons.delegate = self;
  self.fee.delegate = self;
  _picker = [[UIDatePicker alloc] init];
  _picker.minuteInterval = 1;
  _picker.datePickerMode = UIDatePickerModeDate;
  [_picker addTarget:self action:@selector(datePickerEventValueChanged) forControlEvents:UIControlEventValueChanged];
  
  _picker.tag = TF_CALENDAR;
  self.dou.inputView = _picker;
  _picker2 = [self makePicker];
  _picker2.tag = TF_SITUATION;
  self.situation.inputView = _picker2;
  _picker3 = [self makePicker];
  _picker3.tag = TF_LEVEL;
  self.level.inputView = _picker3;
  _picker4 = [self makePicker];
  _picker4.tag = TF_PERSON;
  self.persons.inputView = _picker4;
  _picker5 = [self makePicker];
  _picker5.tag = TF_FEE;
  self.fee.inputView = _picker5;
  _toolbar = [self makeToolbar:CGRectMake(0, 0, 320, 44)];
  _toolbar.tag = TF_CALENDAR;
  _toolbar2 = [self makeToolbar:CGRectMake(0, 0, 320, 44)];
  _toolbar2.tag = TF_SITUATION;
  _toolbar3 = [self makeToolbar:CGRectMake(0, 0, 320, 44)];
  _toolbar3.tag = TF_LEVEL;
  _toolbar4 = [self makeToolbar:CGRectMake(0, 0, 320, 44)];
  _toolbar4.tag = TF_PERSON;
  _toolbar5 = [self makeToolbar:CGRectMake(0, 0, 320, 44)];
  _toolbar5.tag = TF_FEE;
  self.dou.inputAccessoryView = _toolbar;
  self.situation.inputAccessoryView = _toolbar2;
  self.level.inputAccessoryView = _toolbar3;
  self.persons.inputAccessoryView = _toolbar4;
  self.fee.inputAccessoryView = _toolbar5;
  _backView = [[UIView alloc] initWithFrame:self.view.frame];
  _backView.backgroundColor = [UIColor clearColor];
  _backView.hidden = YES;
  _backView.userInteractionEnabled = NO;
  [self.onView addSubview:_backView];
}

//通知セット
- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  if (!_observing) {
    NSNotificationCenter *center;
    center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(keyboardWillShow:)
                   name:UIKeyboardWillShowNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(keyboardWillHide:)
                   name:UIKeyboardWillHideNotification
                 object:nil];
    _observing = YES;
  }
}

//通知解除
- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
  if (_observing) {
    NSNotificationCenter *center;
    center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self
                      name:UIKeyboardWillShowNotification
                    object:nil];
    [center removeObserver:self
                      name:UIKeyboardWillShowNotification
                    object:nil];
    _observing = NO;
  }
}

- (UIPickerView *)makePicker
{
  UIPickerView *picker = [[UIPickerView alloc] init];
  picker.showsSelectionIndicator = YES;
  picker.delegate = self;
  picker.dataSource = self;
 
  return picker;
}

- (UIToolbar *)makeToolbar:(CGRect)rect
{
  UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
  toolbar.barStyle = UIBarStyleBlack;
  [toolbar sizeToFit];
  UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
  UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
  NSArray *items = [NSArray arrayWithObjects:spacer, done, nil];
  [toolbar setItems:items animated:YES];
  
  return toolbar;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
  LOG(@"tag %lu",textField.tag)
  
  _tagNum = 0;
  _pickerFlag = NO;
  switch (textField.tag) {
    case TF_SITUATION:
      LOG()
      _tagNum = TF_SITUATION;
      break;
    case TF_LEVEL:
      LOG()
      _tagNum = TF_LEVEL;
      break;
    case TF_PERSON:
      LOG()
      _tagNum = TF_PERSON;
      break;
    case TF_FEE:
      LOG()
      _tagNum = TF_FEE;
      break;
    default:
      break;
  }
  // ピッカー表示開始
  _backView.hidden = NO;
  return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
  _pickerFlag = YES;
  return YES;
}

- (void)done:(id)sender
{
  _backView.hidden = YES;
  [self.level resignFirstResponder];
  [self.dou resignFirstResponder];
  [self.situation resignFirstResponder];
  [self.persons resignFirstResponder];
  [self.fee resignFirstResponder];
}

//編集・登録
- (IBAction)pushEdited:(id)sender
{
  if (_n == 1) {
    LOG()
    self.dou.enabled = YES;
    [self.dou becomeFirstResponder];
    self.situation.enabled = YES;
    self.level.enabled = YES;
    self.persons.enabled = YES;
    self.fee.enabled = YES;
    self.comment.editable = YES;
    [self.editBtn setTitle:@"登録する" forState:UIControlStateNormal];
    _n = 2;
    
  } else if (_n == 2) {
    LOG()
    [self validationData];
  }
}

//日記削除
- (IBAction)pushDelete:(id)sender {
  if (_tapFlg) {
    return;
  }
  _tapFlg = YES;
  
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"確認" message:@"日記を削除しますか？" preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
    LOG(@"OK tap")
    [_dataManager deleteDiary:_oid];
    [self.navigationController popToRootViewControllerAnimated:YES];
  }];
  UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style: UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    _tapFlg = NO;
  }];
  [alert addAction:ok];
  [alert addAction:cancel];
  [self presentViewController:alert animated:YES completion:nil];
}

//バリデーション
- (void)validationData
{
  if (_tapFlg) {
    return;
  }
  _tapFlg = YES;
  
  if ([self.dou.text length] == 0 || [self.situation.text length] == 0 || [self.level.text length] == 0 || [self.persons.text length] == 0 || [self.fee.text length] == 0) {
    [self warning:@"未入力項目があります"];
    _tapFlg = NO;
  } else if ([_comment.text length] >= 256){
    [self warning:@"コメントは256文字までで入力してください"];
    _tapFlg = NO;
  } else {
    [_dateFomatter setDateFormat:@"yyyy/MM/dd"];
    [_dateFomatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"JST"]];
    NSDate *date = [_dateFomatter dateFromString:self.dou.text];
  
    NSString *dateStr = [_dateFomatter stringFromDate:[NSDate date]];
    [_dateFomatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"JST"]];
    NSDate *now = [_dateFomatter dateFromString:dateStr];
    NSComparisonResult result  = [date compare:now];
    
    switch (result) {
      case NSOrderedDescending:
        [self warning:@"日時の入力に誤りがあります"];
        _tapFlg = NO;
        break;
      default:
        [self registerVisitData:date];
        break;
    }
  }
}

//登録
- (void)registerVisitData:(NSDate *)date
{
  NSMutableDictionary *dic = [NSMutableDictionary dictionary];
  
  if (self.masterFlg) {
    LOG(@"new sid:%@", [self.shopDic valueForKey:@"sid"])
    [dic setValue:[self.shopDic valueForKey:@"sid"] forKey:@"sid"];
    [dic setValue:[self.shopDic valueForKey:@"shop"] forKey:@"shop"];
    [dic setValue:[self.shopDic valueForKey:@"genre"] forKey:@"genre"];
    [dic setValue:[self.shopDic valueForKey:@"area"] forKey:@"area"];
    [dic setValue:[NSNumber numberWithBool:self.masterFlg] forKey:@"masterAdd"];
  } else {
    if (_newFlag) {
      [dic setValue:[NSNumber numberWithBool:_newFlag] forKey:@"new"];
    } else {
      [dic setValue:_oid forKey:@"oid"];
    }
    [dic setValue:_sid forKey:@"sid"];
  }
  [dic setValue:date forKey:@"visited_at"];
  [dic setValue:[NSNumber numberWithInteger:_personNum] forKey:@"persons"];
  [dic setValue:_comment.text forKey:@"memo"];
  [dic setValue:[NSNumber numberWithInteger:_situNum] forKey:@"situation"];
  [dic setValue:[NSNumber numberWithInteger:_feeNum] forKey:@"fee"];
  [dic setValue:[NSNumber numberWithInteger:_levelNum] forKey:@"level"];
  
  if ([_dataManager editorRegist:dic]) {
    LOG()
    [self.navigationController popToRootViewControllerAnimated:YES];
  } else {
    [self warning:@"登録できませんでした"];
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

//店舗詳細
- (IBAction)pushShopData:(id)sender {
  
  _appDelegate.n = 3;
  
  UINavigationController *vc = self.tabBarController.viewControllers[0];
  self.tabBarController.selectedViewController = vc;
  [vc popToRootViewControllerAnimated:NO];
  [vc.viewControllers[0] performSegueWithIdentifier:@"Data" sender:self];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
  return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
  NSUInteger n;
  switch (_tagNum) {
    case TF_SITUATION:
      n = [_situList count];
      break;
    case TF_LEVEL:
      n = [_levelList count];
      break;
    case TF_PERSON:
      n = [_personList count];
      break;
    case TF_FEE:
      n = [_feeList count];
      break;
    default:
      break;
  }
  return n;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
  NSArray *list;
  switch (_tagNum) {
    case TF_SITUATION:
      list = _situList;
      break;
    case TF_LEVEL:
      list = _levelList;
      break;
    case TF_PERSON:
      list = _personList;
      break;
    case TF_FEE:
      list = _feeList;
      break;
    default:
      break;
  }
  return [list objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
  LOG(@"row: %lu", row)
  switch (_tagNum) {
    case TF_SITUATION:
      self.situation.text = [NSString stringWithFormat:@"%@", _situList[row]];
      _situNum = row;
      break;
    case TF_LEVEL:
      self.level.text = [NSString stringWithFormat:@"%@", _levelList[row]];
      _levelNum = row;
      break;
    case TF_PERSON:
      self.persons.text = [NSString stringWithFormat:@"%@", _personList[row]];
      _personNum = row;
      break;
    case TF_FEE:
      self.fee.text = [NSString stringWithFormat:@"%@", _feeList[row]];
      _feeNum = row;
      break;
    default:
      break;
  }
}

//カレンダー更新
- (void)datePickerEventValueChanged
{
  self.dou.text = [_dateFomatter stringFromDate:_picker.date];
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
    } else if ([obj isKindOfClass:[UIView class]]) {
      LOG()
      _backView.hidden = YES;
      _pickerFlag = YES;
      [self.dou resignFirstResponder];
      [self.situation resignFirstResponder];
      [self.level resignFirstResponder];
      [self.persons resignFirstResponder];
      [self.fee resignFirstResponder];
      [self.comment resignFirstResponder];
    } else {
    }
  }];
}

#pragma mark keyboard up

//キーボード
- (void)keyboardWillShow:(NSNotification *)notification
{
  if (_pickerFlag) {
    LOG()
    NSDictionary *userInfo;
    userInfo = [notification userInfo];
    
    CGFloat overlap;
    CGRect keyboardFrame;
    CGRect textViewFrame;
    keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardFrame = [self.scrollView.superview convertRect:keyboardFrame fromView:nil];
    textViewFrame = self.scrollView.frame;
    overlap = MAX(0.0f, CGRectGetMaxY(textViewFrame) - CGRectGetMinY(keyboardFrame));
    
//    LOG(@"keboardFrame:%@", NSStringFromCGRect(keyboardFrame))
//    LOG(@"keboardFrame:%@", NSStringFromCGRect(textViewFrame))
//    LOG(@"keboardFrame:%f", overlap)
    
    UIEdgeInsets insets;
    insets = UIEdgeInsetsMake(0.0f, 0.0f, overlap, 0.0f);
    
    NSTimeInterval duration;
    UIViewAnimationCurve animationCurve;
    void(^animations)(void);
    //キーボード表示時のアニメーション時間取得
    duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    //キーボード表示時のアニメーションCurve
    animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    LOG(@"animationCurve:%ld", animationCurve)
    animations = ^(void) {
      self.scrollView.contentInset = insets;
      self.scrollView.scrollIndicatorInsets = insets;
    };
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:(animationCurve << 16)
                     animations:animations
                     completion:nil];
    CGRect rect;
    rect.origin.x = 0.0f;
    rect.origin.y = self.scrollView.contentSize.height - 1.0f;
    rect.size.width = CGRectGetWidth(self.scrollView.frame);
    rect.size.height = 1.0f;
    [self.scrollView scrollRectToVisible:rect animated:YES];
    
  }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
  if (_pickerFlag) {
    LOG()
    NSDictionary *userInfo;
    userInfo = [notification userInfo];
    
    NSTimeInterval duration;
    UIViewAnimationCurve animationCurve;
    void(^animations)(void);
    duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    animations = ^(void){
      self.scrollView.contentInset = UIEdgeInsetsZero;
      self.scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
    };
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:(animationCurve << 16)
                     animations:animations
                     completion:nil];
      
  }
}

@end
