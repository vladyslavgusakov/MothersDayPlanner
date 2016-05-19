//
//  GreetingView.m
//  MothersDayPlanner
//
//  Created by Robert Baghai on 5/19/16.
//  Copyright © 2016 V-RGB. All rights reserved.
//

#import "GreetingView.h"

@implementation GreetingView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    self.layer.zPosition = 5;
}

- (IBAction)closeView:(id)sender {
    [self removeFromSuperview];
}

@end
