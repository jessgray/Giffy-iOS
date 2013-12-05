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

@interface HomeCollectionViewController ()

@property (nonatomic, strong) DataSource *dataSource;
@property (nonatomic, strong) MyDataManager *myDataManager;

@end

@implementation HomeCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _myDataManager = [[MyDataManager alloc] init];
        _dataSource = [[DataSource alloc] initForEntity:@"Gif" sortKeys:@[@"tag"] predicate:nil sectionNameKeyPath:nil dataManagerDelegate:_myDataManager];
        
        _dataSource.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
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
    [cell.contentView addSubview:[[UIImageView alloc] initWithImage:image]];
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
