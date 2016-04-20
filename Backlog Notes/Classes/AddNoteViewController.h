

#import <UIKit/UIKit.h>
#import "iOS_Constants.h"


///declare delagate methods

@class AddNoteViewController;
@class ChecklistItem;

/// We pass the creted information to checkviewcontroller using delegate method.
@protocol AddItemViewControllerDelegate <NSObject>

///This method declares when user tap on the cancel button, it will dismiss the addnote view controller presenting without saving the data
- (void)addItemViewControllerDidCancel:(AddNoteViewController *)controller;



///This method pass the relevant "added" information such as notes, whether to remind to checklistview controller
- (void)addItemViewController:(AddNoteViewController *)controller didFinishAddingItem:(ChecklistItem *)item;




///This method pass the relevant "edited" information such as task, notes, whether to remind to checklistview controller
- (void)addItemViewController:(AddNoteViewController *)controller didFinishEditingItem:(ChecklistItem *)item;
@end

















/// confirm that textfield, datpicker and actionsheet delegates to self
@interface AddNoteViewController : UITableViewController <UITextFieldDelegate, UITextViewDelegate, UIAlertViewDelegate>


/// textField is a field where user key in the task information. 
//@property (strong, nonatomic) IBOutlet UITextField *textField;

/// notesField is a field where user key in the additional information.
@property (strong, nonatomic) IBOutlet UITextView *notesField;

/// We create doneBarButton as IBOutlet so that we can disable the done button if the text field is empty.
//@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneBarButton;

///confirms delegate method
@property (nonatomic, weak) id <AddItemViewControllerDelegate> delegate;

///We declare itemtoedit method to display information for user to edit 
@property (nonatomic, strong) ChecklistItem *itemToEdit;

///this is the notification time which user selects
@property (nonatomic, strong) IBOutlet UILabel *dueDateLabel;

///This outlet will be only enables if the notes is editing mode
@property (nonatomic, strong) IBOutlet UIBarButtonItem *shareButton;

///When the user tap on the share button we bring up this activity controller
@property (nonatomic, strong) UIActivityViewController *activityViewController;




///create IBActions

///We create cancel IBAction. when user tap on cancel button, we dismiss the presenting view controller by calling AddItemViewControllerDelegate using delegate method
- (IBAction)cancel;

///We create done IBAction. when user tap done button, we dismiss the presenting view controller by calling didFinishAddingItem using delegate method which will pass the added/edited information to checklistviewcontroller
- (IBAction)done;

///We create share button for user to tap to share the notes
-(IBAction) shareButtonClicked:(id)sender;





-(void)customizeAppearance;


@end