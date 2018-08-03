//
//  Functions.m
//  DayTripper
//
//  Created by Michael Abelar on 7/16/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "Functions.h"
#import "Activity.h"

@implementation Functions

// common functions that will be needed


+ (NSArray*) getCellsFromTable:(UITableView*)tableView {
    NSMutableArray *cells = [[NSMutableArray alloc] init];
    for (NSInteger j = 0; j < [tableView numberOfSections]; ++j)
    {
        for (NSInteger i = 0; i < [tableView numberOfRowsInSection:j]; ++i)
        {
            [cells addObject:[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]]];
        }
    }
    return [cells copy];
}

- (double) distanceBetweenTwoPlaces:(Place*)place1 place2:(Place*)place2 {
    CLLocation *startLocation = [[CLLocation alloc] initWithLatitude:place1.latitude longitude:place1.longitude];
    CLLocation *endLocation = [[CLLocation alloc] initWithLatitude:place2.latitude longitude:place2.longitude];
    return [startLocation distanceFromLocation:endLocation];
}

+ (NSString *)primaryActivityCategory:(id<Activity>)activity{
    if(activity.categories.count == 0){
        return @"";
    } else if([[activity activityType] isEqualToString:@"Place"]){\
        return [[activity.categories[0][@"name"] stringByReplacingOccurrencesOfString:@"-" withString:@" "] capitalizedString];
    } else if([[activity activityType] isEqualToString:@"Food"]){
        return [[activity.categories[0][@"title"] stringByReplacingOccurrencesOfString:@"-" withString:@" "] capitalizedString];
    } else if ([[activity activityType] isEqualToString:@"Event"]){
        return [[activity.categories[0] stringByReplacingOccurrencesOfString:@"-" withString:@" "] capitalizedString];
    } else {
        return @"NO CATEGORY";
    }
}

+ (void)fetchUserIOUs:(PFUser *)user withCompletion:(void (^)(NSArray *ious))completionHandler {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"payee == %@ OR payer == %@", PFUser.currentUser, PFUser.currentUser];
        PFQuery *query = [PFQuery queryWithClassName:@"IOU" predicate:pred];
        [query includeKeys:@[@"payer", @"payee", @"description", @"amount", @"completed"]];
        [query orderByAscending:@"completed"];
        //query.limit = 20;
        [query findObjectsInBackgroundWithBlock:^(NSArray *ious, NSError *error) {
            if (ious != nil){
                NSLog(@"FUNCTIONS %@", ious);
                completionHandler(ious);
            } else {
                NSLog(@"%@", error.localizedDescription);
                NSLog(@"Error fetching ious");
                //return [NSMutableArray new];
            }
        }];
}

@end
