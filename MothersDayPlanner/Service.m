//
//  Service.m
//  MothersDayPlanner
//
//  Created by Vladyslav Gusakov on 5/5/16.
//  Copyright © 2016 V-RGB. All rights reserved.
//

#import "Service.h"

@implementation Service

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.formattedAddress forKey:@"formattedAddress"];
    [aCoder encodeObject:self.formattedPhoneNumber forKey:@"formattedPhoneNumber"];
    [aCoder encodeObject:self.internationalPhoneNumber forKey:@"internationalPhoneNumber"];
    [aCoder encodeObject:self.placeName forKey:@"placeName"];
    [aCoder encodeObject:self.serviceImage forKey:@"serviceImage"];
    [aCoder encodeObject:self.fromTime forKey:@"fromTime"];
    [aCoder encodeObject:self.toTime forKey:@"toTime"];
    [aCoder encodeObject:self.note forKey:@"note"];
    [aCoder encodeObject:self.website forKey:@"website"];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    if(self = [super init]){
        self.formattedAddress         = [aDecoder decodeObjectForKey:@"formattedAddress"];
        self.formattedPhoneNumber     = [aDecoder decodeObjectForKey:@"formattedPhoneNumber"];
        self.internationalPhoneNumber = [aDecoder decodeObjectForKey:@"internationalPhoneNumber"];
        self.placeName                = [aDecoder decodeObjectForKey:@"placeName"];
        self.serviceImage             = [aDecoder decodeObjectForKey:@"serviceImage"];
        self.fromTime                 = [aDecoder decodeObjectForKey:@"fromTime"];
        self.toTime                   = [aDecoder decodeObjectForKey:@"toTime"];
        self.note                     = [aDecoder decodeObjectForKey:@"note"];
        self.website                  = [aDecoder decodeObjectForKey:@"website"];
    }
    return self;
}

@end


