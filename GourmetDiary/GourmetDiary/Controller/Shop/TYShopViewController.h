//
//  TYShopViewController.h
//  GourmetDiary
//
//  Created by Tomohiko on 2014/11/29.
//  Copyright (c) 2014年 yamatomo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYBaseViewController.h"

@interface TYShopViewController : TYBaseViewController

@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *genre;
@property (weak, nonatomic) IBOutlet UITextField *area;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

@end
