//
//  detailsViewController.m
//  MothersDayPlanner
//
//  Created by Vladyslav Gusakov on 5/5/16.
//  Copyright © 2016 V-RGB. All rights reserved.
//

#import "DetailsViewController.h"
#import "DataAccessObject.h"
@import GoogleMaps;

@interface DetailsViewController ()

#pragma mark - IBActions
- (IBAction)save:(id)sender;
- (IBAction)fromChoose:(id)sender;
- (IBAction)toChoose:(id)sender;
- (IBAction)doneButtonAction:(id)sender;

#pragma mark - IBOutlets
@property (weak, nonatomic) IBOutlet UILabel      *fromTime;
@property (weak, nonatomic) IBOutlet UILabel      *toTime;
@property (weak, nonatomic) IBOutlet UITextField  *noteTextField;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIView       *dateView;
@property (weak, nonatomic) IBOutlet UIButton     *choose1;
@property (weak, nonatomic) IBOutlet UIButton     *choose2;

#pragma mark - Miscellaneous
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, getter=isFrom) BOOL from;
@property (nonatomic, strong) DataAccessObject *dao;


@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dao = [DataAccessObject sharedInstance];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"hh:mm a"]; // from here u can change format..
    self.dateView.hidden = YES;
    
    NSLog(@"new object to be saved - > %@, %@, %@, %@, %@", self.service.formattedAddress, self.service.formattedPhoneNumber, self.service.placeName, self.service.internationalPhoneNumber, self.service.serviceImage);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)save:(id)sender {
    self.service.fromTime = self.fromTime.text;
    self.service.toTime   = self.toTime.text;
    self.service.note     = self.noteTextField.text;
    
    NSLog(@"object - > %@, %@, %@, %@, %@, %@, %@, %@, %@", self.service.formattedAddress, self.service.formattedPhoneNumber, self.service.placeName, self.service.internationalPhoneNumber, self.service.serviceImage, self.service.fromTime, self.service.toTime, self.service.note, self.service.website);
    
    [self.dao.serviceList addObject:self.service];
    [self.dao save];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)fromChoose:(id)sender {
    self.from            = YES;
    self.dateView.hidden = NO;
}

- (IBAction)toChoose:(id)sender {
    self.from            = NO;
    self.dateView.hidden = NO;
}


- (IBAction)doneButtonAction:(id)sender {
    if (self.isFrom == YES) {
        self.fromTime.text = [self.dateFormatter stringFromDate:self.datePicker.date];
    } else {
        self.toTime.text = [self.dateFormatter stringFromDate:self.datePicker.date];
    }
    
    self.dateView.hidden = YES;
}

@end
