//
//  ListContainerViewController.m
//  MothersDayPlanner
//
//  Created by Robert Baghai on 5/18/16.
//  Copyright © 2016 V-RGB. All rights reserved.
//

#import "ListContainerViewController.h"

@interface ListContainerViewController ()

@end

@implementation ListContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%lu, %@", self.arrayOfPlaces.count, self.arrayOfPlaces);
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self viewDidLoad];
    }
    return self;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
