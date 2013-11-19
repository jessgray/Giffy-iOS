//
//  JGSViewController.m
//  Giffy
//
//  Created by Jessica Smith on 11/14/13.
//  Copyright (c) 2013 Jessica Smith. All rights reserved.
//

#import "JGSViewController.h"

@interface JGSViewController ()
- (IBAction)showHomeMenu:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *homeMenuButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addGifButton;
@property (weak, nonatomic) IBOutlet UITableView *menuView;


@end

@implementation JGSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.menuView.hidden = YES;
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showHomeMenu:(id)sender {
    /*UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Library", @"Trending Gifs", @"Logout", nil];
    [actionSheet showFromBarButtonItem:self.addGifButton animated:YES];*/
    
    //self.menuView.hidden = NO;
}
@end
