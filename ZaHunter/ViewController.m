//
//  ViewController.m
//  ZaHunter
//
//  Created by Fletcher Rhoads on 1/22/14.
//  Copyright (c) 2014 Fletcher Rhoads. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <AddressBook/AddressBook.h>
#import <MapKit/MapKit.h>

@interface ViewController () <CLLocationManagerDelegate, UIActionSheetDelegate, UITableViewDataSource, UITableViewDelegate>
{
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    CLPlacemark *currentAddress;
    NSArray *pizzaPlaces;
    CLLocation *location;
    
    __weak IBOutlet UITableView *tableView;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self requestCurrentLocation];
}

-(void)requestCurrentLocation
{
    locationManager = [CLLocationManager new];
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
}

-(void)searchForPizza
{
    MKLocalSearchRequest *searchRequest = [MKLocalSearchRequest new];
    
    searchRequest.region = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, 30000, 30000);

    searchRequest.naturalLanguageQuery = @"pizza";
    
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:searchRequest];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        pizzaPlaces = response.mapItems;
        pizzaPlaces = [pizzaPlaces sortedArrayUsingComparator:^NSComparisonResult(MKMapItem *obj1, MKMapItem *obj2)
        {
             return [currentLocation distanceFromLocation:obj1.placemark.location]
                  - [currentLocation distanceFromLocation:obj2.placemark.location];
        }];
        [tableView reloadData];
        
    }];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    for (CLLocation *phoneLocation in locations) {
        if (phoneLocation.verticalAccuracy > 500 || phoneLocation.horizontalAccuracy > 500)
            continue;

        [locationManager stopUpdatingLocation];
        currentLocation = phoneLocation;
        [self searchForPizza];
        break;
    }
}

-(void)showDirectionsTo:(MKMapItem*)destinationItem
{
    MKDirectionsRequest *request = [MKDirectionsRequest new];
    request.source = [MKMapItem mapItemForCurrentLocation];
    request.destination = destinationItem;
    MKDirections *directions = [[MKDirections alloc]initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
    }];
}

-(UITableViewCell *)tableView:(UITableView *)myTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [myTableView dequeueReusableCellWithIdentifier:@"PizzaID"];
    
    CLPlacemark *place = [pizzaPlaces[indexPath.row] placemark];
    cell.textLabel.text = place.name;

    double distance = [place.location distanceFromLocation:currentLocation];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%f", distance];
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 9;
}

-(void)compareAddress
{
    
    
    //[self showDirectionsTo:pizzaPlaces];
}







@end
