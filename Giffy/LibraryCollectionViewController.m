//
//  LibraryCollectionViewController.m
//  Giffy
//
//  Created by Jessica Smith on 12/7/13.
//  Copyright (c) 2013 Jessica Smith. All rights reserved.
//
/*
 This view is the library view. It displays all gifs currently saved to the
 phone, sorted by tags. The user can delete an entire section of gifs by 
 pressing and holding on a section. The user can also see all gifs in that
 section by tapping on the section. 
 */

#import "LibraryCollectionViewController.h"
#import "DataSource.h"
#import "MyDataManager.h"
#import "DataManager.h"
#import "Gif.h"
#import "LibraryCategoryViewController.h"
#import "HomeCollectionHeaderView.h"

@interface LibraryCollectionViewController ()

@property (nonatomic, strong) DataSource *dataSource;
@property (nonatomic, strong) MyDataManager *myDataManager;

@property (nonatomic, strong) NSIndexPath *selectedCellIndexPath;

@end

@implementation LibraryCollectionViewController

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
        _dataSource = [[DataSource alloc] initForEntity:@"Gif" sortKeys:@[@"tag"] predicate:nil sectionNameKeyPath:@"tag" dataManagerDelegate:_myDataManager];
        
        _dataSource.delegate = self;

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.dataSource update];
    
    self.collectionView.dataSource = self.dataSource;
    self.dataSource.collectionView = self.collectionView;
    
    // Set margins for the collection view
    UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    collectionViewLayout.sectionInset = UIEdgeInsetsMake(10, 10, 20, 10);
    collectionViewLayout.minimumInteritemSpacing = 0;
    collectionViewLayout.minimumLineSpacing = 0;
    
    
    // attach long press gesture to collectionView
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = .5; //seconds
    lpgr.delegate = self;
    [self.collectionView addGestureRecognizer:lpgr];
    
    [self.collectionView reloadData];
    
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
    return @"LibraryCell";
}

- (NSString *)headerIdentifierForObject:(id)object {
    return @"LibraryHeaderView";
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
        
        Gif *gif = [self.dataSource objectAtIndexPath:indexPath];
        NSString *sectionTitle = gif.tag;
        
        // Show action sheet to the user for actions they can perform on the gifs
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:[NSString stringWithFormat:@"Delete all gifs in %@", sectionTitle], nil];
        [actionSheet showFromTabBar:self.tabBarController.tabBar];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    // Delete section
    if(buttonIndex == 0) {
        
        NSMutableArray *indexPathArray = [[NSMutableArray alloc] init];
        
        NSInteger section = self.selectedCellIndexPath.section;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
        
        // Create array of index paths
        for(int i=0; i < [self.collectionView numberOfItemsInSection:section]; i++) {
            
            NSIndexPath *newPath = [indexPath indexPathByAddingIndex:i];
            [indexPathArray addObject:newPath];
        }
        
        // Remove all items from data source
        for (NSIndexPath *path in indexPathArray) {
            [self.dataSource deleteRowAtIndexPath:path];
        }
        
        // Remove items from collection view
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:section];
        [self.collectionView deleteSections:indexSet];
    }
}


#pragma mark - Segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"ViewSectionSegue"]) {
        LibraryCategoryViewController *viewController = segue.destinationViewController;
    
        // Use dataSource tableview since it will always be the current one
        NSIndexPath *indexPath = [self.dataSource.collectionView indexPathsForSelectedItems][0];
    
        Gif *gif = [self.dataSource objectAtIndexPath:indexPath];
        viewController.sectionName = gif.tag;
    }
}



@end
