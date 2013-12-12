//
//  LibraryCollectionViewController.m
//  Giffy
//
//  Created by Jessica Smith on 12/7/13.
//  Copyright (c) 2013 Jessica Smith. All rights reserved.
//

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
    
    UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    collectionViewLayout.sectionInset = UIEdgeInsetsMake(10, 10, 20, 10);
    collectionViewLayout.minimumInteritemSpacing = 0;
    
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
