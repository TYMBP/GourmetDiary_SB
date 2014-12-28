//
//  TYVisitedTableViewCell.h
//  GourmetDiary
//
//  Created by Tomohiko on 2014/11/22.
//  Copyright (c) 2014年 yamatomo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TYVisitedTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *genre;
@property (weak, nonatomic) IBOutlet UILabel *area;
@property (weak, nonatomic) IBOutlet UILabel *level;
@property (weak, nonatomic) IBOutlet UILabel *dateList;
@property (weak, nonatomic) IBOutlet UILabel *levelList;
@property (weak, nonatomic) IBOutlet UILabel *nameList;
@property (weak, nonatomic) IBOutlet UILabel *genreList;
@property (weak, nonatomic) IBOutlet UILabel *areaList;
@property (weak, nonatomic) IBOutlet UILabel *comment;

@end
