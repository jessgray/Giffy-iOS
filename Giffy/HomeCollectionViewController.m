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
#import "HomeCollectionHeaderView.h"

@interface HomeCollectionViewController ()

@property (nonatomic, strong) DataSource *dataSource;
@property (nonatomic, strong) MyDataManager *myDataManager;

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
    
    if([segue.identifier isEqualToString:@"NewGifSegue"]) {
        NewGifViewController *viewController = segue.destinationViewController;
        
        viewController.completionBlock = ^(id obj) {
            if (obj) {
                NSDictionary *dictionary = obj;
                [self.myDataManager addGif:dictionary];
            }
        };
    }
}

@end
