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
#import "DetailsViewController.h"
#import "ListContainerViewController.h"
#import "DataAccessObject.h"

@interface MapsViewController () <GMSMapViewDelegate>

#pragma mark - IBOutlets
@property (weak, nonatomic) IBOutlet UIView *ListContainer;

#pragma mark - IBActions
- (IBAction)switchValue:(id)sender;

#pragma mark - Miscellaneous
@property (nonatomic, strong) NSDictionary     *dictionaryOfPlaceSearchResults;
@property (nonatomic, strong) NSString         *placeToSearch;
@property (nonatomic, strong) Service          *serviceInfo;
@property (nonatomic, strong) DataAccessObject *dao;
@property (nonatomic, strong) UIImageView      *markerImage;

@end

@implementation MapsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dao = [DataAccessObject sharedInstance];
    [self setMapviewInitialSettings];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    for (CustomMarker *pin in self.arrayOfSearchMarkers) { //drops pins on map
        pin.appearAnimation = kGMSMarkerAnimationPop;
        pin.iconView = self.markerImage;
        pin.map      = self.mapView;
    }
    
}

- (void) setMapviewInitialSettings {
    self.mapView.myLocationEnabled         = YES;
    self.mapView.settings.compassButton    = YES;
    self.mapView.settings.myLocationButton = YES;
    self.mapView.delegate                  = self;
    self.mapView.hidden                    = NO;
    self.ListContainer.hidden              = YES;
    self.mapView.camera = [GMSCameraPosition cameraWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude zoom:15];
    [self createImageForMarker];
//        for (CustomMarker *pin in self.arrayOfSearchMarkers) { //drops pins on map
//            pin.appearAnimation = kGMSMarkerAnimationPop;
//            pin.iconView = self.markerImage;
//            pin.map      = self.mapView;
//        }
}

- (void)createImageForMarker {
    self.markerImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.pinImage]];
    self.markerImage.frame = CGRectMake(0, 0, 35, 35);
}

#pragma mark - API Requests
- (void)fetchInfoBasedOnSelectedPlace {
//    NSLog(@"lat %lf, long %lf",self.coordinate.latitude, self.coordinate.longitude);
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
                    [self performSegueWithIdentifier:@"showDetailView" sender:nil];
                });
            }
        }] resume];
    } else {
        [self presentAlertForBadInternet];
    }
}

#pragma mark - GMSMapView Delegate
- (UIView*)mapView:(GMSMapView*)mapView markerInfoWindow:(CustomMarker*)marker {
    CustomPinView *infoWindow     = [[[NSBundle mainBundle]loadNibNamed:@"CustomPinView" owner:self options:nil]objectAtIndex:0];
    infoWindow.titleLabel.text    = marker.title;
    infoWindow.subTitleLabel.text = marker.snippet;
    infoWindow.leftImage.image    = marker.image;
    /////
    
    infoWindow.backgroundColor = [UIColor clearColor];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = infoWindow.bounds;
    gradient.colors = [NSArray arrayWithObjects: (id)[[UIColor purpleColor] CGColor], (id)[[UIColor colorWithRed:1 green:0.565 blue:0.766 alpha:1] CGColor], nil];
    [infoWindow.layer insertSublayer:gradient atIndex:0];
    
    if ([infoWindow.subTitleLabel.text isEqualToString:@"Open Now!"]) {
        infoWindow.subTitleLabel.textColor = [UIColor greenColor];
    }
    
//    infoWindow.backgroundColor = [UIColor redColor];
//    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
//    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
//    blurEffectView.frame = self.mapView.bounds;
//    [self.mapView addSubview:blurEffectView];
    
    return infoWindow;
}

- (void)mapView:(GMSMapView*)mapView didTapInfoWindowOfMarker:(CustomMarker*)marker {
    self.placeToSearch = marker.placeId;
//    NSLog(@"PLACE ID == %@",self.placeToSearch);
    [self fetchInfoBasedOnSelectedPlace];
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

- (void)presentAlertForBadInternet {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Internet Required" message:@"Please check your internet connection and try again." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        //alert controller dismisses itself
    }];
    [alertController addAction:dismissAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)parseAndPush {
    NSDictionary *dict = [self.dictionaryOfPlaceSearchResults objectForKey:@"result"];
    self.serviceInfo   = [Service new];
    self.serviceInfo.formattedAddress         = [dict valueForKey:@"formatted_address"];
    self.serviceInfo.formattedPhoneNumber     = [dict valueForKey:@"formatted_phone_number"];
    self.serviceInfo.placeName                = [dict valueForKey:@"name"];
    self.serviceInfo.internationalPhoneNumber = [dict valueForKey:@"international_phone_number"];
    self.serviceInfo.serviceImage             = self.serviceImage;
    self.serviceInfo.website                  = [dict valueForKey:@"website"];
    self.serviceInfo.latitude                 = self.coordinate.latitude;
    self.serviceInfo.longitude                = self.coordinate.longitude;
}

- (IBAction)switchValue:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        self.mapView.hidden       = NO;
        self.ListContainer.hidden = YES;
    } else {
        self.mapView.hidden       = YES;
        self.ListContainer.hidden = NO;
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showDetailView"]) {
        DetailsViewController *detailView = (DetailsViewController *)segue.destinationViewController;
        detailView.service = self.serviceInfo;
    } else if ([segue.identifier isEqualToString:@"listContainer"]) {
        ListContainerViewController *listView = (ListContainerViewController *)segue.destinationViewController;
        listView.arrayOfPlaces = self.arrayOfSearchMarkers;
        listView.serviceImage  = self.serviceImage;
        listView.coordinate    = self.coordinate;
        listView.pinImage      = self.pinImage;
    }
}
@end
