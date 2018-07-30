//
//  TripReusableView.h
//  DayTripper
//
//  Created by Riley Schnee on 7/20/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Trip.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@protocol TripReusableViewDelegate
- (void)reloadAttendeeData;
- (void)showAlert:(UIAlertController *)alert;
@end


@interface TripReusableView : UICollectionReusableView 
@property (weak, nonatomic) IBOutlet UIButton *googlePhotosButton;
@property (strong, nonatomic) Trip *trip;
@property (weak, nonatomic) IBOutlet UIView *weatherView;
@property (weak, nonatomic) IBOutlet UILabel *tripNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tripCityLabel;
@property (weak, nonatomic) IBOutlet UILabel *tripDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *highLabel;
@property (weak, nonatomic) IBOutlet UITextField *usernameToAdd;
@property (weak, nonatomic) IBOutlet UILabel *lowLabel;
//description of the weather
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (strong, nonatomic) id<TripReusableViewDelegate> delegate;
@end
