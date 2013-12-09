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

@interface LibraryCategoryViewController ()

@property (nonatomic, strong) DataSource *dataSource;
@property (nonatomic, strong) MyDataManager *myDataManager;

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

@end
