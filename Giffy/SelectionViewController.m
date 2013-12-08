//
//  SelectionViewController.m
//  Giffy
//
//  Created by Jessica Smith on 12/6/13.
//  Copyright (c) 2013 Jessica Smith. All rights reserved.
//

#import "SelectionViewController.h"

@interface SelectionViewController ()

@end

@implementation SelectionViewController

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
    
    SelectionViewController *myController = [[SelectionViewController alloc] init];
    myController.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:myController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
