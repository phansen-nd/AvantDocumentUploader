//
//  AddDocumentViewController.m
//  Avant Document Uploader
//
//  Created by Patrick on 8/15/15.
//  Copyright (c) 2015 Patrick Hansen. All rights reserved.
//

#import "AddDocumentViewController.h"

@interface AddDocumentViewController ()

@end

@implementation AddDocumentViewController

@synthesize imageObject;
@synthesize isSavingPicture;
@synthesize successfulSave;
@synthesize triedSavingEarly;

// IB Outlets
@synthesize takePhotoButton;
@synthesize addPhotoButton;
@synthesize imageView;
@synthesize placeholderLabel;
@synthesize titleTextField;
@synthesize savingDocumentActivityIndicatorView;

- (void)viewDidLoad {
    [super viewDidLoad];

    // Make some initial UI adjustments
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
    takePhotoButton.layer.cornerRadius = 5.0f;
    addPhotoButton.layer.cornerRadius = 5.0f;
    takePhotoButton.clipsToBounds = YES;
    addPhotoButton.clipsToBounds = YES;
    [imageView setBackgroundColor:[[UIColor darkGrayColor] colorWithAlphaComponent:0.5]];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    titleTextField.layer.cornerRadius = 5.0f;
    titleTextField.clipsToBounds = YES;
    
    // Set text field delegate
    titleTextField.delegate = self;
    
    // Init bools to no
    isSavingPicture = NO;
    successfulSave = NO;
    triedSavingEarly = NO;
}

#pragma mark - IB Actions

- (IBAction)saveButtonTouched:(id)sender {
    
    // If a picture is currently being saved, pop a waiting indicator
    // and let it know that the user tried to save (this bool checked later)
    if (isSavingPicture) {
        [savingDocumentActivityIndicatorView startAnimating];
        triedSavingEarly = YES;
        return;
    }
    
    // If there's no title...
    if ([titleTextField.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Please enter a title for the document."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    
    // ...or no image, alert and don't save
    } else if (imageView.image == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Please add an image for the document."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else if (imageObject == nil) {
        // If we get here, it means there's no network connection because
        // we have an image in the view, but it never got saved.
        // Pop the relevant error message
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Please make sure you have a network connection."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    
    // Hopefully no errors then! Try creating a new Document object,
    // populating it's fields, and saving
    } else {
        [savingDocumentActivityIndicatorView startAnimating];
        
        // Turn off user interaction while we're trying to save
        for (int i = 0; i < [[self.view subviews] count]; i++) {
            UIView* view = [[self.view subviews] objectAtIndex: i];
            view.userInteractionEnabled = NO;
        }
        
        
        // Create and populate the new object
        PFObject *newDocument = [PFObject objectWithClassName:@"Document"];
        newDocument[@"title"] = titleTextField.text;
        newDocument[@"user"] = [PFUser currentUser];
        newDocument[@"imagePointer"] = imageObject;
        
        PFACL *docACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [docACL setPublicReadAccess:YES];
        [newDocument setACL:docACL];

        // Save the Document to Parse
        [newDocument saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            [savingDocumentActivityIndicatorView stopAnimating];
            
            // Re-enable user interaction
            for (int i = 0; i < [[self.view subviews] count]; i++) {
                UIView* view = [[self.view subviews] objectAtIndex: i];
                view.userInteractionEnabled = YES;
            }
            
            if (succeeded) {
                
                // Set this bool for the unwind segue later
                successfulSave = YES;
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                                message:@"Your document has uploaded. Avant will review your submission within 24 hours."
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                
                // Unwind back to the Profile view so that view can tell if there
                // was a successful save
                [self performSegueWithIdentifier:@"unwindSave" sender:self];
            } else {
                NSString *errorString = [NSString stringWithFormat:@"Error saving Document. %@", [error localizedDescription]];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:errorString
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        }];
    
    }
}

// Check for a camera then launch the camera
- (IBAction)takePhotoButtonTouched:(id)sender {
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:picker animated:YES completion:nil];

    } else {
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Camera Not Available" message:@"Camera Not Available" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
    }
    
}


// Check for photo lib then launch it
- (IBAction)addPhotoButtonTouched:(id)sender {
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:picker animated:YES completion:nil];
        
    } else {
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Photo Library Not Available" message:@"Photo Library Not Available" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
    }
}

- (IBAction)cancelButtonTouched:(id)sender {

    // If user cancels after an image was saved, delete it from Parse
    if (imageObject != nil) {
        [imageObject deleteEventually];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Image Picker Delegate methods

// When the picker returns an image, put it in the image view for the user to check out,
// and save it! Pre-emptory save will save some time later and if we end up canceling or
// switching the image, we can just delete it
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    imageView.image = image;
    imageView.clipsToBounds = YES;
    
    // Start saving image now to save time
    PFObject *newImage = [PFObject objectWithClassName:@"Image"];
    
    // Convert to JPEG.. this should keep track of the photo's orientation
    NSData* data = UIImageJPEGRepresentation(imageView.image, 0.5f);
    PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:data];
    newImage[@"imageFile"] = imageFile;
    
    // Set this bool in case the user tries to save the Document while the picture is still saving
    isSavingPicture = YES;
    
    [newImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // Set the class variable imageObject to this one (the most recent)
            if (imageObject != nil) {
                // The user switched images, delete the last one because it will never be referenced
                [imageObject deleteEventually];
            }
            imageObject = newImage;
            
        } else {
            NSString *errorString = [NSString stringWithFormat:@"Error saving image. %@", [error localizedDescription]];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:errorString
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [savingDocumentActivityIndicatorView stopAnimating];
        }
        // Update bool to let other Save button know
        isSavingPicture = NO;
        
        // This bool was set way earlier... if it is yes,
        // the user tried to save while the Image was saving,
        // so let's automatically save the Document for them
        if (triedSavingEarly) {
            [self saveButtonTouched:self];
        }
    }];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - Text Field Delegate methods

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [titleTextField resignFirstResponder];
    return YES;
}

@end
