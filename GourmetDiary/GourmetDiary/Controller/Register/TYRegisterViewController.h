//
//  TYRegisterViewController.h
//  GourmetDiary
//
//  Created by Tomohiko on 2014/11/21.
//  Copyright (c) 2014年 yamatomo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ShopMst;

@interface TYRegisterViewController : UIViewController<UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *dou;
@property (weak, nonatomic) IBOutlet UITextField *situation;
@property (weak, nonatomic) IBOutlet UITextField *level;
@property (weak, nonatomic) IBOutlet UITextField *persons;
@property (weak, nonatomic) IBOutlet UITextField *fee;
@property (weak, nonatomic) IBOutlet UITextView *comment;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (nonatomic) ShopMst *shopMst;

@end
