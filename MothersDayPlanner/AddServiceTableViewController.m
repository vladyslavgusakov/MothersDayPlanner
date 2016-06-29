//
//  AddServiceTableViewController.m
//  MothersDayPlanner
//
//  Created by Vladyslav Gusakov on 5/5/16.
//  Copyright © 2016 V-RGB. All rights reserved.
//

#import "AddServiceTableViewController.h"
#import "MapsViewController.h"
#import "CustomMarker.h"
#import "Constants.h"
#import "DataAccessObject.h"
@import GoogleMaps;

#define MIDDLE_VIEW_X CGRectGetMidX(self.view.bounds)
#define MIDDLE_VIEW_Y CGRectGetMidY(self.view.bounds)

@interface AddServiceTableViewController () <CLLocationManagerDelegate>

#pragma mark - Location
@property (nonatomic, strong) CLLocationManager     *locationManager;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

#pragma mark - Miscellaneous
@property (nonatomic, strong) NSDictionary            *serviceImages;
@property (nonatomic, strong) NSArray                 *servicesList;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) NSDictionary            *dictionaryOfSearchResults;
@property (nonatomic, strong) NSMutableArray          *arrayOfSearchMarkers;
@property (nonatomic, strong) DataAccessObject        *dao;

@end

@implementation AddServiceTableViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.dao = [DataAccessObject sharedInstance];
    [self getCurrentLocation];
    self.servicesList  = @[@"spa", @"florist", @"shoe_store", @"beauty_salon", @"jewelry_store", @"liquor_store", @"hair_care", @"clothing_store"];
    self.serviceImages = @{
                           @"spa": @"spa_main.jpg",
                           @"florist": @"flowers.jpg",
                           @"shoe_store" : @"shoe_store_main.png",
                           @"beauty_salon" : @"beauty_main.png",
                           @"jewelry_store": @"jew.jpg",
                           @"liquor_store": @"liq.jpg",
                           @"hair_care": @"hair.jpg",
                           @"clothing_store" : @"clothing_main.jpg"
                           };
    [self createActivityIndicator];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)presentAlertForBadInternet {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Internet Required" message:@"Please check your internet connection and try again." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        //alert controller dismisses itself
    }];
    [alertController addAction:dismissAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Table View Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.servicesList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = [[self.servicesList[indexPath.row] stringByReplacingOccurrencesOfString:@"_" withString:@" "] uppercaseString];
    cell.imageView.image = [UIImage imageNamed:self.servicesList[indexPath.row]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.dao validInternetConnectionExists]) {
        [self.activityIndicator startAnimating];
//        NSLog(@"Lat %f , long = %f",self.coordinate.latitude, self.coordinate.longitude);
        [self fetchPlacesBasedOnServiceType:indexPath];
    } else {
        [self presentAlertForBadInternet];
    }
}

- (void)createActivityIndicator {
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicator.color = [UIColor purpleColor];
    self.activityIndicator.center = self.view.center;
    [self.view addSubview:self.activityIndicator];
}

#pragma mark - API Requests
- (void)fetchPlacesBasedOnServiceType: (NSIndexPath*)indexPath {
    self.tableView.allowsSelection = NO;
    self.tableView.scrollEnabled   = NO;
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL        *url     = [NSURL URLWithString:[NSString stringWithFormat
                                                  :@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%lf,%lf&radius=6000&types=%@&key=%@",
                                                  self.coordinate.latitude,
                                                  self.coordinate.longitude,
                                                  self.servicesList[indexPath.row],
                                                  serverKey
                                                  ]];
    
    [[session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data,
                                                      NSURLResponse * _Nullable response,
                                                      NSError * _Nullable error) {
        if ( error ) {
           // NSLog(@"Error : %@, %@",error.localizedDescription, error.userInfo);
            [self presentAlertToUser];
        } else {
            dispatch_async(dispatch_get_main_queue(),^{
                self.dictionaryOfSearchResults = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                [self parseAndPin];
                [self.activityIndicator stopAnimating];
                [self performSegueWithIdentifier:@"showMapList" sender:nil];
                self.tableView.allowsSelection = YES;
                self.tableView.scrollEnabled   = YES;
            });
        }
    }] resume];
}

- (void)parseAndPin {
    NSDictionary *result      = [self.dictionaryOfSearchResults objectForKey:@"results"];
    NSArray *tempGeo          = [result valueForKey:@"geometry"];
    NSArray *tempLoc          = [tempGeo valueForKey:@"location"];
    NSArray *nameArray        = [result valueForKey:@"name"];
    NSArray *openingHours     = [result valueForKey:@"opening_hours"];
    NSArray *openOrClosed     = [openingHours valueForKey:@"open_now"];
    NSArray *latitudeArray    = [tempLoc valueForKey:@"lat"];
    NSArray *longitudeArray   = [tempLoc valueForKey:@"lng"];
    NSArray *place_idArray    = [result valueForKey:@"place_id"];
    self.arrayOfSearchMarkers = [NSMutableArray new];
    
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//    NSLog(@"%@",result);
    NSLog(@"%@",openOrClosed);
    
    for (int i = 0 ; i < latitudeArray.count; i++) {
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[[latitudeArray objectAtIndex:i] doubleValue]
                                                                longitude:[[longitudeArray objectAtIndex:i] doubleValue] zoom:12];
        CustomMarker *searchMarker = [[CustomMarker alloc] init];
        searchMarker.position      = camera.target;
        searchMarker.title         = [NSString stringWithFormat:@"%@",[nameArray objectAtIndex:i]];
        if ([[openOrClosed objectAtIndex:i]  isEqual: @1]) {
            searchMarker.snippet       = @"Open Now!";
        } else {
            searchMarker.snippet       = @"Closed :(";
        }
        
        searchMarker.image         = [UIImage imageNamed:self.servicesList[indexPath.row]];
        searchMarker.icon          = [GMSMarker markerImageWithColor:[UIColor purpleColor]];
        searchMarker.placeId       = [place_idArray objectAtIndex:i];
        [self.arrayOfSearchMarkers addObject:searchMarker];
    }
    
}

#pragma mark - Lazy Loading
- (CLLocationManager*)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
    }
    return _locationManager;
}

- (NSMutableArray *)arrayOfSearchMarkers {
    if (!_arrayOfSearchMarkers) {
        _arrayOfSearchMarkers = [[NSMutableArray alloc] init];
    }
    return _arrayOfSearchMarkers;
}

#pragma mark - CLLocation Manager Delegate
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *location = [locations lastObject];
    self.coordinate      = location.coordinate;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    //NSLog(@"Error = %@, %@", error.localizedDescription, error.userInfo);
//    [self presentAlertToUser];
}

#pragma mark - Location
- (void)getCurrentLocation {
    [self.locationManager requestWhenInUseAuthorization];
    self.locationManager.delegate        = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
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
    MapsViewController *mapsVC = (MapsViewController*)segue.destinationViewController;
    NSIndexPath *indexPath     = [self.tableView indexPathForSelectedRow];
    mapsVC.serviceImage        = [self.serviceImages valueForKey:self.servicesList[indexPath.row]];
    mapsVC.pinImage            = self.servicesList[indexPath.row];
    mapsVC.mapView.camera      = [GMSCameraPosition cameraWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude zoom:15];
    mapsVC.dictionaryOfSearchResults = self.dictionaryOfSearchResults;
    mapsVC.arrayOfSearchMarkers      = self.arrayOfSearchMarkers;
    mapsVC.coordinate = self.coordinate;
}

@end
