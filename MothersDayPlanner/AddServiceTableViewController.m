//
//  AddServiceTableViewController.m
//  MothersDayPlanner
//
//  Created by Vladyslav Gusakov on 5/5/16.
//  Copyright © 2016 V-RGB. All rights reserved.
//

#import "AddServiceTableViewController.h"
#import "MapsViewController.h"

@interface AddServiceTableViewController ()

@property (nonatomic, strong) NSDictionary *serviceImages;
@property (nonatomic, strong) NSArray      *servicesList;


@end

@implementation AddServiceTableViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
//    servicesList = @[@"spa", @"florist", @"shoe_store", @"beauty_salon", @"jewelry_store", @"liquor_store", @"hair_care", @"clothing_store"];
    self.servicesList = @[@"spa", @"florist", @"shoe_store", @"beauty_salon", @"jewelry_store", @"liquor_store", @"hair_care", @"clothing_store"];
    
    //TODO: Add more images
    self.serviceImages = @{
                           @"spa": @"spa_main.jpg",
                           @"florist": @"flowers.jpg",
                           @"shoe_store" : @"shoe_store_main.png",
                           @"beauty_salon" : @"beauty_main.png",
                           @"jewelry_store": @"jew.jpg",
                           @"liquor_store": @"liq.jpg",
                           @"hair_care": @"hair.jpg",
                           @"clothing_store" : @"clothing_main.jpg"
                           };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.servicesList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell...
//    cell.textLabel.text = [[servicesList[indexPath.row] stringByReplacingOccurrencesOfString:@"_" withString:@" "] uppercaseString];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = [[self.servicesList[indexPath.row] stringByReplacingOccurrencesOfString:@"_" withString:@" "] uppercaseString];
    cell.imageView.image = [UIImage imageNamed:self.servicesList[indexPath.row]];
    return cell;
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    MapsViewController *mapsVC = (MapsViewController*)segue.destinationViewController;
    NSIndexPath *indexPath     = [self.tableView indexPathForSelectedRow];
    mapsVC.selectedService     = self.servicesList[indexPath.row];
    mapsVC.serviceImage        = [self.serviceImages valueForKey:self.servicesList[indexPath.row]];
}


@end
