//
//  TYEditorViewController.h
//  GourmetDiary
//
//  Created by Tomohiko on 2014/11/26.
//  Copyright (c) 2014年 yamatomo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYBaseViewController.h"

@class ShopMst;

//@interface TYEditorViewController : UIViewController<UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
@interface TYEditorViewController : TYBaseViewController

@property (nonatomic) ShopMst *master;
@property BOOL masterFlg;
@property (nonatomic) NSString *para;
@property (nonatomic) NSMutableDictionary *shopDic;
@property (weak, nonatomic) IBOutlet UITextField *dou;
@property (weak, nonatomic) IBOutlet UITextField *situation;
@property (weak, nonatomic) IBOutlet UITextField *level;
@property (weak, nonatomic) IBOutlet UITextField *fee;
@property (weak, nonatomic) IBOutlet UITextField *persons;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;
@property (weak, nonatomic) IBOutlet UINavigationItem *naviTitle;
@property (weak, nonatomic) IBOutlet UITextView *comment;
@property (weak, nonatomic) IBOutlet UIView *onView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@end
