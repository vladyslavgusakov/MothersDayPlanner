//
//  Service.h
//  MothersDayPlanner
//
//  Created by Vladyslav Gusakov on 5/5/16.
//  Copyright © 2016 V-RGB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Service : NSObject

@property (nonatomic, strong) NSString *formattedAddress;
@property (nonatomic, strong) NSString *formattedPhoneNumber;
@property (nonatomic, strong) NSString *internationalPhoneNumber;
@property (nonatomic, strong) NSString *placeName;
@property (nonatomic, strong) NSString *serviceImage;
@property (nonatomic, strong) NSString *fromTime;
@property (nonatomic, strong) NSString *toTime;
//@property (nonatomic, strong) NSString *note;
@property (nonatomic, strong) NSString *website;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;

@end
