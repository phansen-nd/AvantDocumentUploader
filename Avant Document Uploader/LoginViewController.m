//
//  LoginViewController.m
//  Avant Document Uploader
//
//  Created by Patrick on 8/16/15.
//  Copyright (c) 2015 Patrick Hansen. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

// IB Outlets
@synthesize usernameTextField;
@synthesize passwordTextField;
@synthesize loginButton;
@synthesize loginActivityIndicatorView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Make some initial UI adjustments
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
    loginButton.layer.cornerRadius = 5.0f;
    loginButton.clipsToBounds = YES;
    usernameTextField.layer.cornerRadius = 5.0f;
    usernameTextField.delegate = self;
    usernameTextField.clipsToBounds = YES;
    passwordTextField.layer.cornerRadius = 5.0f;
    passwordTextField.delegate = self;
    passwordTextField.clipsToBounds = YES;
    
}

// Leave the login if user cancels
- (IBAction)cancelButtonTouched:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)loginButtonTouched:(id)sender {

    // If there's no username, discontinue
    if (usernameTextField.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Please enter a username!"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
    // Likewise, if there's no password or it's too short, discontinue
    } else if (passwordTextField.text.length < 6) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Please enter a password that is at least 6 characters long!"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    
    // If the fields are validated (to this minor degree), try signing the user up
    } else {
        
        // Let the user know we're thinking
        [loginActivityIndicatorView startAnimating];
        
        // Create a new user and try signing up
        PFUser *newUser = [PFUser user];
        newUser.username = usernameTextField.text;
        newUser.password = passwordTextField.text;
        [newUser signUpInBackgroundWithBlock: ^(BOOL succeeded, NSError *error) {
            
            // Success means the user is new, post an informative message and exit the login controller
            if (succeeded) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                                message:@"You are now signed up and logged in! You are now able to upload documents."
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                [self dismissViewControllerAnimated:YES completion:nil];
            } else {
                
                // If it didn't succeed because the username was taken, check to see if the password entered
                // matches an existing account (regular login)
                if ([error code] == kPFErrorUsernameTaken) {
                    [PFUser logInWithUsernameInBackground:usernameTextField.text password:passwordTextField.text block:^(PFUser *user, NSError *error) {
                        if (!error) {
                            
                            // Successfull login, exit the login controller
                            [self dismissViewControllerAnimated:YES completion:nil];
                        } else {
                            // If the username matched, but the password was wrong, the user typed an incorrect password
                            NSString *errorString = [NSString stringWithFormat:@"Login unsuccessful: %@", [error localizedDescription]];
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                            message:errorString
                                                                           delegate:self
                                                                  cancelButtonTitle:@"OK"
                                                                  otherButtonTitles:nil];
                            [alert show];
                        }
                    }];
                } else {
                    NSLog(@"Error: %@", [error localizedDescription]);
                }
            }
            // Finished thinking!
            [loginActivityIndicatorView stopAnimating];
        }];
        
    }
    
}

#pragma mark - Text Field Delegate methods

// If user taps "return" from user name, move to password
// If user taps "done" from password, hide the keyboard
- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag == 0) {
        [usernameTextField resignFirstResponder];
        [passwordTextField becomeFirstResponder];
    } else if (textField.tag == 1) {
        [textField resignFirstResponder];
    }
    
    return YES;
}

@end
