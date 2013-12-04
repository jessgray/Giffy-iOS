//
//  NewGifViewController.m
//  Giffy
//
//  Created by Jessica Smith on 12/4/13.
//  Copyright (c) 2013 Jessica Smith. All rights reserved.
//

#import "NewGifViewController.h"

@interface NewGifViewController ()
- (IBAction)addNewGifButton:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *tagTextField;
@property (weak, nonatomic) IBOutlet UITextField *linkTextField;

@end

@implementation NewGifViewController

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    // Close the keyboard
    [textField resignFirstResponder];
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {

    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    
}


- (IBAction)addNewGifButton:(id)sender {
    
    if(self.tagTextField.text.length == 0 || self.linkTextField.text.length == 0) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error" message:@"A tag name and link must be provided" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [message show];
    } else {
        NSDictionary *dictionary = @{@"tag":self.tagTextField.text, @"url":self.linkTextField.text};
        self.completionBlock(dictionary);
    }
}

@end
