//
//  ThemeView.m
//  MothersDayPlanner
//
//  Created by Robert Baghai on 7/13/16.
//  Copyright © 2016 V-RGB. All rights reserved.
//

#import "ThemeView.h"
#import "DataAccessObject.h"

@interface ThemeView ()

@property (nonatomic, strong) DataAccessObject *dao;

@end

@implementation ThemeView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    self.dao = [DataAccessObject sharedInstance];
    
    NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"themeColor"];
    UIColor *themeColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];

    if ([self.backgroundColor isEqual:themeColor]) {
        self.layer.borderWidth = 7;
        self.layer.borderColor = [UIColor blackColor].CGColor;
    }
    
    self.layer.cornerRadius = self.bounds.size.width / 2;
    self.layer.masksToBounds = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(saveThemeColor)];
    tapGesture.numberOfTapsRequired = 1;
    [self addGestureRecognizer:tapGesture];
}

- (void)saveThemeColor {
    NSLog(@"Tapped me with color, %@",self.backgroundColor);
    //save theme color to NSUserDefaults
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:self.backgroundColor];
    [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:@"themeColor"];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"pop" object:nil];
}


@end
