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

@interface TrendingViewController ()

@property (nonatomic, strong)TrendingGifModel *model;
@property (nonatomic, strong)UIRefreshControl *refreshControl;

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
    
    [self.collectionView reloadData];
    
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
