//
//  LoginViewController.m
//  beam
//
//  Created by Raj Vir on 5/23/13.
//  Copyright (c) 2013 Raj Vir. All rights reserved.
//

#import "LoginViewController.h"
#import <Firebase/Firebase.h>
#import <FirebaseAuthClient/FirebaseAuthClient.h>

@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)LoginButtonPressed:(id)sender {
    //self.username;
    //self.password;
    Firebase* ref = [[Firebase alloc] initWithUrl:@"https://rjvir.firebaseio.com"];
    FirebaseAuthClient* authClient = [[FirebaseAuthClient alloc] initWithRef:ref];
    [authClient createUserWithEmail:@"rjvir" password:@"password" andCompletionBlock:^(NSError* error, FAUser* user) {
         if (error != nil) {
             NSLog(@"error: %@", error);
             // There was an error creating the account
         } else {
             NSLog(@"yo");
             // We created a new user account
         }
     }];
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

@end
