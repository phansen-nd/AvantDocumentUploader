//
//  ViewController.h
//  Avant Document Uploader
//
//  Created by Patrick on 8/15/15.
//  Copyright (c) 2015 Patrick Hansen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <QuartzCore/QuartzCore.h>
#import "LoginViewController.h"
#import "AddDocumentViewController.h"

@interface UserProfileViewController : UIViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) PFUser *lastUser;
@property (nonatomic, strong) NSMutableArray *userDocs;
@property (nonatomic, strong) UIImageView *fullScreenImageView;
@property (nonatomic, strong) UIScrollView *fullScreenScrollView;
@property CGPoint originalImageCenter;
@property CGFloat longestDistance;
@property CGRect originalImageFrame;
@property CGFloat thumbnailHeight;
@property CGFloat thumbnailWidth;

// IB Outlets
@property (nonatomic, strong) IBOutlet UIButton *uploadButton;
@property (nonatomic, strong) IBOutlet UILabel *customerIDLabel;
@property (nonatomic, strong) IBOutlet UIScrollView *documentScrollView;
@property (nonatomic, strong) IBOutlet UIView *documentsBackgroundView;
@property (nonatomic, strong) IBOutlet UILabel *noDocumentsLabel;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *loadingDocumentsActivityIndicatorView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *switchUserButton;

// IB Actions
- (IBAction)loginButtonTouched:(id)sender;
- (IBAction)unwindToProfile:(UIStoryboardSegue *)unwindSegue;

@end

