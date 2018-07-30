//
//  QuizReusableView.h
//  DayTripper
//
//  Created by Riley Schnee on 7/19/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "QuizViewControllerDelegate.h"

#import "QuizReusableViewDelegate.h"
#import "QuizViewController.h"

#import "MPGTextField.h"


//@protocol QuizReusableViewDelegate
//@property (strong, nonatomic) NSString *location;
//@property (nonatomic) double latitude;
//@property (nonatomic) double longitude;
//- (void)dismissKeyboard:(id)sender;
//@end


@interface QuizReusableView : UICollectionReusableView <MKLocalSearchCompleterDelegate, UITextFieldDelegate, QuizViewControllerDelegate, MPGTextFieldDelegate>

@property (strong, nonatomic) MKLocalSearchCompleter *completer;
@property (weak, nonatomic) IBOutlet UITextField *locationField;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) id<QuizReusableViewDelegate> delegate;

@property (strong, nonatomic) NSMutableArray* searchResults;

@property (nonatomic) int lastEditedLocation;
@property (nonatomic) int prevTextFieldLength;

- (void)textFieldDidChange:(UITextField *)textField;

@end
