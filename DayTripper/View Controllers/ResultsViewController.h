//
//  ResultsViewController.h
//  DayTripper
//
//  Created by Riley Schnee on 7/13/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResultsCell.h"
#import "ItinViewController.h"
#import "Functions.h"
#import "Trip.h"
#import "APIManager.h"
#import "Activity.h"
#import "Food.h"
#import "Event.h"

@interface ResultsViewController : UIViewController
@property (nonatomic, strong) NSString* location;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (strong, nonatomic) NSDate* windowStartTime;
@property (strong, nonatomic) NSDate* windowEndTime;
@property (strong, nonatomic) NSMutableArray *placeCategories;
@property (strong, nonatomic) NSMutableArray *foodCategories;
@property (strong, nonatomic) NSMutableArray *eventCategories;
@property (strong, nonatomic) NSDate *tripDate;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *mapBtn;
- (IBAction)onTapMap:(id)sender;

@end
