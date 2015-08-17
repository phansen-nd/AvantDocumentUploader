//
//  LoginViewController.h
//  Avant Document Uploader
//
//  Created by Patrick on 8/16/15.
//  Copyright (c) 2015 Patrick Hansen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface LoginViewController : UIViewController <UITextFieldDelegate>

// IB Outlets
@property (nonatomic, strong) IBOutlet UITextField *usernameTextField;
@property (nonatomic, strong) IBOutlet UITextField *passwordTextField;
@property (nonatomic, strong) IBOutlet UIButton *loginButton;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *loginActivityIndicatorView;

// IB Actions
- (IBAction)cancelButtonTouched:(id)sender;
- (IBAction)loginButtonTouched:(id)sender;

@end
