//
//  TYMapViewController.m
//  GourmetDiary
//
//  Created by Tomohiko on 2014/11/21.
//  Copyright (c) 2014年 yamatomo. All rights reserved.
//

#import "TYMapViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "TYApplication.h"
#import "ShopMst.h"

@interface TYMapViewController ()

@end

@implementation TYMapViewController {
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.mapView.delegate = self;
  
  NSArray *ary = [[TYApplication application] getLocation];
  NSNumber *latObj = [ary objectAtIndex:1];
  NSNumber *lngObj = [ary objectAtIndex:0];
  double lat = fabs(latObj.doubleValue);
  double lng = fabs(lngObj.doubleValue);
  
  CLLocationCoordinate2D center = CLLocationCoordinate2DMake(lat, lng);
  MKCoordinateRegion now = MKCoordinateRegionMakeWithDistance(center, 3000.0, 3000.0);
  self.mapView.region = now;
  self.mapView.showsUserLocation = YES;
  
  
  NSNumber *latNowObj = self.shopMst.lat;
  NSNumber *lngNowObj = self.shopMst.lng;
  double latNow = fabs(latNowObj.doubleValue);
  double lngNow = fabs(lngNowObj.doubleValue);
  MKPointAnnotation *pin = [[MKPointAnnotation alloc] init];
  pin.title = self.shopMst.shop;
  pin.coordinate = CLLocationCoordinate2DMake(latNow, lngNow);
  [self.mapView addAnnotation:pin];
  [self openAnnotation:pin];
  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
  LOG(@"annotation:%@", annotation)
  if ([annotation isKindOfClass:[MKUserLocation class]]) {
    LOG(@"userLocation")
    return false;
  } else {
    static NSString *Identifier = @"PinAnnotationIdentifier";
    MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:Identifier];
    if (pinView == nil) {
      pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:Identifier];
      pinView.animatesDrop = YES;
      pinView.canShowCallout = YES;
      return pinView;
    }
    pinView.annotation = annotation;
    return pinView;
  }
}

- (void)openAnnotation:(id)annotation{
  [self.mapView selectAnnotation:annotation animated:YES];
}

//- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
//{
//  LOG()
//  
//  [mapView selectAnnotation:[mapView.annotations lastObject] animated:YES];
//}

@end
