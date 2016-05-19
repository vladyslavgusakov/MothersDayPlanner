//
//  ListContainerViewController.h
//  MothersDayPlanner
//
//  Created by Robert Baghai on 5/19/16.
//  Copyright © 2016 V-RGB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Service.h"

@interface ListContainerViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *arrayOfPlaces;

@property (nonatomic, strong) NSString *serviceImage;
@property (nonatomic, strong) Service  *serviceInfo;


@property (nonatomic, strong) NSDictionary *dictionaryOfPlaceSearchResults;

@end
