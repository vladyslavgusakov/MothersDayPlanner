//
//  Service.h
//  MothersDayPlanner
//
//  Created by Vladyslav Gusakov on 5/5/16.
//  Copyright © 2016 V-RGB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Service : NSObject

@property (nonatomic, strong) NSString *formatted_address;
@property (nonatomic, strong) NSString *formatted_phone_number;
@property (nonatomic, strong) NSString *international_phone_number;
@property (nonatomic, strong) NSString *name; //place name

@end
