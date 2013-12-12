//
//  LibraryCategoryViewController.m
//  Giffy
//
//  Created by Jessica Smith on 12/9/13.
//  Copyright (c) 2013 Jessica Smith. All rights reserved.
//

#import "LibraryCategoryViewController.h"
#import "DataSource.h"
#import "MyDataManager.h"
#import "DataManager.h"
#import "Gif.h"
#import "ViewGifViewController.h"

@interface LibraryCategoryViewController ()

@property (nonatomic, strong) DataSource *dataSource;
@property (nonatomic, strong) MyDataManager *myDataManager;

@property (nonatomic, strong) NSIndexPath *selectedCellIndexPath;

@end

@implementation LibraryCategoryViewController

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
        _dataSource = [[DataSource alloc] initForEntity:@"Gif" sortKeys:@[@"tag"] predicate:nil sectionNameKeyPath:@"tag" dataManagerDelegate:_myDataManager];
        
        _dataSource.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    self.collectionView.dataSource = self.dataSource;
    self.dataSource.collectionView = self.collectionView;
    
    // Set title of Navigation controller
    self.navigationItem.title = self.sectionName;
    
    // attach long press gesture to collectionView
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = .2; //seconds
    lpgr.delegate = self;
    [self.collectionView addGestureRecognizer:lpgr];
    
    UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    collectionViewLayout.sectionInset = UIEdgeInsetsMake(10, 10, 20, 10);
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    NSString *searchPredicateString = [NSString stringWithFormat:@"tag contains '%@'", self.sectionName];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:searchPredicateString];
    [self.dataSource updateWithPredicate:predicate];
    
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Collection View Data Source
- (NSString *)cellIdentifierForObject:(id)object {
    return @"LibraryCategoryCell";
}

- (NSString *)headerIdentifierForObject:(id)object {
    return nil;
}


- (void)configureCell:(UICollectionViewCell*)cell withObject:(id)object {
    Gif *gif = object;
    
    UIImage *image = [[UIImage alloc] initWithData:gif.photo];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    
    // Resize image to fit in the collection view cell
    imageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, cell.contentView.frame.size.width, cell.contentView.frame.size.height);
    
    // Make image square (cropping some pieces of the image out if necessary)
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [cell.contentView addSubview:imageView];
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
        self.selectedCellIndexPath = indexPath;
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Copy Gif URL", @"Copy Gif", nil];
        [actionSheet showFromTabBar:self.tabBarController.tabBar];
        
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    Gif *gif = [self.dataSource objectAtIndexPath:self.selectedCellIndexPath];
    
    // Copy gif link if "Copy Gif URL" button was tapped
    if(buttonIndex == 0) {
        
        UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
        pasteBoard.string = gif.url;
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Copied Gif URL" message:@"The gif's URL was copied to the clipboard!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        
    } else if(buttonIndex == 1) { // Copy gif for pasting directly into iMessage
        UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
        NSData *data = gif.photo;
        [pasteBoard setData:data forPasteboardType:@"com.compuserve.gif"];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Copied Gif" message:@"The gif was copied to the clipboard for use in iMessage" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
}


#pragma mark - Segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"ViewCategoryGifSegue"]) {
        ViewGifViewController *viewController = segue.destinationViewController;
        
        // Use dataSource tableview since it will always be the current one
        NSIndexPath *indexPath = [self.dataSource.collectionView indexPathsForSelectedItems][0];
        
        Gif *gif = [self.dataSource objectAtIndexPath:indexPath];
        viewController.gifData = gif.photo;
    }
}

@end
