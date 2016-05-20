//
//  MainTableViewController.m
//  MothersDayPlanner
//
//  Created by Vladyslav Gusakov on 5/5/16.
//  Copyright © 2016 V-RGB. All rights reserved.
//

#import "MainTableViewController.h"
#import "CustomCell.h"
#import "DataAccessObject.h"
#import "Service.h"
#import "WebViewController.h"

#define MIDDLE_VIEW_X CGRectGetMidX(self.view.bounds)
#define MIDDLE_VIEW_Y CGRectGetMidY(self.view.bounds)

@interface MainTableViewController ()

@property (nonatomic, strong) DataAccessObject *dao;
@property (nonatomic, strong) CALayer          *layer;

@end

@implementation MainTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dao = [DataAccessObject sharedInstance];
    [self greetNewUser];
    [self trackFirstLaunch];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.dao fetchAllDataFromUserDefaults];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    [self animateLayer];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.layer removeFromSuperlayer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - First Launch Greeting

- (BOOL)isFirstLaunchEver {
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"HasLaunchedOnce"] == NO) {
        return true;
    } else {
        return false;
    }
}

- (void)greetNewUser {
    if ([self isFirstLaunchEver]){
        [self presentView];
    }
}

- (void)trackFirstLaunch {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)presentView {
    UIView *greet = [[[NSBundle mainBundle] loadNibNamed:@"GreetingView" owner:self options:kNilOptions] objectAtIndex:0];
    greet.center = self.view.center;
    [self.view addSubview:greet];
}

#pragma mark - CA Prompt
#warning we can get rid of this and/or adjust this
- (void)animateLayer {
    if (self.dao.serviceList.count == 0) {
        [self createLayer];
        CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        pulseAnimation.toValue           = [NSValue valueWithCATransform3D:CATransform3DIdentity];
        pulseAnimation.autoreverses      = YES;
        pulseAnimation.duration          = 1.0;
        pulseAnimation.repeatCount       = HUGE_VALF;
        pulseAnimation.timingFunction    = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [self.layer addAnimation:pulseAnimation forKey:@"pulse"];
    } else {
        [self.layer removeFromSuperlayer];
    }
}

- (void)createLayer {
    self.layer = [CALayer layer];
    self.layer.contents = (id)[UIImage imageNamed:@"up2_filled.png"].CGImage;
    self.layer.bounds = CGRectMake(0, 0, 100, 100);
    self.layer.position = CGPointMake(MIDDLE_VIEW_X + 130, MIDDLE_VIEW_Y - 200);
    [self.layer setMasksToBounds:YES];
    self.layer.transform = CATransform3DMakeScale(1.90, 1.90, 1.00);
    self.layer.zPosition = 9;
    [self.view.layer addSublayer:self.layer];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dao.serviceList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    Service *service      = [self.dao.serviceList objectAtIndex:indexPath.row];
    cell.name.text        = service.placeName;
    cell.background.image = [UIImage imageNamed:service.serviceImage];
    cell.desc.text        = service.formattedAddress;
    cell.fromTime.text    = service.fromTime;
    cell.toTime.text      = service.toTime;
    cell.background.clipsToBounds = YES;
    
    NSLog(@"%@",service.formattedPhoneNumber);
    NSLog(@"%@",service.internationalPhoneNumber);
    
    return cell;
}

#pragma mark - Table View Delegate
-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 170;
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Call" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        Service *service = [self.dao.serviceList objectAtIndex:indexPath.row];
        [self makePhoneCallWithNumber:service.internationalPhoneNumber];
    }];
    editAction.backgroundColor = [UIColor greenColor];
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [self.dao.serviceList removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.dao save];
        [self.tableView reloadData];
    }];
    deleteAction.backgroundColor = [UIColor redColor];
    return @[deleteAction,editAction];
}

- (void)makePhoneCallWithNumber: (NSString*)phoneNumber {
    NSString *formatedNumber         = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *finalPhoneNumberFormat = [formatedNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSURL *phoneUrl = [NSURL URLWithString:[@"telprompt://" stringByAppendingString:finalPhoneNumberFormat]];
    
    if ([[UIApplication sharedApplication]canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl];
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sorry!" message:@"This service did not provide a phone number" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            //alertController dismisses itself
        }];
        [alertController addAction:cancel];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Service *service = [self.dao.serviceList objectAtIndex:indexPath.row];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Choose" message:@"Select an option below" preferredStyle:UIAlertControllerStyleActionSheet];
    alertController.view.backgroundColor = [UIColor whiteColor];
    alertController.view.tintColor = [UIColor purpleColor];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        //alertController dismisses itself
    }];
    
    UIAlertAction *webAction = [UIAlertAction actionWithTitle:@"Website" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self performSegueWithIdentifier:@"showWeb" sender:service.website];
    }];
    
    UIAlertAction *directionsAction = [UIAlertAction actionWithTitle:@"Get Directions" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self getDirectionsForService:service];
    }];
    
    //TODO: add show note action
    
    [alertController addAction:directionsAction];
    [alertController addAction:webAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)getDirectionsForService: (Service *)service {
    NSString *currentLocation = @"Current%20Location";
    if ([[UIApplication sharedApplication] canOpenURL:
         [NSURL URLWithString:@"comgooglemaps://"]]) {
        [[UIApplication sharedApplication] openURL:
         [NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?saddr=%@&daddr=%@&directionsmode=driving",currentLocation,[service.formattedAddress stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]]]];
    } else {
        [self presentAlertToUser];
    }
}

- (void)presentAlertToUser {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sorry!" message:@"Please, try again." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        //do nothing... alert dismisses itself
    }];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

 #pragma mark - Navigation

 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     if ([segue.identifier isEqualToString:@"showWeb"]) {
         WebViewController *webView = (WebViewController *)segue.destinationViewController;
         webView.myURL = sender;
     }
 }
 

@end
