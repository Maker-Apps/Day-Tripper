//
//  ProfileViewController.h
//  DayTripper
//
//  Created by Riley Schnee on 7/24/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "Trip.h"

@interface ProfileViewController : UIViewController
@property (strong, nonatomic) PFUser *user;
@property (strong, nonatomic) Trip *trip;

@end
