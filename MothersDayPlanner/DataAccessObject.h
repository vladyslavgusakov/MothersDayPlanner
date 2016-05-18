//
//  DataAccessObject.h
//  MothersDayPlanner
//
//  Created by Robert Baghai on 5/17/16.
//  Copyright © 2016 V-RGB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataAccessObject : NSObject

@property (nonatomic, strong) NSMutableArray *serviceList;

+ (instancetype)sharedInstance;
- (void)save;
- (void)fetchAllDataFromUserDefaults;

@end
