//
//  detailsViewController.m
//  MothersDayPlanner
//
//  Created by Vladyslav Gusakov on 5/5/16.
//  Copyright © 2016 V-RGB. All rights reserved.
//

#import "DetailsViewController.h"

@interface DetailsViewController ()
- (IBAction)save:(id)sender;
- (IBAction)fromChoose:(id)sender;
- (IBAction)toChoose:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *fromTime;
@property (weak, nonatomic) IBOutlet UILabel *toTime;
@property (weak, nonatomic) IBOutlet UITextField *noteTextField;
- (IBAction)doneButtonAction:(id)sender;

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIView *dateView;

@property (weak, nonatomic) IBOutlet UIButton *choose1;
@property (weak, nonatomic) IBOutlet UIButton *choose2;

@end

@implementation DetailsViewController {
    UIDatePicker *datepicker;
    NSDateFormatter *df;
    BOOL isFrom;
    NSUserDefaults *defaults;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
     df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"hh:mm a"]; // from here u can change format..
    self.dateView.hidden = YES;
    
     defaults = [NSUserDefaults standardUserDefaults];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)save:(id)sender {
    
    [defaults setObject:self.fromTime.text forKey:@"from"];
    [defaults setObject:self.toTime.text forKey:@"to"];
    [defaults setObject:self.noteTextField.text forKey:@"note"];

    [defaults synchronize];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)fromChoose:(id)sender {
    isFrom = YES;
    self.dateView.hidden = NO;
}

- (IBAction)toChoose:(id)sender {
    isFrom = NO;
    self.dateView.hidden = NO;
}


- (IBAction)doneButtonAction:(id)sender {
    if (isFrom == YES) {
        self.fromTime.text = [df stringFromDate:self.datePicker.date];
    }
    else {
        self.toTime.text = [df stringFromDate:self.datePicker.date];
    }
    
    self.dateView.hidden = YES;
    
    
    
}
@end
