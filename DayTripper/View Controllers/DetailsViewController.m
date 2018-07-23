//
//  DetailsViewController.m
//  DayTripper
//
//  Created by Kimora Kong on 7/18/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "DetailsViewController.h"
#import <Corelocation/Corelocation.h>
#import "APIManager.h"
#import "UIImageView+AFNetworking.h"
#import "Functions.h"

@import UberRides;

@interface DetailsViewController () <CLLocationManagerDelegate>

@property (strong, nonatomic) NSArray<CLPlacemark *> *somePlacemarks;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) CLPlacemark *somePlacemark;
@property (strong, nonatomic) NSMutableArray *images;
@property (strong, nonatomic) NSMutableArray *imageUrls;
@property (nonatomic) int currentImageIndex;
- (IBAction)didTapDirections:(id)sender;
@property (nonatomic) int currNumEventPhotos;
@property (weak, nonatomic) IBOutlet UILabel *hoursLabel;
@property (weak, nonatomic) IBOutlet UIButton *websiteLink;
@property (strong, nonatomic) NSString* websiteToGoTo;
@property (weak, nonatomic) IBOutlet UIView *uberView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLGeocoder *geocoder;
@property (nonatomic) double currentLat;
@property (nonatomic) double currentLong;
@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.nameLabel.text = self.activity.name;
    
    //UBER + LOCATION
    self.geocoder = [[CLGeocoder alloc] init];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startMonitoringSignificantLocationChanges];
    [self.locationManager startUpdatingLocation];
    
    
    


    
    //CATEGORIES
    if([[self.activity activityType] isEqualToString:@"Place"]){
        self.categoriesLabel.text = [[self.activity.categories[0][@"name"] stringByReplacingOccurrencesOfString:@"-" withString:@" "] capitalizedString];
    } else if([[self.activity activityType] isEqualToString:@"Food"]){
        self.categoriesLabel.text = [[self.activity.categories[0][@"title"] stringByReplacingOccurrencesOfString:@"-" withString:@" "] capitalizedString];
    } else if ([[self.activity activityType] isEqualToString:@"Event"]){
        self.categoriesLabel.text = [[self.activity.categories[0] stringByReplacingOccurrencesOfString:@"-" withString:@" "] capitalizedString];
    }
    
    //IMAGES
    //init the images arrays that will be used for storing images
    self.imageUrls = [[NSMutableArray alloc] init];
    self.images = [[NSMutableArray alloc] init];
    self.currentImageIndex = 0;

    self.categoriesLabel.text = [Functions primaryActivityCategory:self.activity];
        
    //get the images related to location
    if([[self.activity activityType] isEqualToString:@"Place"]){
        [self.hoursLabel setHidden:YES];
        //get foursquare images
        [self fetch4SQPhotos:self.activity.apiId];
        //hide website button
        [self.websiteLink setHidden:YES];
    } else if([[self.activity activityType] isEqualToString:@"Food"]){
        //get yelp images
        [self fetchYelpPhotos:self.activity.apiId];
        //get the hours
        [self fetchYelpHours:self.activity.apiId];
        //set website url
        self.websiteToGoTo = self.activity.website;
    } else if ([[self.activity activityType] isEqualToString:@"Event"]){
        [self.hoursLabel setHidden:YES];
        [self getEventPhotoObjectsByLocation];
        [self.websiteLink setHidden:YES];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *currLocation = [locations lastObject];
    self.currentLat = currLocation.coordinate.latitude;
    self.currentLong = currLocation.coordinate.longitude;
//    NSLog(@"%f", self.currentLat);
//    NSLog(@"%f", self.currentLong);
    
        // stopping locationManager from fetching again
        [self.locationManager stopUpdatingLocation];
    
    //add the uber button
    UBSDKRideParametersBuilder *builder = [[UBSDKRideParametersBuilder alloc] init];
    CLLocation *pickupLocation = [[CLLocation alloc] initWithLatitude:self.currentLat longitude:self.currentLong];
    CLLocation *dropoffLocation = [[CLLocation alloc] initWithLatitude:self.activity.latitude longitude:self.activity.longitude];
    [builder setPickupLocation:pickupLocation];
    [builder setDropoffLocation:dropoffLocation];
    [builder setDropoffNickname:[NSString stringWithFormat:@"%@", self.activity.name]];
    UBSDKRideParameters *rideParameters = [builder build];
    
    self.somePlacemarks = [[NSArray<CLPlacemark *> alloc] init];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.activity.latitude longitude:self.activity.longitude];
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error){
            NSLog (@"%@", error.localizedDescription);
        }else{
            self.somePlacemarks = [placemarks copy];
            self.somePlacemark = [placemarks firstObject];
            
            NSArray *partsAddr = [[NSArray alloc] initWithObjects: self.somePlacemark.name, self.somePlacemark.locality, self.somePlacemark.administrativeArea, self.somePlacemark.postalCode, self.somePlacemark.country, nil];
            NSString *address = [partsAddr componentsJoinedByString:@", "];
            self.locationLabel.text =  address;
            [builder setDropoffAddress:[NSString stringWithFormat:@"%@", self.somePlacemark.name]];
        }
    }];
    
    UBSDKRideRequestButton *button = [[UBSDKRideRequestButton alloc] initWithRideParameters:rideParameters];
    [self.uberView addSubview:button];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"failed to fetch current location : %@", error);
}


- (IBAction)didTapDirections:(id)sender {
    NSString *baseURL = @"https://www.google.com/maps/dir/?api=1";
    NSString *url = [NSString stringWithFormat:@"%@%f%@%f%@%f%@%f", @"&origin=", self.currentLat, @",", self.currentLong,@"&destination=", self.activity.latitude, @",", self.activity.longitude];
    NSString *URL = [baseURL stringByAppendingString:url];
    NSURL *googleURL = [NSURL URLWithString:URL];
        [[UIApplication sharedApplication] openURL:googleURL options:@{} completionHandler:^(BOOL success) {
        if (success){
            NSLog(@"YAY dir");
        }else{
            NSLog(@" NO YAY fail");
        }
    }];
}

- (void)setActivity:(id<Activity>)activity{
    _activity = activity;
}


- (IBAction)swipeLeft:(id)sender {
    [self handleSwipeLeft:sender];

}

- (IBAction)swipeRight:(id)sender {
    [self handleSwipeRight:sender];
}


#pragma mark - API requests
- (void) fetch4SQPhotos: (NSString*) tripId {
    APIManager *apiManager = [[APIManager alloc] init];
    //make the request
    NSString *baseURL =  [NSString stringWithFormat:@"%@%@%@", @"https://api.foursquare.com/v2/venues/", tripId, @"/photos"];
    //params
    NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc] init];
    [paramsDict setObject:[[[NSProcessInfo processInfo] environment] objectForKey:@"CLIENT_ID_4SQ"] forKey:@"client_id"];
    [paramsDict setObject:[[[NSProcessInfo processInfo] environment] objectForKey:@"CLIENT_SECRET_4SQ"] forKey:@"client_secret"];
    NSString *currDate = [self generatCurrentDateFourSquare];
    [paramsDict setObject:currDate forKey:@"v"];
    
    [apiManager getRequest:baseURL params:[paramsDict copy] completion:^(NSArray* responseDict) {
        NSArray *photoObjs = responseDict[0][@"response"][@"photos"][@"items"];
        for (NSDictionary *photoObj in photoObjs) {
            NSString* url = [self constructURLFromDict:photoObj];
            [self.imageUrls addObject:url];
        }
        [self populateImageArray];
    }];
}

- (NSString *) generatCurrentDateFourSquare {
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    return [dateFormatter stringFromDate:today];
}

- (NSString *) constructURLFromDict:(NSDictionary*) dict {
    NSString* prefix = dict[@"prefix"];
    NSString* suffix = dict[@"suffix"];
    NSString* width = [dict[@"width"] stringValue];
    NSString* height = [dict[@"height"] stringValue];
    return [NSString stringWithFormat:@"%@%@%@%@%@", prefix, width, @"x", height, suffix];
}

- (void) fetchYelpPhotos: (NSString*) tripId {
    APIManager *apiManager = [[APIManager alloc] init];
    //make the request
    NSString *baseURL =  [NSString stringWithFormat:@"%@%@", @"https://api.yelp.com/v3/businesses/", tripId];
    //params
    NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc] init];
    NSString *apiToken = [NSString stringWithFormat:@"%@%@", @"Bearer ", [[[NSProcessInfo processInfo] environment] objectForKey:@"APIKEY_YELP"]];
    [paramsDict setObject:apiToken forKey:@"Authorization"];

    [apiManager getRequest:baseURL params:[paramsDict copy] completion:^(NSArray* responseDict) {
        NSArray *photos = responseDict[0][@"photos"];
        for (NSString* photo in photos) {
            [self.imageUrls addObject:photo];
        }
        [self populateImageArray];

    }];
}

//gets hours of operation
- (void) fetchYelpHours: (NSString*) tripId {
    //get index of current day of the week
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [gregorian components:NSCalendarUnitWeekday fromDate:[NSDate date]];
    int oldweekdayIndex = (int) [comps weekday];
    //now map such that monday represents 0 and sunday is 6
    int weekdayIndex = [self mapToNewIndex:oldweekdayIndex];
    
    APIManager *apiManager = [[APIManager alloc] init];
    //make the request
    NSString *baseURL =  [NSString stringWithFormat:@"%@%@", @"https://api.yelp.com/v3/businesses/", tripId];
    //params
    NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc] init];
    NSString *apiToken = [NSString stringWithFormat:@"%@%@", @"Bearer ", [[[NSProcessInfo processInfo] environment] objectForKey:@"APIKEY_YELP"]];
    [paramsDict setObject:apiToken forKey:@"Authorization"];
    
    __weak typeof(self) weakSelf = self;
    [apiManager getRequest:baseURL params:[paramsDict copy] completion:^(NSArray* responseDict) {
        NSArray *days = responseDict[0][@"hours"][0][@"open"];
        NSDictionary* currDayObject = days[weekdayIndex];
        NSString* startTimeString = [self militaryTimeToAMPM: currDayObject[@"start"]];
        NSString* endTimeString = [self militaryTimeToAMPM: currDayObject[@"end"]];
        [weakSelf setHoursAsync:startTimeString endTimeString:endTimeString];
    }];
}

//this function converts the Yelp Military time to normal AM/PM time
- (NSString*) militaryTimeToAMPM: (NSString *) milTime {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"HHmm";
    NSDate *date = [dateFormatter dateFromString:milTime];
    
    dateFormatter.dateFormat = @"hh:mm a";
    NSString *pmamDateString = [dateFormatter stringFromDate:date];
    return pmamDateString;
}

//converts week index starting at sunday to week index number starting at monday
- (int) mapToNewIndex:(int) oldIndex {
    switch (oldIndex)
    {
        case 0:
            return 6;
            break;
        case 1:
            return 0;
            break;
        case 2:
            return 1;
            break;
        case 3:
            return 2;
            break;
        case 4:
            return 3;
            break;
        case 5:
            return 4;
            break;
        case 6:
            return 5;
            break;
        default:
            return 0;
            break;
    }
}



- (void) populateImageArray {
    __weak typeof(self) weakSelf = self;
    for (NSString* url in self.imageUrls) {
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        UIImage *image = [UIImage imageWithData:data];
        [self.images addObject:image];
    }
    [weakSelf setImageAsync];
    
}

-(void) setImageAsync {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.images.count > 0) {
            UIImage *image = self.images[0];
            [self.imageView setImage:image];
        }
    });
}

-(void) setHoursAsync:(NSString*)startTimeString endTimeString:(NSString*)endTimeString {
    dispatch_async(dispatch_get_main_queue(), ^{
         self.hoursLabel.text = [NSString stringWithFormat:@"%@%@%@", startTimeString, @" - ", endTimeString];
    });
   
}


- (IBAction)tapWebsiteLink:(id)sender {
    if (![self.websiteLink isHidden]) {
        //go to url if not hidden
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: self.websiteToGoTo]];
    }
}




#pragma mark - Image Scroll Animation

- (void)addAnimationPresentToView:(UIView *)viewTobeAnimated
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.30;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [transition setValue:@"IntroSwipeIn" forKey:@"IntroAnimation"];
    transition.fillMode=kCAFillModeForwards;
    transition.type = kCATransitionPush;
    transition.subtype =kCATransitionFromRight;
    [viewTobeAnimated.layer addAnimation:transition forKey:nil];
    
}

- (void)addAnimationPresentToViewOut:(UIView *)viewTobeAnimated
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.30;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [transition setValue:@"IntroSwipeIn" forKey:@"IntroAnimation"];
    transition.fillMode=kCAFillModeForwards;
    transition.type = kCATransitionPush;
    transition.subtype =kCATransitionFromLeft;
    [viewTobeAnimated.layer addAnimation:transition forKey:nil];
    
}

-(void)changeImage
{
    //set image with url
    UIImage *image = self.images[self.currentImageIndex];
    [self.imageView setImage:image];
}
-(void)handleSwipeLeft:(id)sender
{
    if(self.currentImageIndex < (self.images.count - 1))
    {
        self.currentImageIndex = self.currentImageIndex + 1;
        [self addAnimationPresentToView:self.imageView];
        [self changeImage];
    }
    
}
-(void)handleSwipeRight:(id)sender
{
    if (self.currentImageIndex > 0)
    {
        self.currentImageIndex = self.currentImageIndex - 1;
        [self addAnimationPresentToViewOut:self.imageView];
        [self changeImage];
    }
    
}


# pragma mark - Google Places Request for Event API
//given a lat and long will search to find nearby places and their photo ids
- (void) getEventPhotoObjectsByLocation {
    __weak typeof(self) weakSelf = self;
    APIManager *apiManager = [[APIManager alloc] init];
    //make the request
    NSString *baseURL = @"https://maps.googleapis.com/maps/api/place/nearbysearch/json";
    //params
    NSString* locationParam = [NSString stringWithFormat:@"%f%@%f", self.activity.latitude, @",", self.activity.longitude];
    NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc] init];
    
    [paramsDict setObject:[[[NSProcessInfo processInfo] environment] objectForKey:@"APIKEY_GOOGLE"] forKey:@"key"];
    [paramsDict setObject:locationParam forKey:@"location"];
    [paramsDict setObject:@"100" forKey:@"radius"];
    
    int maxNumPhotos = 3;
    
    [apiManager getRequest:baseURL params:[paramsDict copy] completion:^(NSArray* responseDict) {
        NSArray *placesResults = responseDict[0][@"results"];
        for (NSDictionary* place in placesResults) {
            if (self.currNumEventPhotos >= maxNumPhotos) {
                break;
            }
            NSArray* photoRefs = place[@"photos"];
            if (photoRefs.count > 0) {
                for (NSDictionary* photoRef in photoRefs) {
                    if (self.currNumEventPhotos >= maxNumPhotos) {
                        break;
                    }
                    NSString* photoRefString = photoRef[@"photo_reference"];
                    if (photoRefString.length > 0) {
                        if (self.currNumEventPhotos < maxNumPhotos) {
                            [self getImageFromPhotoRef: photoRefString];
                            self.currNumEventPhotos = self.currNumEventPhotos + 1;
                        }
                    }
                }
            }
        }
        [weakSelf setImageAsync];
    }];
}

- (void) getImageFromPhotoRef:(NSString*) photoReference {
    APIManager *apiManager = [[APIManager alloc] init];
    
    NSString *baseURL = @"https://maps.googleapis.com/maps/api/place/photo";
    NSString* maxWidth = @"?maxwidth=600";
    NSString* photoRef = [NSString stringWithFormat:@"%@%@", @"&photoreference=", photoReference];
    NSString* key = [NSString stringWithFormat:@"%@%@", @"&key=", [[[NSProcessInfo processInfo] environment] objectForKey:@"APIKEY_GOOGLE"]];
    NSString* finalURL = [NSString stringWithFormat:@"%@%@%@%@", baseURL, maxWidth, photoRef, key];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:finalURL]];
    UIImage *image = [UIImage imageWithData:data];
    [self.images addObject:image];
    
}



@end
