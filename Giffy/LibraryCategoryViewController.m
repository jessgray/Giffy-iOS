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
- (IBAction)selectButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *selectButton;

@property (nonatomic, strong) DataSource *dataSource;
@property (nonatomic, strong) MyDataManager *myDataManager;

@property (nonatomic, strong) NSIndexPath *selectedCellIndexPath;

@property BOOL multipleSelectionsAllowed;
@property BOOL copyingGif;

@property (nonatomic, strong) UIBarButtonItem *backButton;

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
    
    // Turn off feature for multiple selection initially - user must press 'select' button to enable
    self.multipleSelectionsAllowed = NO;
    
    // Set title of Navigation controller
    self.navigationItem.title = self.sectionName;
    
    self.copyingGif = NO;
    
    // attach long press gesture to collectionView
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = .2; //seconds
    lpgr.delegate = self;
    [self.collectionView addGestureRecognizer:lpgr];
    
    // Apply margins to the collection view
    UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    collectionViewLayout.sectionInset = UIEdgeInsetsMake(10, 10, 20, 10);
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Only show gifs that are in the specific category that was selected
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
        
        self.copyingGif = YES;
        
        // Show appropriate action sheet to the user
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Copy Gif URL", @"Copy Gif", nil];
        [actionSheet showFromTabBar:self.tabBarController.tabBar];
        
    }
}

#pragma mark - Action Sheets
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(self.copyingGif) {
        
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

    } else {
        // Delete selected cells if delete button was tapped
        if(buttonIndex == 0) {
            [self deleteSelectedCells];
        }
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

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if(self.multipleSelectionsAllowed) {
        return NO;
    } else {
        return YES;
    }
}


#pragma mark - Selecting Gifs
// Remove the overlay on each deselected cell and disable delete button if this is the last cell deselected
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    if(self.multipleSelectionsAllowed) {
        
        // Disable delete button if nothing is selected
        if([[self.collectionView indexPathsForSelectedItems] count] == 0) {
            self.navigationItem.leftBarButtonItem.enabled = NO;
        }
        
        UICollectionViewCell *cell = (UICollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        UIView *overlayView = cell.contentView.subviews.lastObject;
        [overlayView removeFromSuperview];
        
    }
}

// Apply an overlay to visually distinguish selected cells. Enable the delete button so the user can delete all
//  selected cells.
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if(self.multipleSelectionsAllowed) {
        
        // Enable deletions
        self.navigationItem.leftBarButtonItem.enabled = YES;
        
        UICollectionViewCell *cell = (UICollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"SelectionMark" ofType:@"png"];
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
        
        // Add overlay to show the selection happening
        UIImageView *overlayView = [[UIImageView alloc] initWithImage:image];
        overlayView.frame = CGRectMake(overlayView.frame.origin.x, overlayView.frame.origin.y, cell.contentView.frame.size.width, cell.contentView.frame.size.height);
        
        overlayView.contentMode = UIViewContentModeScaleAspectFill;
        
        overlayView.backgroundColor = [[UIColor alloc]initWithWhite:1.0 alpha:0.3];
        [cell.contentView addSubview:overlayView];
        
    }
}


- (IBAction)selectButtonClicked:(id)sender {
    
    if(!self.multipleSelectionsAllowed) {
        // Allow multiple selection
        self.collectionView.allowsMultipleSelection = YES;
        self.multipleSelectionsAllowed = YES;
        
        self.navigationItem.title = @"Select";
        self.selectButton.title = @"Cancel";
        
        // Save add button and add delete button in its place
        self.backButton = [self.navigationItem leftBarButtonItem];
        UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(showDeleteActionSheet)];
        
        // Disable delete button until selections have been made
        self.navigationItem.leftBarButtonItem = deleteButton;
        self.navigationItem.leftBarButtonItem.enabled = NO;
        
    } else {
        
        // Remove any selected items
        for (NSIndexPath *indexPath in [self.collectionView indexPathsForSelectedItems]) {
            UICollectionViewCell *cell = (UICollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            UIView *overlayView = cell.contentView.subviews.lastObject;
            
            [overlayView removeFromSuperview];
            
            [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
        }
        
        // Disallow multiple selection and change titles
        self.collectionView.allowsMultipleSelection = NO;
        self.multipleSelectionsAllowed = NO;
        
        self.navigationItem.title = @"Giffy";
        self.selectButton.title = @"Select";
        
        // Retrieve the add button and replace the delete button
        self.navigationItem.leftBarButtonItem = self.backButton;
    }
}

// Shows the action sheet to confirm the deletion of cells
- (void)showDeleteActionSheet {
    NSUInteger count = [[self.collectionView indexPathsForSelectedItems] count];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:[NSString stringWithFormat:@"Delete %lu gifs", (unsigned long)count] otherButtonTitles: nil];
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

// Deletes cells that were selected by the user
- (void)deleteSelectedCells {
    if(self.multipleSelectionsAllowed) {
        
        // Delete Selected Items
        for (NSIndexPath *indexPath in [self.collectionView indexPathsForSelectedItems]) {
            [self.dataSource deleteRowAtIndexPath:indexPath];
        }
        
        [self.collectionView reloadData];
        
        // Remove any selected items
        for (NSIndexPath *indexPath in [self.collectionView indexPathsForSelectedItems]) {
            UICollectionViewCell *cell = (UICollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            UIView *overlayView = cell.contentView.subviews.lastObject;
            
            [overlayView removeFromSuperview];
            
            [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
        }
        
        // Disallow multiple selection and change titles
        self.collectionView.allowsMultipleSelection = NO;
        self.multipleSelectionsAllowed = NO;
        
        self.navigationItem.title = @"Giffy";
        self.selectButton.title = @"Select";
        
        // Retrieve the add button and replace the delete button
        self.navigationItem.leftBarButtonItem = self.backButton;
    }
}
@end
