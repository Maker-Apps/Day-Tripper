//
//  ImgurDetailViewController.h
//  DayTripper
//
//  Created by Riley Schnee on 8/6/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImgurDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *pictureView;
@property (strong, nonatomic) NSURL *imageURL;
@property (weak, nonatomic) IBOutlet UILabel *posterLabel;
@end
