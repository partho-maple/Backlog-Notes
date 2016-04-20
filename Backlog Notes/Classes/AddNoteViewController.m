
#import "AddNoteViewController.h"
#import "ChecklistItem.h"

#define emptyNoteAlertViewsTag 0

@interface AddNoteViewController ()

@end



@implementation AddNoteViewController {

    NSString *notes;
    BOOL shouldRemind;
    NSDate *dueDate;
}



///synthesize properties
@synthesize notesField, delegate, itemToEdit, dueDateLabel, activityViewController;



///we display current date and time when we present the addnotevewcontroller to user
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        notes = @"";
        shouldRemind = YES;
        dueDate = [NSDate date];
    }
    return self;
}



/// NSdate formetter to format date and update the label when user picked different date 
- (void)updateDueDateLabel
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    self.dueDateLabel.text = [formatter stringFromDate:dueDate];
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ///wecreate
    UIBarButtonItem *doneButton         = [[UIBarButtonItem alloc]
                                          initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                          target:self
                                          action:@selector(done)];
    
    UIBarButtonItem *shareButton         = [[UIBarButtonItem alloc]
                                            initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                            target:self
                                            action:@selector(shareButtonClicked:)];
    
    
    self.navigationItem.rightBarButtonItems =
    [NSArray arrayWithObjects:doneButton, shareButton, nil];
    
    
    
    ///we check whether it is editing mode or adding mode, then set the title and fields appropriately.

    if (self.itemToEdit != nil) {
        self.title = @"Edit Note";
    } else
        
        self.title = @"Add Note";
    self.notesField.text = notes;


    [self updateDueDateLabel];
    shareButton.enabled = YES;
    
    
//    Sets the TextView delegate
    self.notesField.delegate = self;
    
    
    
    
    [self customizeAppearance];

}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.title != NSLocalizedString(@"Edit Note", nil)) {
        [self.notesField becomeFirstResponder];
        [self.notesField resignFirstResponder];
//        [self.notesField becomeFirstResponder];
        
    }else
        [self.notesField resignFirstResponder];
}





/// method to call addItemViewControllerDidCancel method when cancel button pressed

- (IBAction)cancel
{
    [self.delegate addItemViewControllerDidCancel:self];
}


/// method to call didFinishAddingItem method when Done button pressed


- (IBAction)done
{
    
    if ([self.notesField.text isEqualToString:@" "] || [self.notesField.text isEqualToString:@""] || [self.notesField.text isEqualToString:nil])
    {
        
        UIAlertView* message = [[UIAlertView alloc]
                                initWithTitle: @"Empty !!!"
                                message: @"Note is empty. Click OK to write again, or Cancel to dismiss."
                                delegate: self
                                cancelButtonTitle: @"Cancel"
                                otherButtonTitles: @"OK", nil];
        
        message.tag = emptyNoteAlertViewsTag;
        [message show];
        
    }
    else
    {
        if (self.itemToEdit == nil) {
            ChecklistItem *item = [[ChecklistItem alloc] init];
            
            item.notes = self.notesField.text;
            item.shouldRemind = YES;
            item.dueDate = dueDate;
            
            //        Shows the notification on the given date
            //        [item scheduleNotification];
            
            [self.delegate addItemViewController:self didFinishAddingItem:item];
        } else {
            self.itemToEdit.notes = self.notesField.text;
            self.itemToEdit.shouldRemind = YES;
            self.itemToEdit.dueDate = dueDate;
            
            //        Shows the notification on the given date
            //        [self.itemToEdit scheduleNotification];
            
            [self.delegate addItemViewController:self didFinishEditingItem:self.itemToEdit];
        }
    }

    
}




///optionally we can dismiss keyboard if the user starts to scroll the tableview

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.notesField resignFirstResponder];
    
}



- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
   
    if (indexPath.section == 0) {
    cell.backgroundColor =  TableCellBackgroundColor;
    
    
    }else{
        
    }

}


///to prevent the uitableview cell turns blue when user taps on it

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        
        return indexPath;
    } else {
        return nil;
    }
}







- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

///release te memory by setting nil to these fields as we no loner need them

- (void)viewDidUnload
{
    [self setNotesField:nil];
    [self setDueDateLabel:nil];
    [super viewDidUnload];
}


///we present stored item if the user editing an item

- (void)setItemToEdit:(ChecklistItem *)newItem
{
    if (itemToEdit != newItem) {
        itemToEdit = newItem;
        notes = itemToEdit.notes;
        shouldRemind = itemToEdit.shouldRemind;
        dueDate = itemToEdit.dueDate;
    }
}



#pragma mark - Table view data source



///we use prepare for segue method to display date picker controller

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}




-(IBAction) shareButtonClicked:(id)sender
{
    
    NSString *emailBody = notesField.text;
     
    self.activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[emailBody] applicationActivities:nil];
    
    [self presentViewController:self.activityViewController animated:YES completion:nil];
    
    
}




#pragma mark - AlertView data source

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == emptyNoteAlertViewsTag)
    {
        if (buttonIndex == alertView.cancelButtonIndex) {
            // Cancel was tapped
            NSLog(@"Cancel was tapped");
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }
        else if (buttonIndex == alertView.firstOtherButtonIndex)
        {
            // The other button was tapped
            NSLog(@"OK button was tapped");
        }
    }
}


#pragma mark - TextView data source

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    NSLog(@"textViewDidBeginEditing...");
//    self.notesField.frame.origin.y = self.navigationController.navigationBar.frame.origin.y + self.dueDateLabel.frame.origin.y;
    
//    [self.notesField setFrame:CGRectMake(0, (self.navigationController.navigationBar.frame.origin.y + self.dueDateLabel.frame.origin.y), 320.0, 500)];
}

 - (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}




-(void)customizeAppearance
{
    self.navigationController.navigationBar.barTintColor = NavBarBackgroundColor;
    self.navigationController.navigationBar.translucent = NO;
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName :TableSectionHeaderTextColorYellow}];
    

    
    // Create the colors
    UIColor *lightOp = backgroundColorGradientTop;
    UIColor *darkOp = backgroundColorGradientBottom;
    
    
    // Create the gradient
    CAGradientLayer *gradient = [CAGradientLayer layer];
    
    // Set colors
    gradient.colors = [NSArray arrayWithObjects:
                       (id)lightOp.CGColor,
                       (id)darkOp.CGColor,
                       nil];
    
    // Set bounds
    gradient.frame = self.view.bounds;
    
    
    UIImage *gradientImage = [self imageFromLayer:gradient];
    UIImage *worldBGImage = [UIImage imageNamed:@"blue-background.png"];
    
    
    CGSize size = CGSizeMake(gradientImage.size.width, gradientImage.size.height);
    UIGraphicsBeginImageContext(size);
    
    [worldBGImage drawInRect:CGRectMake(0,0,size.width, size.height)];
    [gradientImage drawInRect:CGRectMake(0,0,size.width, size.height)];
    //    [worldBGImage drawInRect:CGRectMake(0,0,size.width, size.height)];
    
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:finalImage];
    
//    [notesField setBackgroundColor:[UIColor clearColor]];
    [notesField setBackgroundColor:TableCellBackgroundColor];
}

- (UIImage *)imageFromLayer:(CALayer *)layer
{
    UIGraphicsBeginImageContext([layer frame].size);
    
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return outputImage;
}




@end
