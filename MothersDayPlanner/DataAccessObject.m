//
//  DataAccessObject.m
//  MothersDayPlanner
//
//  Created by Robert Baghai on 5/17/16.
//  Copyright © 2016 V-RGB. All rights reserved.
//

#import "DataAccessObject.h"
#import "Service.h"
#import <UIKit/UIKit.h>

@implementation DataAccessObject

+ (instancetype)sharedInstance {
    static dispatch_once_t cp_singleton_once_token;
    static DataAccessObject *sharedInstance;
    dispatch_once(&cp_singleton_once_token, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.serviceList = [[NSMutableArray alloc] init];
    });
    return sharedInstance;
}

#pragma mark - NSUserDefaults
- (void)save {
    NSData *encodeObject     = [NSKeyedArchiver archivedDataWithRootObject:self.serviceList];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodeObject forKey:@"serviceListData"];
    [defaults synchronize];
}

- (void)fetchAllDataFromUserDefaults {
    if ([[NSUserDefaults standardUserDefaults] dataForKey:@"serviceListData"]) {
        NSData *unarchivedData = [[NSUserDefaults standardUserDefaults] dataForKey:@"serviceListData"];
        self.serviceList = [NSKeyedUnarchiver unarchiveObjectWithData:unarchivedData];
    } else {
        NSData *encodeObject     = [NSKeyedArchiver archivedDataWithRootObject:self.serviceList];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:encodeObject forKey:@"serviceListData"];
        [defaults synchronize];
    } 
}

- (void)trackFirstLaunch {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        //sets default pink color on first launch
        UIColor *baseColor = [UIColor colorWithRed: 0.988 green: 0.353 blue: 0.451 alpha: 1];
        NSData *colorData  = [NSKeyedArchiver archivedDataWithRootObject:baseColor];
        [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:@"themeColor"];
    }
}


#pragma mark - Test Reachability
- (BOOL)validInternetConnectionExists {
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus netWorkStatus = [self.internetReachability currentReachabilityStatus];
    return (netWorkStatus != NotReachable) ? YES : NO;
}

@end
