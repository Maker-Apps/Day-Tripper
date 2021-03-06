//
//  DetailsViewController.h
//  DayTripper
//
//  Created by Kimora Kong on 7/18/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Activity.h"
#import "Place.h"
#import "Food.h"
#import "Event.h"
#import "ResultsCell.h"


@interface DetailsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoriesLabel;
@property (strong, nonatomic) id<Activity> activity;
@property (strong, nonatomic) NSString* titleForItin;
@property (nonatomic) BOOL fromMap;
@property (strong, nonatomic) id<ResultsCellDelegate> delegate;
@property (nonatomic) BOOL allowAddToTrip;


@end
