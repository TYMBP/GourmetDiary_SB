//
//  TYBaseScrollView.m
//  GourmetDiary
//
//  Created by Tomohiko on 2014/12/23.
//  Copyright (c) 2014年 yamatomo. All rights reserved.
//

#import "TYBaseScrollView.h"

@implementation TYBaseScrollView

- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];
  if (self) {
    LOG()
  }
  return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  LOG()
  if (!self.dragging) {
    [self.nextResponder touchesEnded:touches withEvent:event];
  }
  [super touchesEnded:touches withEvent:event];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  LOG()
  if (!self.dragging) {
    [self.nextResponder touchesBegan:touches withEvent:event];
  }
  [super touchesBegan:touches withEvent:event];
}

@end
