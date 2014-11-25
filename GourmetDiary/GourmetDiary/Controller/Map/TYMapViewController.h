//
//  TYMapViewController.h
//  GourmetDiary
//
//  Created by Tomohiko on 2014/11/21.
//  Copyright (c) 2014年 yamatomo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class ShopMst;

@interface TYMapViewController : UIViewController<MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, copy) NSString *title;
@property (nonatomic) ShopMst *shopMst;

@end
