//
//  TYBaseViewController.h
//  GourmetDiary
//
//  Created by Tomohiko on 2014/12/20.
//  Copyright (c) 2014年 yamatomo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@interface TYBaseViewController : UIViewController <UITextViewDelegate, UIScrollViewDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate>


- (UIPickerView *)makePicker;
- (UIToolbar *)makeToolbar:(CGRect)rect;

@end
