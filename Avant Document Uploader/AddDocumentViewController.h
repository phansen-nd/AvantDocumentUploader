//
//  AddDocumentViewController.h
//  Avant Document Uploader
//
//  Created by Patrick on 8/15/15.
//  Copyright (c) 2015 Patrick Hansen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface AddDocumentViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) PFObject *imageObject;
@property BOOL isSavingPicture;
@property BOOL successfulSave;
@property BOOL triedSavingEarly;

// IB Outlets
@property (nonatomic, strong) IBOutlet UIButton *takePhotoButton;
@property (nonatomic, strong) IBOutlet UIButton *addPhotoButton;
@property (nonatomic, strong) IBOutlet UILabel *placeholderLabel;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UITextField *titleTextField;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *savingDocumentActivityIndicatorView;

// IB Actions
- (IBAction)cancelButtonTouched:(id)sender;
- (IBAction)saveButtonTouched:(id)sender;
- (IBAction)takePhotoButtonTouched:(id)sender;
- (IBAction)addPhotoButtonTouched:(id)sender;

@end
