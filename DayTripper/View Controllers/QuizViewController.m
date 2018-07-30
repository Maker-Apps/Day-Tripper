//
//  QuizViewController.m
//  DayTripper
//
//  Created by Riley Schnee on 7/13/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "QuizViewController.h"
#import "ResultsViewController.h"
#import <MapKit/MapKit.h>
#import "Constants.h"
#import <TTGTagCollectionView/TTGTextTagCollectionView.h>

@interface QuizViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *allCategories;
@property (strong, nonatomic) Constants *cats;
@property (strong, nonatomic) NSMutableArray *chosenPlaceCategories;
@property (strong, nonatomic) NSMutableArray *chosenFoodCategories;
@property (strong, nonatomic) NSMutableArray *chosenEventCategories;
@property (strong, nonatomic) NSMutableArray *chosenCategories;
@property (strong, nonatomic) UICollectionViewFlowLayout *layout;
@property (strong, nonatomic) TTGTextTagCollectionView *tagCollectionView;
@end

@implementation QuizViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.location = @"";
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    // Setting up TextTagCollection of categories
    self.tagCollectionView = [[TTGTextTagCollectionView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height / 2, self.view.frame.size.width, self.view.frame.size.height / 2)];
    [self.view addSubview:self.tagCollectionView];
    TTGTextTagConfig *config = self.tagCollectionView.defaultConfig;
    config.tagTextColor = [UIColor whiteColor];
    config.tagBackgroundColor = [UIColor colorWithRed:0.36 green:0.56 blue:0.76 alpha:1.0];
    config.tagSelectedBackgroundColor = [UIColor colorWithRed:0.94 green:0.40 blue:0.23 alpha:1.0];
    self.tagCollectionView.alignment = TTGTagCollectionAlignmentFillByExpandingWidth;
    
    
    self.latitude = 0;
    self.longitude = 0;
        
    self.cats = [[Constants alloc] init];
    [self.cats setCategories];
    self.chosenCategories = [[NSMutableArray alloc] init];
    self.chosenPlaceCategories = [[NSMutableArray alloc] init];
    self.chosenFoodCategories = [[NSMutableArray alloc] init];
    self.chosenEventCategories = [[NSMutableArray alloc] init];
    NSMutableDictionary *temp = [[NSMutableDictionary alloc] init];
    [temp addEntriesFromDictionary:self.cats.placeCategories];
    [temp addEntriesFromDictionary:self.cats.foodCategories];
    [temp addEntriesFromDictionary:self.cats.eventCategories];
    self.allCategories = [[temp allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
//    self.allCategories = [self.cats.placeCategories allKeys];
//    self.allCategories = [self.allCategories arrayByAddingObjectsFromArray:[self.cats.foodCategories allKeys]];
//    self.allCategories = [self.allCategories arrayByAddingObjectsFromArray:[self.cats.eventCategories allKeys]];
    [self.tagCollectionView addTags:self.allCategories];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([self.location isEqualToString:@""] ||[self doublesAreEqual:self.latitude isEqualTo:(double) 0.0]){
        [self alertNoLocation];
    } else {
        ResultsViewController *resultsViewController = [segue destinationViewController];
        resultsViewController.location = self.location;
        resultsViewController.latitude = self.latitude;
        resultsViewController.longitude = self.longitude;
        [self processCategories];
        resultsViewController.placeCategories = self.chosenPlaceCategories;
        resultsViewController.foodCategories = self.chosenFoodCategories;
        resultsViewController.eventCategories = self.chosenEventCategories;
        resultsViewController.tripDate = self.tripDate;
    }
}


- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    CategoryCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CategoryCollectionCell" forIndexPath:indexPath];
    cell.categoryLabel.text = self.allCategories[indexPath.item];
    [cell setSelected:[self isCategoryInArray:cell.categoryLabel.text]];
    self.catDelegate = cell;
    [self.catDelegate toggleWordColor];
    //NSLog(@"%@", cell.categoryLabel.text);
    
    CGSize textSize = [cell.categoryLabel.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17.0f]}];
    [cell.categoryLabel sizeThatFits:textSize];
        //get the width and height of the label (CGSize contains two parameters: width and height)
    CGSize labelSize = cell.categoryLabel.frame.size;
    //self.layout.itemSize = labelSize;
    //cell.frame.size = labelSize;
    //NSLog(@"\n width  = %f height = %f", labelSize.width,labelSize.height);
    
    CGRect temp = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, labelSize.width, 150);
    cell.frame = temp;
    cell.delegate = self;
    if([self.cats.placeCategories objectForKey:cell.categoryLabel.text] != nil){
        cell.categoryAlias = [self.cats.placeCategories objectForKey:cell.categoryLabel.text];
    } else if([self.cats.foodCategories objectForKey:cell.categoryLabel.text] != nil){
        cell.categoryAlias = [self.cats.foodCategories objectForKey:cell.categoryLabel.text];
    } else if([self.cats.eventCategories objectForKey:cell.categoryLabel.text] != nil){
        cell.categoryAlias = [self.cats.eventCategories objectForKey:cell.categoryLabel.text];
    }
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:cell action:@selector(toggleCatStatus:)];
    [cell addGestureRecognizer:tap];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 0;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    QuizReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"QuizReusableView" forIndexPath:indexPath];
    [header.locationField setDelegate:header];
    self.delegate = header;
    header.delegate = self;
    [header.locationField addTarget:header action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

    return header;
}

- (void)processCategories{
    
    //TTGTextTagCollecitonViewProcessing
    for(NSString * key in [self.tagCollectionView allSelectedTags]){
        if([self.cats.placeCategories objectForKey:key] != nil){
            [self.chosenPlaceCategories addObject:[self.cats.placeCategories objectForKey:key]];
        } else if([self.cats.foodCategories objectForKey:key] != nil){
            [self.chosenFoodCategories addObject:[self.cats.foodCategories objectForKey:key]];
        } else if([self.cats.eventCategories objectForKey:key] != nil){
            [self.chosenEventCategories addObject:[self.cats.eventCategories objectForKey:key]];
        }
    }
    
    
    
    // FOR USING NORMAL COLLECTION VIEW
    /*
    for(NSString *key in self.chosenCategories){
        if([self.cats.placeCategories objectForKey:key] != nil){
            [self.chosenPlaceCategories addObject:[self.cats.placeCategories objectForKey:key]];
        } else if([self.cats.foodCategories objectForKey:key] != nil){
            [self.chosenFoodCategories addObject:[self.cats.foodCategories objectForKey:key]];
        } else if([self.cats.eventCategories objectForKey:key] != nil){
            [self.chosenEventCategories addObject:[self.cats.eventCategories objectForKey:key]];
        }
    }
     */
    
}


//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
//
//    return [(NSString*)[self.allCategories objectAtIndex:indexPath.item] sizeWithAttributes:NULL];
//}

- (void)addCategoryToArray:(NSString *)cat {
    NSLog(@"Added %@ to chosenCategories", cat);
    [self.chosenCategories addObject:cat];
    NSLog(@"%@", self.chosenCategories);
}

- (BOOL)isCategoryInArray:(NSString *)cat {
    return [self.chosenCategories containsObject:cat];
}

- (void)removeCategoryFromArray:(NSString *)cat {
    NSLog(@"Removed %@ from chosenCategories", cat);
    [self.chosenCategories removeObject:cat];
}

- (BOOL)doublesAreEqual:(double)first isEqualTo:(double)second {
    if(fabs(first - second) < DBL_EPSILON)
        return YES;
    else
        return NO;
}


- (void)alertNoLocation{
    UIAlertController *noLocaAlert = [UIAlertController alertControllerWithTitle:@"No Valid Location" message:@"You must enter a valid location" preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { // handle response here.
    }];
    // add the OK action to the alert controller
    [noLocaAlert addAction:okAction];
    [self presentViewController:noLocaAlert animated:YES completion:nil];
}


@end
