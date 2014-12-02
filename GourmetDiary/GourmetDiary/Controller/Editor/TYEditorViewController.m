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
  int _n;
  
  UIDatePicker *_picker;
  UIPickerView *_picker2;
  UIPickerView *_picker3;
  UIPickerView *_picker4;
  UIPickerView *_picker5;
  NSUInteger _levelNum; //??
  NSUInteger _situNum; //??
  NSUInteger _personNum; //??
  NSUInteger _feeNum; //??
  NSMutableArray *_levelList;
  NSMutableArray *_situList;
  NSMutableArray *_personList;
  NSMutableArray *_feeList;
  NSUInteger _tagNum;
  UIToolbar *_toolbar;
  UIToolbar *_toolbar2;
  UIToolbar *_toolbar3;
  UIToolbar *_toolbar4;
  UIToolbar *_toolbar5;
  UIView *_backView;
}


- (id)initWithCoder:(NSCoder *)coder
{
  self = [super initWithCoder:coder];
  if (self) {
    _dateFomatter = [[NSDateFormatter alloc] init];
     [_dateFomatter setDateFormat:@"yy/MM/dd"];
    _dataManager = [TYGourmetDiaryManager sharedmanager];
    //picker用
    _levelList = [[NSMutableArray alloc] initWithObjects:@"", @"うーん1点", @"もうちょい2点", @"まあまあ3点", @"まずまず4点", @"うまい！5点", nil];
    _situList = [[NSMutableArray alloc] initWithObjects:@"", @"朝ごはん", @"昼ごはん", @"夜ごはん", @"お茶のじかん", @"お酒のじかん", @"持ちかえり", @"OTHER", nil];
    _personList = [[NSMutableArray alloc] initWithObjects:@"", @"1人", @"2人", @"3人", @"4人", @"5人〜9人", @"10人以上", nil];
    _feeList = [[NSMutableArray alloc] initWithObjects:@"", @"500円しない", @"500〜1,000円くらい", @"1,000〜2,000円くらい", @"2,000〜3,000円くらい", @"3,000〜4,000円くらい", @"4,000〜5,000円くらい", @"5,000〜10,000円だったかな", @"10,000円以上だった…", nil];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
 
  _dic = nil;
  
  self.editBtn.layer.borderColor = [[UIColor whiteColor] CGColor];
  self.editBtn.layer.borderWidth = 1;
  self.editBtn.layer.cornerRadius = 5;
  self.deleteBtn.layer.borderColor = [[UIColor whiteColor] CGColor];
  self.deleteBtn.layer.borderWidth = 1;
  self.deleteBtn.layer.cornerRadius = 5;
  
  _appDelegate = (TYAppDelegate *)[[UIApplication sharedApplication] delegate];
  NSString *sid = _appDelegate.sid;
  _n = _appDelegate.n;
  _dateFomatter = [[NSDateFormatter alloc] init];
   [_dateFomatter setDateFormat:@"yyyy/MM/dd"];
  
  if (_n == 1) {
    LOG()
    _dic = [[_dataManager fetchDiaryData:sid] objectAtIndex:0];
    
    self.naviTitle.title = [_dic valueForKey:@"shop"];
    self.dou.text = [_dateFomatter stringFromDate:[_dic valueForKey:@"visited_at"]];
    self.dou.enabled = NO;
    self.situation.text = [TYUtil setSituationPickerText:[_dic valueForKey:@"situation"]];
    self.situation.enabled = NO;
    self.level.text = [TYUtil setLevelPickerText:[_dic valueForKey:@"level"]];
    self.level.enabled = NO;
    NSString *persons = [[_dic valueForKey:@"persons"] stringValue];
    self.persons.text = [NSString stringWithFormat:@"%@人", persons];
    self.persons.enabled = NO;
    self.fee.text = [TYUtil setFeePickerText:[_dic valueForKey:@"fee"]];
    self.fee.enabled = NO;
    self.comment.text = [_dic valueForKey:@"memo"];
    self.comment.editable = NO;
    
  } else if (_n == 2) {
    if (self.shopDic) {
      LOG()
      self.naviTitle.title = [self.shopDic valueForKey:@"shop"];
      [self.editBtn setTitle:@"登録する" forState:UIControlStateNormal];
      self.deleteBtn.enabled = NO;
      self.deleteBtn.alpha = 0.3;
    } else {
      [self warning:@"登録エラーがあります"];
    }
  }
  
  self.dou.tag = TF_CALENDAR;
  self.dou.text = [_dateFomatter stringFromDate:[NSDate date]];
  self.dou.delegate = self;
  self.situation.tag = TF_SITUATION;
  self.situation.delegate = self;
  self.level.tag = TF_LEVEL;
  self.level.delegate = self;
  self.persons.tag = TF_PERSON;
  self.persons.delegate = self;
  self.fee.tag = TF_FEE;
  self.fee.delegate = self;
//  self.comment.editable = YES;
  
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
//  _backView.alpha = 0;
  _backView.hidden = YES;
  _backView.userInteractionEnabled = NO;
  [self.view addSubview:_backView];
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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
  _tagNum = 0;
  LOG(@"tag %lu",textField.tag)
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

- (void)done:(id)sender
{
  _backView.hidden = YES;
  [self.level resignFirstResponder];
  [self.dou resignFirstResponder];
  [self.situation resignFirstResponder];
  [self.persons resignFirstResponder];
  [self.fee resignFirstResponder];
}

//
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
    _n = 2;
    
  } else if (_n == 2) {
    LOG()
    [self validationData];
  }
}

//日記削除
- (IBAction)pushDelete:(id)sender {
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"確認" message:@"日記を削除しますか？" preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
    LOG(@"OK tap")
    [_dataManager deleteDiary];
    [self.navigationController popToRootViewControllerAnimated:YES];
  }];
  UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style: UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    LOG()
  }];
  [alert addAction:ok];
  [alert addAction:cancel];
  [self presentViewController:alert animated:YES completion:nil];
}

//バリデーション
- (void)validationData
{
  LOG()
  if ([self.dou.text length] == 0 || [self.situation.text length] == 0 || [self.level.text length] == 0 || [self.persons.text length] == 0 || [self.fee.text length] == 0) {
    [self warning:@"未入力項目があります"];
  } else if ([_comment.text length] >= 256){
    [self warning:@"コメントは256文字までで入力してください"];
  } else {
    [_dateFomatter setDateFormat:@"yyyy/MM/dd"];
    [_dateFomatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *date = [_dateFomatter dateFromString:self.dou.text];
  
    NSString *dateStr = [_dateFomatter stringFromDate:[NSDate date]];
    [_dateFomatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *now = [_dateFomatter dateFromString:dateStr];
    NSComparisonResult result  = [date compare:now];
    
    switch (result) {
      case NSOrderedDescending:
        [self warning:@"日時の入力に誤りがあります"];
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
  LOG()
  NSMutableDictionary *dic = [NSMutableDictionary dictionary];
  [dic setValue:[self.shopDic valueForKey:@"sid"] forKey:@"sid"];
  [dic setValue:date forKey:@"visited_at"];
  [dic setValue:[NSNumber numberWithInteger:_personNum] forKey:@"persons"];
  [dic setValue:_comment.text forKey:@"memo"];
  [dic setValue:[NSNumber numberWithInteger:_situNum] forKey:@"situation"];
  [dic setValue:[NSNumber numberWithInteger:_feeNum] forKey:@"fee"];
  [self.shopDic setValue:[NSNumber numberWithInteger:_levelNum] forKey:@"level"];
  
  LOG(@"level: %@", [NSNumber numberWithInteger:_levelNum])
  
//  [_dataManager addVisitRegist:dic shop:self.shopMst];
  if ([_dataManager addEditorRegist:dic shop:self.shopDic]) {
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

  _appDelegate.n = 2;
  
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
//  LOG(@"row: %lu", row)
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
    } else {
    }
  }];
}


@end
