//
//  Trip.h
//  DayTripper
//
//  Created by Riley Schnee on 7/16/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface Trip : PFObject <PFSubclassing>
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSMutableArray *activities;
@property (strong, nonatomic) PFUser *planner;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (strong, nonatomic) NSMutableArray *attendees;
@property (strong, nonatomic) NSDate *tripDate;
@property (strong, nonatomic) NSString *albumId;

+ (void) saveTrip: ( Trip * _Nullable )trip withName: (NSString * _Nullable)name withDate: (NSDate *_Nullable)date withLat: (double)lat withLon:(double)lon withCompletion: (PFBooleanResultBlock  _Nullable)completion;

@end
