# AvantDocumentUploader

This is my implementation of the Avant [mobile challenge](https://github.com/avantcredit/programming_challenges/blob/master/mobile.md). 

## Basic Usage
* Start by signing up with a customer ID (any string). An account will be created and stored in Parse's database.
* Once signed into an account, the user can upload documents with a picture and a title.
 * The user can take a picture or upload one from their photo library.
 * The title can be any string.
* Once saved, documents are displayed in the profile view with their titles in a sideways-scrolling table.
* By tapping on one of the documents, a user can examine it more closely with zooming and panning. 
 * To dismiss an image that is full-screened, the user should drag the image away from the center of the screen.
* At any time, the user can upload more documents or switch accounts to a new customer ID.

## Other Notes
* I used a Parse backend to store customer info and documents. 
* The app is compatible with any screen size (except for Apple Watch) and any device running iOS8. 
* Only the portrait orientation is supported - this was a design decision.
