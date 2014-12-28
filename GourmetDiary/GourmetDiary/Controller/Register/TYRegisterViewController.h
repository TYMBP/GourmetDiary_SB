//
//  TYRegisterViewController.h
//  GourmetDiary
//
//  Created by Tomohiko on 2014/11/21.
//  Copyright (c) 2014年 yamatomo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYBaseViewController.h"

@class ShopMst;

@interface TYRegisterViewController : TYBaseViewController

@property (weak, nonatomic) IBOutlet UITextField *dou;
@property (weak, nonatomic) IBOutlet UITextField *situation;
@property (weak, nonatomic) IBOutlet UITextField *level;
@property (weak, nonatomic) IBOutlet UITextField *persons;
@property (weak, nonatomic) IBOutlet UITextField *fee;
@property (weak, nonatomic) IBOutlet UITextView *comment;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (weak, nonatomic) IBOutlet UINavigationItem *naviTitle;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *onView;
@property (nonatomic) ShopMst *shopMst;
@property (nonatomic) UITextField *activeField;

@end
