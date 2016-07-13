//
//  CustomCell.m
//  MothersDayPlanner
//
//  Created by Vladyslav Gusakov on 5/5/16.
//  Copyright © 2016 V-RGB. All rights reserved.
//

#import "CustomCell.h"

@implementation CustomCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
//    NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"themeColor"];
//    UIColor *color = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
//    self.leftView.backgroundColor = color;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
