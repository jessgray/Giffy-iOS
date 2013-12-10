//
//  HomeCollectionViewController.m
//  Giffy
//
//  Created by Jessica Smith on 12/4/13.
//  Copyright (c) 2013 Jessica Smith. All rights reserved.
//

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
- (IBAction)addRemoveButtonClicked:(id)sender;


@property (nonatomic, strong) UIBarButtonItem *addButton;
@property (nonatomic, strong) DataSource *dataSource;
@property (nonatomic, strong) MyDataManager *myDataManager;
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
    
    self.multipleSelectionsAllowed = NO;
    
    self.collectionView.dataSource = self.dataSource;
    self.dataSource.collectionView = self.collectionView;
    
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



- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    if(self.multipleSelectionsAllowed) {
        
        UICollectionViewCell *cell = (UICollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        UIView *overlayView = cell.contentView.subviews.lastObject;
        [overlayView removeFromSuperview];
        
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if(self.multipleSelectionsAllowed) {
        
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

- (IBAction)selectButtonClicked:(id)sender {
    
    if(!self.multipleSelectionsAllowed) {
        // Allow multiple selection
        self.collectionView.allowsMultipleSelection = YES;
        self.multipleSelectionsAllowed = YES;
        
        self.navigationItem.title = @"Select";
        self.selectButton.title = @"Cancel";
        
        // Save add button and add delete button in its place
        self.addButton = self.addRemoveButton;
        UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteSelectedCells)];
        
        self.navigationItem.rightBarButtonItem = deleteButton;

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

- (void)deleteSelectedCells {
    if(self.multipleSelectionsAllowed) {
        
        // Delete Selected Items
        for (NSIndexPath *indexPath in [self.collectionView indexPathsForSelectedItems]) {
            [self.dataSource deleteRowAtIndexPath:indexPath];
        }
        
        [self.collectionView reloadData];
    }
}

- (IBAction)addRemoveButtonClicked:(id)sender {
    
    if(self.multipleSelectionsAllowed) {
        
        // Delete Selected Items
        [self.collectionView deleteItemsAtIndexPaths:[self.collectionView indexPathsForSelectedItems]];
    }
    
}
@end
