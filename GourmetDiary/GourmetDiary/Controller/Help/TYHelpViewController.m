//
//  TYHelpViewController.m
//  GourmetDiary
//
//  Created by Tomohiko on 2015/01/11.
//  Copyright (c) 2015年 yamatomo. All rights reserved.
//

#import "TYHelpViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation TYHelpViewController {
  float _height;
  float _width;
  float _imgWd;
  float _zoom;
  double _scale;
}

- (void)viewDidLoad
{
  LOG()
  [super viewDidLoad];
  
  self.view.backgroundColor = [UIColor colorWithRed:1.0 green:0.98 blue:0.98 alpha:1.0];
  UIScrollView *scrollView = [[UIScrollView alloc] init];
  scrollView.frame = self.view.bounds;
  _width = self.view.bounds.size.width;
  scrollView.scrollEnabled = YES;
 
  CGRect rect = [UIScreen mainScreen].bounds;
 
  //3.5or4inch and 4inch over
  if (rect.size.width == 320) {
    LOG(@"320")
    _imgWd = 240;
    _height = 1960;
    _zoom = 0.8;
  } else {
    LOG(@"320 over")
    _imgWd = 300;
    _height = 2450;
    _zoom = 1;
  }
  
  scrollView.contentSize = CGSizeMake(_width, _height);
  [self.view addSubview:scrollView];
  
  UIView *uv = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2 - ((self.view.bounds.size.width - 40)/2), 10, self.view.bounds.size.width - 40, _height-30)];
//  uv.backgroundColor = [UIColor colorWithRed:0.94 green:0.97 blue:1.00 alpha:1.0];
  uv.backgroundColor = [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0];
  uv.alpha = 0.7f;
  uv.layer.borderWidth = 6.0f;
  uv.layer.borderColor = [UIColor colorWithRed:0.80 green:0.80 blue:0.80 alpha:0.5].CGColor;
  uv.layer.cornerRadius = 5.0f;
  [scrollView addSubview:uv];
  
  //tutorial
  UILabel *lv1 = [self makeLabel:@"検索した情報を登録する"];
  lv1.frame = CGRectMake(40, 10*_zoom, 200, 50*_zoom);
  UIImageView *iv1 = [self makeImageView:@"tutorial1.jpg" position:60];
  [scrollView addSubview:lv1];
  [scrollView addSubview:iv1];
  
  UILabel *lv2 = [self makeLabel:@"↓"];
  lv2.frame = CGRectMake(50, 258*_zoom, 200, 50*_zoom);
  UIImageView *iv2 = [self makeImageView:@"tutorial2.jpg" position:308];
  [scrollView addSubview:lv2];
  [scrollView addSubview:iv2];
  
  UILabel *lv3 = [self makeLabel:@"↓"];
  lv3.frame = CGRectMake(50, 628*_zoom, 200, 50*_zoom);
  UIImageView *iv3 = [self makeImageView:@"tutorial3.jpg" position:678];
  [scrollView addSubview:lv3];
  [scrollView addSubview:iv3];
  
  UILabel *lv4 = [self makeLabel:@"↓"];
  lv4.frame = CGRectMake(50, 878*_zoom, 200, 50*_zoom);
  UIImageView *iv4 = [self makeImageView:@"tutorial4.jpg" position:928];
  [scrollView addSubview:lv4];
  [scrollView addSubview:iv4];
  
  UILabel *lv5 = [self makeLabel:@"↓"];
  lv5.frame = CGRectMake(50, 1248*_zoom, 200, 50*_zoom);
  UIImageView *iv5 = [self makeImageView:@"tutorial5.jpg" position:1298];
  [scrollView addSubview:lv5];
  [scrollView addSubview:iv5];
  
  UILabel *lv6 = [self makeLabel:@"店舗情報から新規登録"];
  lv6.frame = CGRectMake(40, 1626*_zoom, 200, 50*_zoom);
  UIImageView *iv6 = [self makeImageView:@"tutorial6.jpg" position:1676];
  [scrollView addSubview:lv6];
  [scrollView addSubview:iv6];
  
  UILabel *lv7 = [self makeLabel:@"↓"];
  lv7.frame = CGRectMake(50, 1916*_zoom, 200, 50*_zoom);
  UIImageView *iv7 = [self makeImageView:@"tutorial7.jpg" position:1966];
  [scrollView addSubview:lv7];
  [scrollView addSubview:iv7];
  
  UILabel *lv8 = [self makeLabel:@"※ 続きは検索からの登録と同じ"];
  lv8.frame = CGRectMake(40, 2366*_zoom, 220, 50*_zoom);
  [scrollView addSubview:lv8];
}

- (UILabel *)makeLabel:(NSString *)text
{
  UILabel *label = [[UILabel alloc] init];
  label.font = [UIFont fontWithName:@"HirakakuProN-W6" size:14];
  label.text = text;
  label.textColor = [UIColor whiteColor];
  label.textAlignment = NSTextAlignmentLeft;
  
  return label;
}

- (UIImageView *)makeImageView:(NSString *)name position:(float)position
{
  LOG()
  UIImageView *imageView;
  UIImage *image = [UIImage imageNamed:name];
  float ht = image.size.height;
  _scale = _imgWd/image.size.width;
  
  // リサイズ後の画像を取得します。
  CGSize resizedSize = CGSizeMake(_imgWd, ht*_scale);
  UIGraphicsBeginImageContext(resizedSize);
  [image drawInRect:CGRectMake(0, 0, resizedSize.width, resizedSize.height)];
  UIImage* resizedImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  imageView = [[UIImageView alloc] initWithImage:resizedImage];
  imageView.contentMode = UIViewContentModeCenter;
  imageView.frame = CGRectMake(self.view.bounds.size.width/2-(_imgWd/2), position * _zoom, _imgWd, ht*_scale);
  
  return imageView;
}


@end
