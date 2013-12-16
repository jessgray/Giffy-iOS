//
//  HomeCollectionViewController.m
//  Giffy
//
//  Created by Jessica Smith on 12/4/13.
//  Copyright (c) 2013 Jessica Smith. All rights reserved.
//
/*
 This view is the recently added view. From here, the user can see all gifs that have
 been added to giffy, sorted by the date they were added. The user can add a new gif
 to giffy by pressing the '+' button in the upper right hand corner. They can also 
 select multiple gifs to delete by pressing the select button, selecting all gifs
 they want to delete, and then pressing the trash button. A user can copy a specific
 gif's URL or the gif itself by pressing and holding on the gif. Finally, a user can
 view the moving gif by tapping on the gif.
 */

#import "HomeCollectionViewController.h"
#import "DataSource.h"
#import "MyDataManager.h"
#import "DataManager.h"
#import "Gif.h"
#import "NewGifViewController.h"
#import "ViewGifViewController.h"

@interface HomeCollectionViewController ()
- (IBAction)selectButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *selectButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addRemoveButton;


@property (nonatomic, strong) UIBarButtonItem *addButton;
@property (nonatomic, strong) DataSource *dataSource;
@property (nonatomic, strong) MyDataManager *myDataManager;

@property (nonatomic, strong) NSIndexPath *selectedCellIndexPath;
@property BOOL copyingGif;

@property BOOL multipleSelectionsAllowed;

@end

@implementation HomeCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        _myDataManager = [[MyDataManager alloc] init];
        _dataSource = [[DataSource alloc] initForEntity:@"Gif" sortKeys:@[@"date"] predicate:nil sectionNameKeyPath:@"date" dataManagerDelegate:_myDataManager];
        
        _dataSource.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    // Turn off feature for multiple selection initially - user must press 'select' button to enable
    self.multipleSelectionsAllowed = NO;
    
    [self.dataSource update];
    
    self.collectionView.dataSource = self.dataSource;
    self.dataSource.collectionView = self.collectionView;
    
    self.copyingGif = NO;
    
    // attach long press gesture to collectionView
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = .5; //seconds
    lpgr.delegate = self;
    [self.collectionView addGestureRecognizer:lpgr];
    
    // Set margins for collection view
    UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    collectionViewLayout.sectionInset = UIEdgeInsetsMake(10, 10, 20, 10);
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Collection View Data Source
- (NSString *)cellIdentifierForObject:(id)object {
    return @"Cell";
}

- (NSString *)headerIdentifierForObject:(id)object {
    return @"HeaderView";
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

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if(self.multipleSelectionsAllowed) {
        return NO;
    } else {
        return YES;
    }
}

// Remove the overlay on each deselected cell and disable delete button if this is the last cell deselected
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    if(self.multipleSelectionsAllowed) {
        
        // Disable delete button if nothing is selected
        if([[self.collectionView indexPathsForSelectedItems] count] == 0) {
            self.navigationItem.rightBarButtonItem.enabled = NO;
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
        self.navigationItem.rightBarButtonItem.enabled = YES;
        
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
        
        // Present the user with options for doing things to the gif.
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Copy Gif URL", @"Copy Gif", nil];
        [actionSheet showFromTabBar:self.tabBarController.tabBar];
        
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    // Determine which action sheet was presented to the user
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
        
        self.copyingGif = NO;
        
    } else {
        // Delete selected cells if delete button was tapped
        if(buttonIndex == 0) {
            [self deleteSelectedCells];
        }
    }
    
}


#pragma mark - Segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"NewGifSegue"]) {
        NewGifViewController *viewController = segue.destinationViewController;
        
        viewController.completionBlock = ^(id obj) {
            if (obj) {
                NSDictionary *dictionary = obj;
                [self.myDataManager addGif:dictionary];
            }
        };
    } else if([segue.identifier isEqualToString:@"ViewGifSegue"]) {
        ViewGifViewController *viewController = segue.destinationViewController;
        
        // Use dataSource tableview since it will always be the current one
        NSIndexPath *indexPath = [self.dataSource.collectionView indexPathsForSelectedItems][0];
        
        Gif *gif = [self.dataSource objectAtIndexPath:indexPath];
        viewController.gifData = gif.photo;
    }
}

// This method handles the user clicking on the "select" button on the navigation bar, which allows them to
//  select multiple gifs for deleting.
- (IBAction)selectButtonClicked:(id)sender {
    
    if(!self.multipleSelectionsAllowed) {
        // Allow multiple selection
        self.collectionView.allowsMultipleSelection = YES;
        self.multipleSelectionsAllowed = YES;
        
        self.navigationItem.title = @"Select";
        self.selectButton.title = @"Cancel";
        
        // Save add button and add delete button in its place
        self.addButton = self.addRemoveButton;
        UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(showDeleteActionSheet)];
        
        // Disable delete button until selections have been made
        self.navigationItem.rightBarButtonItem = deleteButton;
        self.navigationItem.rightBarButtonItem.enabled = NO;

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
        self.addRemoveButton = self.addButton;
        self.navigationItem.rightBarButtonItem = self.addRemoveButton;
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
        self.addRemoveButton = self.addButton;
        self.navigationItem.rightBarButtonItem = self.addRemoveButton;
    }
}

@end
