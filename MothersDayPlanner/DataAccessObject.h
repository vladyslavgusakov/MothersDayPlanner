//
//  DataAccessObject.h
//  MothersDayPlanner
//
//  Created by Robert Baghai on 5/17/16.
//  Copyright © 2016 V-RGB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@interface DataAccessObject : NSObject

@property (nonatomic, strong) NSMutableArray *serviceList;
@property (nonatomic, strong) Reachability *internetReachability;

+ (instancetype)sharedInstance;
- (void)save;
- (void)fetchAllDataFromUserDefaults;
- (void)trackFirstLaunch;
- (BOOL)validInternetConnectionExists;

@end
