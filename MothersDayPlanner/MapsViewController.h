//
//  MapsViewController.h
//  MothersDayPlanner
//
//  Created by Vladyslav Gusakov on 5/5/16.
//  Copyright © 2016 V-RGB. All rights reserved.
//

#import <UIKit/UIKit.h>
@import GoogleMaps;

@interface MapsViewController : UIViewController

@property (nonatomic, strong) NSString *pinImage;
@property (nonatomic, strong) NSString              *serviceImage;
@property (nonatomic, strong) NSDictionary          *dictionaryOfSearchResults;
@property (nonatomic, strong) NSMutableArray        *arrayOfSearchMarkers;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;


@end
