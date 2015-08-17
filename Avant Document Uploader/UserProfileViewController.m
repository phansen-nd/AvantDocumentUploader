//
//  ViewController.m
//  Avant Document Uploader
//
//  Created by Patrick on 8/15/15.
//  Copyright (c) 2015 Patrick Hansen. All rights reserved.
//

#import "UserProfileViewController.h"

#define PADDING_TOP 0
#define PADDING 5

@interface UserProfileViewController ()

@end

@implementation UserProfileViewController

@synthesize thumbnailHeight;
@synthesize thumbnailWidth;
@synthesize lastUser;
@synthesize userDocs;
@synthesize fullScreenImageView;
@synthesize fullScreenScrollView;
@synthesize originalImageCenter;
@synthesize longestDistance;
@synthesize originalImageFrame;

// Synthesize IB Outlets
@synthesize uploadButton;
@synthesize customerIDLabel;
@synthesize documentScrollView;
@synthesize documentsBackgroundView;
@synthesize noDocumentsLabel;
@synthesize loadingDocumentsActivityIndicatorView;
@synthesize switchUserButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Make some initial UI adjustments
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
    uploadButton.layer.cornerRadius = 5.0f;
    uploadButton.clipsToBounds = YES;
    documentsBackgroundView.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.5];
    
    // Get the initial images for the logged in user
    if ([PFUser currentUser]) {
        [self initialRetrieveUserDocs];
        lastUser = [PFUser currentUser];
        customerIDLabel.text = [[PFUser currentUser] objectForKey:@"username"];
    }
    
    // Init User Docs array
    userDocs = [[NSMutableArray alloc] init];
}

- (void)viewDidLayoutSubviews {
    // Calculate doc thumbnail height and width
    thumbnailHeight = documentScrollView.frame.size.height;
    thumbnailWidth = 0.618*thumbnailHeight;
}

// Wait until now to auto-launch the login/sign-up controller to make sure the
// navigation stack is all set up
- (void)viewDidAppear:(BOOL)animated {
    [self performSelector:@selector(checkForUser:) withObject:nil afterDelay:0.5];
}

- (void)viewWillAppear:(BOOL)animated {
    
    if (![PFUser currentUser]) {
        return;
    } else if ([PFUser currentUser] != lastUser) {
        // The user has switched, unload all of the Document thumbnails,
        // reload the correct ones, set the customer ID label,
        // and set the lastUser to the new user
        lastUser = [PFUser currentUser];
        customerIDLabel.text = [[PFUser currentUser] objectForKey:@"username"];
        [self unloadUserDocs];
        [self initialRetrieveUserDocs];
    }
    
}

#pragma mark - Scroll View delegate methods
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return fullScreenImageView;
}

#pragma mark - Helper methods

// Uses a PFQuery to fetch all documents associated with the current user
- (void)initialRetrieveUserDocs {    
    [loadingDocumentsActivityIndicatorView startAnimating];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Document"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];

    // Include the image in the data grab so we don't have to load it separately
    [query includeKey:@"imagePointer"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *documents, NSError *error) {
        if (!error) {
            
            // Display a notice if there aren't any documents
            // so there isn't just a big gray, empty space
            if ([documents count] == 0) {
                noDocumentsLabel.hidden = NO;
            } else {
                noDocumentsLabel.hidden = YES;
            }
            
            // Set userDocs so we have the documents stored in the class
            userDocs = [NSMutableArray arrayWithArray:documents];
            
            // Start an asynchronous thread for big data downloads
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                NSMutableArray *imageDataArray = [[NSMutableArray alloc] init];
                
                // Store image data in array for easy access later on the main thread
                for (PFObject *doc in documents) {
                    PFObject *imageObject = [doc objectForKey:@"imagePointer"];
                    PFFile *imageFile = [imageObject objectForKey:@"imageFile"];
                    NSData *imageData = [imageFile getData];
                    UIImage *image = [UIImage imageWithData:imageData];
                    [imageDataArray addObject:image];
                }
                
                // Go to main thread to update the UI
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    // Create the buttons necessary for each image in the sideways-scrolling table
                    for (int i = 0; i < [documents count]; i++) {
                        PFObject *doc = [documents objectAtIndex:i];
                        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                        button.imageView.contentMode = UIViewContentModeScaleAspectFill;
                        button.showsTouchWhenHighlighted = YES;
                        [button setImage:[imageDataArray objectAtIndex:i] forState:UIControlStateNormal];
                        button.tag = i;
                        button.frame = CGRectMake(thumbnailWidth * (i) + PADDING * (i) + PADDING, PADDING_TOP, thumbnailWidth, thumbnailHeight);
                        
                        // Set an action for if the button is clicked
                        [button addTarget:self action:@selector(pictureButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                        
                        // Create a Title UIView
                        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(-2, 0, button.frame.size.width + 4, 30)];
                        [titleLabel setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.7]];
                        [titleLabel setTextColor:[UIColor whiteColor]];
                        [titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:20.0f]];
                        [titleLabel setTextAlignment:NSTextAlignmentCenter];
                        [titleLabel setText:[doc objectForKey:@"title"]];
                        [button addSubview:titleLabel];
                        
                        // Add the button to the scroll view
                        [documentScrollView addSubview:button];
                    }
                    
                    [loadingDocumentsActivityIndicatorView stopAnimating];
                    
                    int count = (int)[documents count] - 1;
                    
                    // Size the scroll view for all the buttons plus some padding
                    documentScrollView.contentSize = CGSizeMake((count + 1)*thumbnailWidth + (count + 1)*PADDING + PADDING, thumbnailWidth + PADDING_TOP);
                    documentScrollView.clipsToBounds = YES;
                });
            });
        } else {
            NSString *errorString = [NSString stringWithFormat:@"Error loading Documents. %@", [error localizedDescription]];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:errorString
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }];
}

- (void)pictureButtonPressed:(UIButton *)button {
    
    // Set up image view with initial frame where the button is (really cool frame)
    UIImage *image = [button currentImage];
    fullScreenImageView = [[UIImageView alloc] initWithFrame:CGRectMake([documentScrollView convertRect:button.frame toView:self.view].origin.x, documentsBackgroundView.frame.origin.y + button.frame.origin.y, button.frame.size.width, button.frame.size.height)];
    [fullScreenImageView setContentMode:UIViewContentModeScaleAspectFit];
    [fullScreenImageView setImage:image];
    [fullScreenImageView setClipsToBounds:YES];
    
    // Enable user interaction so we can gestures
    [fullScreenImageView setUserInteractionEnabled:YES];
    
    // Save original image frame
    originalImageFrame = CGRectMake([documentScrollView convertRect:button.frame toView:self.view].origin.x, documentsBackgroundView.frame.origin.y + button.frame.origin.y, button.frame.size.width, button.frame.size.height);
    
    // Set up scroll view
    fullScreenScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 50, self.view.frame.size.width, self.view.frame.size.height)];
    [fullScreenScrollView setScrollEnabled:YES];
    [fullScreenScrollView setBackgroundColor:[UIColor blackColor]];
    [fullScreenScrollView setAlpha:0.0];
    [fullScreenScrollView setContentSize:CGSizeMake(fullScreenImageView.frame.size.width, fullScreenImageView.frame.size.height)];
    fullScreenScrollView.minimumZoomScale = 1.0;
    fullScreenScrollView.maximumZoomScale = 4.0;
    [fullScreenScrollView setZoomScale:fullScreenScrollView.minimumZoomScale];
    [fullScreenScrollView setShowsHorizontalScrollIndicator:NO];
    [fullScreenScrollView setShowsVerticalScrollIndicator:NO];
    [fullScreenScrollView setDelegate:self];

    // Add new scroll view to view
    [self.view addSubview:fullScreenScrollView];
    [self.view bringSubviewToFront:fullScreenScrollView];

    // Add image view to scroll view so we actually see it
    [fullScreenScrollView addSubview:fullScreenImageView];
    
    // Animate the image growing from it's original button positon to take up the whole screen (with aspect fit)
    // Also animate turning the background black
    [UIView animateWithDuration:0.3 animations:^(void) {
        fullScreenImageView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + 50, self.view.frame.size.width, self.view.frame.size.height - 100);
        fullScreenScrollView.alpha = 1.0;
    }];
    
    // Get the image view center and longest distance before it can start changing... distance formula!!
    originalImageCenter = fullScreenImageView.center;
    longestDistance = powf((powf(self.view.frame.origin.x - originalImageCenter.x, 2.0) + powf(self.view.frame.origin.y - originalImageCenter.y, 2.0)), 0.5);
    
    // Set the view title and hide the button!
    self.title = [[userDocs objectAtIndex:button.tag] objectForKey:@"title"];
    [switchUserButton setEnabled:NO];
    [switchUserButton setTintColor:[UIColor clearColor]];
    
    [self setUpImageGestures];
}

- (void)setUpImageGestures {
    // Make a way to scroll the full screen image away
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAway:)];
    [panRecognizer setDelegate:self];
    [fullScreenImageView addGestureRecognizer:panRecognizer];
    
    // Enable zoom by double tapping
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapZoom:)];
    [tapRecognizer setNumberOfTapsRequired:2];
    [tapRecognizer setDelegate:self];
    [fullScreenImageView addGestureRecognizer:tapRecognizer];
}

- (void)panAway:(UIPanGestureRecognizer *)recognizer {
    
    // Reset to no zoom if it's close enough
    if (fullScreenScrollView.zoomScale < 1.2) {
        fullScreenScrollView.zoomScale = 1.0;
    }
    
    // If we're all zoomed out, let the image follow the user's finger around.
    // Animate so the darkness fades away the farther the user moves the picture away from the center
    // If they let go more than 100 pixels from the center, send the image away.
    // Otherwise, return it to center
    if (fullScreenScrollView.zoomScale == 1.0) {
        
        CGPoint translatedPoint = [recognizer translationInView:self.view];
        CGFloat distanceFromCenter = powf((powf(fullScreenImageView.center.x - originalImageCenter.x, 2.0) + powf(fullScreenImageView.center.y - originalImageCenter.y, 2.0)), 0.5);
        
        if ([recognizer state] == UIGestureRecognizerStateChanged) {
            
            // Follow the touch
            CGPoint newCenter = CGPointMake(fullScreenImageView.center.x + translatedPoint.x, fullScreenImageView.center.y + translatedPoint.y);
            fullScreenImageView.center = newCenter;
            
            // Reset the velocity to 0
            [recognizer setTranslation:CGPointZero inView:self.view];
            
            // Set map's overlay tint based on the pan location
            CGFloat newAlpha = 1.0 * (1 - distanceFromCenter/longestDistance);

            // Update the scrollview alpha so we know this image is getting thrown away
            fullScreenScrollView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:newAlpha];
        }
        
        if ([recognizer state] == UIGestureRecognizerStateEnded) {
            if (distanceFromCenter < 100) {
                // If it's close enough, return the image to center
                [UIView animateWithDuration:0.4 animations:^(void) {
                    fullScreenImageView.center = originalImageCenter;
                    fullScreenScrollView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1.0];
                }];
            } else {
                // Otherwise, send it home
                self.title = @"Profile";
                [switchUserButton setEnabled:YES];
                [switchUserButton setTintColor:self.view.tintColor];
                [UIView animateWithDuration:0.3 animations:^(void) {
                    fullScreenImageView.frame = originalImageFrame;
                    fullScreenScrollView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
                }completion:^(BOOL completed) {
                    [fullScreenImageView removeFromSuperview];
                    [fullScreenScrollView removeFromSuperview];
                }];
            }
        }
    }
}

// Double tap for zoom
- (void)tapZoom:(UITapGestureRecognizer *) recognizer {
    if (fullScreenScrollView.zoomScale < 2.0) {
        [UIView animateWithDuration:0.3 animations:^(void) {
            fullScreenScrollView.zoomScale *= 2;
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^(void) {
            fullScreenScrollView.zoomScale = 1.0;
        }];
    }
}

- (void)unloadUserDocs {
    // Remove old user's docs
    for (UIView *view in [documentScrollView subviews]) {
        if ([view isKindOfClass:[UIButton class]]) {
            [view removeFromSuperview];
        }
    }
}

- (void)checkForUser:(id)sender {
    // Check for a user
    if (![PFUser currentUser]) {
        [self performSegueWithIdentifier:@"login" sender:self];
    }
}

- (IBAction)loginButtonTouched:(id)sender {
    // Keep track of who the user was before login so we can check for a new user on return
    lastUser = [PFUser currentUser];
}

// Unwind segue triggered after a photo is added
- (IBAction)unwindToProfile:(UIStoryboardSegue *)unwindSegue {
    
    // Get the source controller
    AddDocumentViewController *source = (AddDocumentViewController *) [unwindSegue sourceViewController];
    
    // If we're coming off a successful save, reload the images to get the new one
    if (source.successfulSave) {
        [self initialRetrieveUserDocs];
    }
    
}

@end
