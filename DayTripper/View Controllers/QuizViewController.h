//
//  QuizViewController.h
//  DayTripper
//
//  Created by Riley Schnee on 7/13/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuizViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *locationField;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

@end
