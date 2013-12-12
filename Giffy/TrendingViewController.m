//
//  TrendingViewController.m
//  Giffy
//
//  Created by Jessica Smith on 12/10/13.
//  Copyright (c) 2013 Jessica Smith. All rights reserved.
//

#import "TrendingViewController.h"
#import "TrendingGifModel.h"
#import "Constants.h"
#import "ViewGifViewController.h"
#import "MyDataManager.h"

@interface TrendingViewController ()

@property (nonatomic, strong)TrendingGifModel *model;
@property (nonatomic, strong)UIRefreshControl *refreshControl;
@property (nonatomic, strong) MyDataManager *myDataManager;

@property NSInteger selectedCellIndex;

@end

@implementation TrendingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        
        _myDataManager = [[MyDataManager alloc] init];
        _model = [[TrendingGifModel alloc] init];
        [self.model addObserver:self forKeyPath:@"trendingGifs"
                        options:NSKeyValueObservingOptionNew
                        context:NULL];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gifDataDownloaded) name:GifDataDownloadCompleted object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoDownloaded:) name:GifPhotoDownlodCompleted object:nil];
    
    // attach long press gesture to collectionView
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = .2; //seconds
    lpgr.delegate = self;
    [self.collectionView addGestureRecognizer:lpgr];
    
    // Add margin to collection view
    UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    collectionViewLayout.sectionInset = UIEdgeInsetsMake(10, 10, 20, 10);
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.model count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"TrendingCell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    UIImage *image = [self.model photoForIndex:indexPath.row];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    
    // Resize image to fit in the collection view cell
    imageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, cell.contentView.frame.size.width, cell.contentView.frame.size.height);
    
    // Make image square (cropping some pieces of the image out if necessary)
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [cell.contentView addSubview:imageView];
    
    return cell;
}

- (void)gifDataDownloaded {
    [self.collectionView reloadData];
}

-(void)photoDownloaded:(NSNotification*)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSNumber *rowNumber = [userInfo objectForKey:@"index"];
    NSInteger rowIndex = [rowNumber integerValue];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:0];
    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
}

- (void)refreshCollection {
    [self.model downloadData];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self.collectionView reloadData];
}

#pragma mark - Gestures

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    CGPoint p = [gestureRecognizer locationInView:self.collectionView];
    
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:p];
    if (indexPath == nil){
        NSLog(@"couldn't find index path");
    } else {
        // get the cell at indexPath (the one you long pressed)
        self.selectedCellIndex = indexPath.row;
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Add Gif to Library", nil];
        [actionSheet showFromTabBar:self.tabBarController.tabBar];

    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    // Add gif to library if "Add to library" button was tapped
    if(buttonIndex == 0) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Add Gif" message:@"Provide a tag for the gif:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        
        [alertView show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // User clicked "OK"
    if(buttonIndex == 1) {
        // Get textfield
        UITextField *textField = [alertView textFieldAtIndex:0];
        NSString *tag = [textField.text lowercaseString];
        
        // Create date that has no minutes, hours, or seconds
        NSDate *date = [[NSDate alloc] init];
        unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:flags fromDate:date];
        NSDate *dateOnly = [calendar dateFromComponents:components];
        
        NSString *url = [self.model urlForIndex:self.selectedCellIndex];
        
        NSDictionary *dictionary = @{@"tag":[tag capitalizedString], @"date":dateOnly, @"url":url};
        [self.myDataManager addGif:dictionary];
    }
}

#pragma mark - Segues

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
    NSIndexPath *indexPath = [self.collectionView indexPathsForSelectedItems][0];
    NSData *imageData = [self.model dataForIndex:indexPath.row];
    
    if(imageData != nil) {
        return YES;
    } else {
        return NO;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"ViewTrendingGifSegue"]) {
        
        ViewGifViewController *viewController = segue.destinationViewController;
        NSIndexPath *indexPath = [self.collectionView indexPathsForSelectedItems][0];
        viewController.gifData = [self.model dataForIndex:indexPath.row];
    }
}

@end
