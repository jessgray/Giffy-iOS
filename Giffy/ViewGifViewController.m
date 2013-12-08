//
//  ViewGifViewController.m
//  Giffy
//
//  Created by Jessica Smith on 12/7/13.
//  Copyright (c) 2013 Jessica Smith. All rights reserved.
//

#import "ViewGifViewController.h"
#import "UIImage+animatedGIF.h"


#define kToolbarHeight 44.0

@interface ViewGifViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation ViewGifViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Get gif and initialize image view with it
    UIImage *animatedGif = [UIImage animatedImageWithAnimatedGIFData:self.gifData];
    _imageView = [[UIImageView alloc] initWithImage:animatedGif];
    
    [self.scrollView addSubview:self.imageView];
    self.scrollView.contentSize = animatedGif.size;
    
    // Allow scroll view to zoom
    self.scrollView.maximumZoomScale = 2.0;
    self.scrollView.minimumZoomScale = self.scrollView.bounds.size.width/animatedGif.size.width;
    self.scrollView.bounces = YES;
    self.scrollView.bouncesZoom = NO;
    
    // Set initial view bounds for image
    self.scrollView.delegate = self;
    [self.scrollView zoomToRect:self.imageView.bounds animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ScrollView Delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

@end
