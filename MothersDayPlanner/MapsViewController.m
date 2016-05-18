//
//  MapsViewController.m
//  MothersDayPlanner
//
//  Created by Vladyslav Gusakov on 5/5/16.
//  Copyright © 2016 V-RGB. All rights reserved.
//

#import "MapsViewController.h"
#import "CustomMarker.h"
#import "CustomPinView.h"
#import "Service.h"
#import "Constants.h"
@import GoogleMaps;

@interface MapsViewController () <CLLocationManagerDelegate, GMSMapViewDelegate>

#pragma mark - Location
@property (nonatomic, strong) CLLocationManager     *locationManager;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

#pragma mark - IBOutlets
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;

#pragma mark - IBActions
- (IBAction)switchView:(id)sender;

#pragma mark - Miscellaneous
@property (nonatomic, strong) NSDictionary     *dictionaryOfSearchResults;
@property (nonatomic, strong) NSDictionary     *dicitonaryOfPlaceResults;
@property (nonatomic, strong) NSMutableArray   *arrayOfSearchMarkers;
@property (nonatomic, strong) NSDictionary     *dictionaryOfPlaceSearchResults;
@property (nonatomic, strong) NSString         *placeToSearch;
@property (nonatomic, strong) Service          *serviceInfo;

@end


@implementation MapsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getCurrentLocation];
    self.mapView.myLocationEnabled = YES;
    self.mapView.delegate          = self;
//    self.selectedService = @"spa";
}

#pragma mark - Location
- (void)getCurrentLocation {
    [self.locationManager requestWhenInUseAuthorization];
    self.locationManager.delegate        = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
}

#pragma mark - API Requests
- (void)fetchPlacesBasedOnServiceType {
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL        *url     = [NSURL URLWithString:[NSString stringWithFormat
                                                  :@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%lf,%lf&radius=6000&types=%@&key=%@",
                                                  self.coordinate.latitude,
                                                  self.coordinate.longitude,
                                                  self.selectedService,
                                                  serverKey
                                                  ]];
    
    [[session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data,
                                                      NSURLResponse * _Nullable response,
                                                      NSError * _Nullable error) {
        if ( error ) {
            NSLog(@"Error : %@, %@",error.localizedDescription, error.userInfo);
            [self presentAlertToUser];
        } else {
            dispatch_async(dispatch_get_main_queue(),^{
                self.dictionaryOfSearchResults = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                //                NSLog(@"%@",self.dictionaryOfSearchResults);
                [self parseAndPin];
                
            });
        }
    }] resume];
}

- (void)fetchInfoBasedForSelectedPlace {
    NSLog(@"lat %lf, long %lf",self.coordinate.latitude, self.coordinate.longitude);
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSString     *url     = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?placeid=%@&key=%@",self.placeToSearch, serverKey];
    [[session dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData * _Nullable data,
                                                                            NSURLResponse * _Nullable response,
                                                                            NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error : %@, %@",error.localizedDescription, error.userInfo);
        } else {
            dispatch_async(dispatch_get_main_queue(),^{
                self.dictionaryOfPlaceSearchResults = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                //                    NSLog(@"%@",results);
                [self parseAndPush];
                [self performSegueWithIdentifier:@"showDetailView" sender:nil];
            });
        }
    }] resume];
}

#pragma mark - GMSMapView Delegate
- (UIView*)mapView:(GMSMapView*)mapView markerInfoWindow:(CustomMarker*)marker {
    CustomPinView *infoWindow        = [[[NSBundle mainBundle]loadNibNamed:@"CustomPinView" owner:self options:nil]objectAtIndex:0];
    infoWindow.titleLabel.text    = marker.title;
    infoWindow.subTitleLabel.text = marker.snippet;
    infoWindow.leftImage.image    = marker.image;
    return infoWindow;
}

- (void)mapView:(GMSMapView*)mapView didTapInfoWindowOfMarker:(CustomMarker*)marker {
    self.placeToSearch = marker.place_id;
    NSLog(@"PLACE ID == %@",self.placeToSearch);
    [self fetchInfoBasedForSelectedPlace];
}

#pragma mark - CLLocation Manager Delegate
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *location = [locations lastObject];
    self.coordinate      = location.coordinate;
    self.mapView.camera = [GMSCameraPosition cameraWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude zoom:15];
    [self fetchPlacesBasedOnServiceType];
    [self.locationManager stopUpdatingLocation];
    self.locationManager = nil;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Error = %@, %@", error.localizedDescription, error.userInfo);
    [self presentAlertToUser];
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

#pragma mark - IBActions
- (IBAction)switchView:(id)sender {
    
}

#pragma mark - Miscellaneous
- (void)presentAlertToUser {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sorry!" message:@"Please, try again." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        //do nothing... alert dismisses itself
    }];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)parseAndPin {
    NSDictionary *result    = [self.dictionaryOfSearchResults objectForKey:@"results"];
    NSArray *tempGeo   = [result valueForKey:@"geometry"];
    NSArray *tempLoc   = [tempGeo valueForKey:@"location"];
    NSArray *nameArray      = [result valueForKey:@"name"];
    NSArray *iconArray      = [result valueForKey:@"icon"];
    NSArray *latitudeArray  = [tempLoc valueForKey:@"lat"];
    NSArray *longitudeArray = [tempLoc valueForKey:@"lng"];
    NSArray *place_idArray =  [result valueForKey:@"place_id"];
    
    for (int i = 0 ; i < latitudeArray.count; i++) {
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[[latitudeArray objectAtIndex:i] doubleValue]
                                                                longitude:[[longitudeArray objectAtIndex:i] doubleValue] zoom:12];
        NSString *string = [NSString stringWithFormat:@"%@",[iconArray objectAtIndex:i]];
        
        CustomMarker *searchMarker = [[CustomMarker alloc] init];
        searchMarker.position      = camera.target;
        searchMarker.title         = [NSString stringWithFormat:@"%@",[nameArray objectAtIndex:i]];
        searchMarker.snippet       = @"NYC";
        searchMarker.image         = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:string]]];
        searchMarker.icon          = [GMSMarker markerImageWithColor:[UIColor purpleColor]];
        searchMarker.place_id      = [place_idArray objectAtIndex:i];
        
        self.arrayOfSearchMarkers = [NSMutableArray arrayWithObject:searchMarker];
        for (CustomMarker *pin in self.arrayOfSearchMarkers) {
            pin.map = self.mapView;
        }
    }
}

-(void)parseAndPush {
    NSDictionary *dict = [self.dictionaryOfPlaceSearchResults objectForKey:@"result"];
    self.serviceInfo = [Service new];
    self.serviceInfo.formatted_address          = [dict valueForKey:@"formatted_address"];
    self.serviceInfo.formatted_phone_number     = [dict valueForKey:@"formatted_phone_number"];
    self.serviceInfo.name                       = [dict valueForKey:@"name"];
    self.serviceInfo.international_phone_number = [dict valueForKey:@"international_phone_number"];
    //    NSLog(@"phone number = %@, address = %@, name = %@, international phone num = %@",service.formatted_phone_number, service.formatted_address, service.name, service.international_phone_number);
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
    
}

@end
