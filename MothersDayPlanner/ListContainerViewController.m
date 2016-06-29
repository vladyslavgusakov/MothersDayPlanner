//
//  ListContainerViewController.m
//  MothersDayPlanner
//
//  Created by Robert Baghai on 5/19/16.
//  Copyright © 2016 V-RGB. All rights reserved.
//

#import "ListContainerViewController.h"
#import "CustomMarker.h"
#import "Constants.h"
#import "DetailsViewController.h"
#import "DataAccessObject.h"

@interface ListContainerViewController ()

@property (nonatomic, strong) NSString         *placeToSearch;
@property (nonatomic, strong) DataAccessObject *dao;

@end

@implementation ListContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dao = [DataAccessObject sharedInstance];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table View Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfPlaces.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    CustomMarker *marker = [self.arrayOfPlaces objectAtIndex:indexPath.row];
    cell.textLabel.text  = marker.title;
    cell.imageView.image = [UIImage imageNamed:self.pinImage];
    
    return cell;
}

#pragma mark - Table View Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomMarker *marker = [self.arrayOfPlaces objectAtIndex:indexPath.row];
    self.placeToSearch   = marker.placeId;
    //NSLog(@"PLACE ID == %@",self.placeToSearch);
    [self fetchInfoBasedOnSelectedPlace];
}

#pragma mark - API Requests
- (void)fetchInfoBasedOnSelectedPlace {
    if ([self.dao validInternetConnectionExists]) {
        NSURLSession *session = [NSURLSession sharedSession];
        NSString     *url     = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?placeid=%@&key=%@",self.placeToSearch, serverKey];
        [[session dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData * _Nullable data,
                                                                                NSURLResponse * _Nullable response,
                                                                                NSError * _Nullable error) {
            if (error) {
                //NSLog(@"Error : %@, %@",error.localizedDescription, error.userInfo);
                [self presentAlertToUser];
            } else {
                dispatch_async(dispatch_get_main_queue(),^{
                    self.dictionaryOfPlaceSearchResults = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    [self parseAndPush];
                    [self performSegueWithIdentifier:@"showDetail" sender:nil];
                });
            }
        }] resume];
    } else {
        [self presentAlertForBadInternet];
    }
}

-(void)parseAndPush {
    NSDictionary *dict = [self.dictionaryOfPlaceSearchResults objectForKey:@"result"];
    self.serviceInfo = [Service new];
    self.serviceInfo.formattedAddress         = [dict valueForKey:@"formatted_address"];
    self.serviceInfo.placeName                = [dict valueForKey:@"name"];
    self.serviceInfo.internationalPhoneNumber = [dict valueForKey:@"international_phone_number"];
    self.serviceInfo.serviceImage             = self.serviceImage;
    self.serviceInfo.website                  = [dict valueForKey:@"website"];
    self.serviceInfo.latitude                 = self.coordinate.latitude;
    self.serviceInfo.longitude                = self.coordinate.longitude;
}

- (void)presentAlertToUser {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sorry!" message:@"Please, try again." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        //do nothing... alert dismisses itself
    }];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)presentAlertForBadInternet {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Internet Required" message:@"Please check your internet connection and try again." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        //alert controller dismisses itself
    }];
    [alertController addAction:dismissAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showDetail"]) {
        DetailsViewController *detailView = (DetailsViewController *)segue.destinationViewController;
        detailView.service = self.serviceInfo;
    }
}

@end
