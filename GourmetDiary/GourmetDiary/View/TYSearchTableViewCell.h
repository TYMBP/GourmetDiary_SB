//
//  TYSearchTableViewCell.h
//  GourmetDiary
//
//  Created by Tomohiko on 2014/11/20.
//  Copyright (c) 2014年 yamatomo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TYSearchTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *genru;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *genruRs;
@property (weak, nonatomic) IBOutlet UILabel *nameRs;
@property (weak, nonatomic) IBOutlet UILabel *area;
@property (weak, nonatomic) IBOutlet UILabel *areaRs;
@property (weak, nonatomic) IBOutlet UILabel *genreMst;
@property (weak, nonatomic) IBOutlet UILabel *areaMst;
@property (weak, nonatomic) IBOutlet UILabel *nameMst;

@end
