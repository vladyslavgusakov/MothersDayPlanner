//
//  SettingsViewController.m
//  MothersDayPlanner
//
//  Created by Robert Baghai on 7/13/16.
//  Copyright © 2016 V-RGB. All rights reserved.
//

#import "SettingsViewController.h"
//#import "DataAccessObject.h"

@interface SettingsViewController ()

//@property (nonatomic, strong) DataAccessObject *dao;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.dao = [DataAccessObject sharedInstance];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pop) name:@"pop" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)pop {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)goToApplicationPermissionSettings:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

@end
