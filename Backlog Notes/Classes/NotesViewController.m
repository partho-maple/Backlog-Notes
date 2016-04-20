
#import "NotesViewController.h"


@interface NotesViewController ()

@end

#import "ChecklistItem.h"


@implementation NotesViewController {
    NSMutableArray *items;
    NSMutableArray *itemDatesUnsorted;
    NSMutableArray *itemDatesSorted;
    NSMutableArray *tableDataSections;
    CHOrderedDictionary *tableDataSectionsDict;
    NSMutableOrderedSet* tableDataSectionsDictKeyOrder;
}




///decode the plist
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self loadChecklistItems];
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [self customizeAppearance];
}


-(void)customizeAppearance
{
    ///table view background with our own custom image
    //    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blue-background.png"]];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName :TableSectionHeaderTextColorYellow}];
    

    
    ///initialize pull to refresh control
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    /// configure left navigation bar button item as edit button. This edit button has a mechanism of changing its title to "Done" when it pressed
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    [self.tableView reloadData];
    
    
    
    self.navigationController.navigationBar.barTintColor = NavBarBackgroundColor;
    self.navigationController.navigationBar.translucent = NO;
    
    self.tableView.separatorColor = [UIColor clearColor];
    
    
    [[UITableViewHeaderFooterView appearance] setTintColor:NavBarBackgroundColor];
    
    
    
    
    
    
    
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
}




- (UIImage *)imageFromLayer:(CALayer *)layer
{
    UIGraphicsBeginImageContext([layer frame].size);
    
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return outputImage;
}



///Tells the delegate that the user tapped the accessory (disclosure) view associated with a given row.
/// we declare the touch event of accessory button of uitableview cell. When user tap on the accessory button, it should bring editing mode
- (IBAction)accessoryButtonTapped:(id)sender event:(id)event
{
	NSSet *touches = [event allTouches];
	UITouch *touch = [touches anyObject];
	CGPoint currentTouchPosition = [touch locationInView:self.tableView];
	NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: currentTouchPosition];
	if (indexPath != nil)
		
	{
        [self tableView: self.tableView accessoryButtonTappedForRowWithIndexPath: indexPath];
	}
}





#pragma mark - Utilities methodes

///Creates a list of path strings for the specified directories in the specified domains. The list is in the order in which you should search the directories. If expandTilde is YES, tildes are expanded as described in stringByExpandingTildeInPath.
///we define the plist shall be saved in our own directory
- (NSString *)documentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}



///Returns a new string made by appending to the receiver a given string. Note that this method only works with file paths (not, for example, string representations of URLs).
///we save the plist in the documents director of our application
- (NSString *)dataFilePath
{
    return [[self documentsDirectory] stringByAppendingPathComponent:@"Notes.plist"];
}



///Method to save the data to plist
- (void)saveChecklistItems
{
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:items forKey:@"ChecklistItems"];
    [archiver finishEncoding];
    [data writeToFile:[self dataFilePath] atomically:YES];
}



//we load decoded data to tableview
- (void)loadChecklistItems
{
    NSString *path = [self dataFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        NSData *data = [[NSData alloc] initWithContentsOfFile:path];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        items = [unarchiver decodeObjectForKey:@"ChecklistItems"];
        [unarchiver finishDecoding];
    }
    else
    {
        items = [[NSMutableArray alloc] initWithCapacity:20];
    }
    
    
    
    
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"dueDate" ascending:NO];
    NSArray *sortedArray = [items sortedArrayUsingDescriptors: [NSArray arrayWithObject:sortDescriptor]];
    items = [NSMutableArray arrayWithArray:sortedArray];
    
 
    
//    Reversing the Items List
//    NSArray *localItemsReversed = [[NSMutableArray alloc] initWithCapacity:items.count];
//    localItemsReversed = [[items reverseObjectEnumerator] allObjects];
//    items = [NSMutableArray arrayWithArray:localItemsReversed];
    
    

    
    
    
//    Sort the table date on it's date
    [self sortTableDateToIndecesByDateWith:items];
}


- (void) sortTableDateToIndecesByDateWith:(NSMutableArray *)listItems
{
    
    tableDataSectionsDict = [CHOrderedDictionary dictionary];
    tableDataSectionsDictKeyOrder = [[NSMutableOrderedSet alloc] init];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit ) fromDate:[[NSDate alloc] init]];
    [components setTimeZone:[NSTimeZone defaultTimeZone]];
    NSDateFormatter *df=[[NSDateFormatter alloc]init];
    [df setDateFormat:@"dd/MM/yyyy"];
    
    
    
    NSDate *now = [NSDate date];
    
    
    
    [components setHour:-[components hour]];
    [components setMinute:-[components minute]];
    [components setSecond:-[components second]];
    NSDate *today = [cal dateByAddingComponents:components toDate:[[NSDate alloc] init] options:0]; //    This variable should now be pointing at a date object that is the start of today (midnight);
    
    
    
    [components setHour:-24];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *yesterday = [cal dateByAddingComponents:components toDate: today options:0];
    
    
    
    components = [cal components:NSWeekdayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:[[NSDate alloc] init]];
    
    
    
    [components setDay:([components day] - ([components weekday] - 1))];
    NSDate *thisWeek  = [cal dateFromComponents:components];

    
    [components setDay:([components day] - 7)];
    NSDate *lastWeek  = [cal dateFromComponents:components];

    
    [components setDay:([components day] - 7)];
    NSDate *twoWeeksAgo  = [cal dateFromComponents:components];

    
    [components setDay:([components day] - ([components day] -1))];
    NSDate *thisMonth = [cal dateFromComponents:components];

    
    [components setMonth:([components month] - 1)];
    NSDate *lastMonth = [cal dateFromComponents:components];

    
    [components setMonth:([components month] - 1)];
    NSDate *twoMonthsAgo = [cal dateFromComponents:components];

    
    NSMutableArray *TodayArray  = [NSMutableArray array];
    NSMutableArray *YesterdayArray  = [NSMutableArray array];
    NSMutableArray *ThisWeekArray  = [NSMutableArray array];
    NSMutableArray *LastWeekArray  = [NSMutableArray array];
    NSMutableArray *TwoWeeksAgoArray  = [NSMutableArray array];
    NSMutableArray *ThisMonthArray  = [NSMutableArray array];
    NSMutableArray *LastMonthArray  = [NSMutableArray array];
    NSMutableArray *TwoMonthsAgoArray  = [NSMutableArray array];
    NSMutableArray *LongAgoArray  = [NSMutableArray array];
    
    
    NSMutableArray *AllTimeArray  = [NSMutableArray array];
    
    
    for (int i=0; i < items.count; i++) {
        
        ChecklistItem *item = [items objectAtIndex:i];
        NSDate *addingDate = item.dueDate;
        NSUInteger count = tableDataSectionsDict.count;
        
        if ([NotesViewController date:addingDate isBetweenDate:today andDate:now]) {
            
            [TodayArray addObject:item];
            
            if (![[tableDataSectionsDict allKeys]containsObject:@"Today"]) {
//                [tableDataSectionsDict setObject:TodayArray forKey:@"Today"];
                [tableDataSectionsDict insertObject:TodayArray forKey:@"Today" atIndex:count];
            }
        }
        else if ([NotesViewController date:addingDate isBetweenDate:yesterday andDate:today]) {
            
            [YesterdayArray addObject:item];
            
            if (![[tableDataSectionsDict allKeys]containsObject:@"Yesterday"]) {
//                [tableDataSectionsDict setObject:YesterdayArray forKey:@"Yesterday"];
                [tableDataSectionsDict insertObject:YesterdayArray forKey:@"Yesterday" atIndex:count];
            }
        }
        else if ([NotesViewController date:addingDate isBetweenDate:thisWeek andDate:yesterday]) {
            
            [ThisWeekArray addObject:item];
            
            if (![[tableDataSectionsDict allKeys]containsObject:@"This Week"]) {
//                [tableDataSectionsDict setObject:ThisWeekArray forKey:@"This Week"];
                [tableDataSectionsDict insertObject:ThisWeekArray forKey:@"This Week" atIndex:count];
            }
        }
        else if ([NotesViewController date:addingDate isBetweenDate:lastWeek andDate:thisWeek]) {
            
            [LastWeekArray addObject:item];
            
            if (![[tableDataSectionsDict allKeys]containsObject:@"Last Week"]) {
//                [tableDataSectionsDict setObject:LastWeekArray forKey:@"Last Week"];
                [tableDataSectionsDict insertObject:LastWeekArray forKey:@"Last Week" atIndex:count];
            }
        }
        else if ([NotesViewController date:addingDate isBetweenDate:twoWeeksAgo andDate:lastWeek]) {
            
            [TwoWeeksAgoArray addObject:item];
            
            if (![[tableDataSectionsDict allKeys]containsObject:@"Two Weeks Ago"]) {
//                [tableDataSectionsDict setObject:TwoWeeksAgoArray forKey:@"Two Weeks Ago"];
                [tableDataSectionsDict insertObject:TwoWeeksAgoArray forKey:@"Two Weeks Ago" atIndex:count];
            }
        }
        else if ([NotesViewController date:addingDate isBetweenDate:thisMonth andDate:twoWeeksAgo]) {
            
            [ThisMonthArray addObject:item];
            
            if (![[tableDataSectionsDict allKeys]containsObject:@"This Month"]) {
//                [tableDataSectionsDict setObject:ThisMonthArray forKey:@"This Month"];
                [tableDataSectionsDict insertObject:ThisMonthArray forKey:@"This Month" atIndex:count];
            }
        }
        else if ([NotesViewController date:addingDate isBetweenDate:lastMonth andDate:thisMonth]) {
            
            [LastMonthArray addObject:item];
            
            if (![[tableDataSectionsDict allKeys]containsObject:@"Last Month"]) {
//                [tableDataSectionsDict setObject:LastMonthArray forKey:@"Last Month"];
                [tableDataSectionsDict insertObject:LastMonthArray forKey:@"Last Month" atIndex:count];
            }
        }
        else if ([NotesViewController date:addingDate isBetweenDate:twoMonthsAgo andDate:lastMonth]) {
            
            [TwoMonthsAgoArray addObject:item];
            
            if (![[tableDataSectionsDict allKeys]containsObject:@"Two Months Ago"]) {
//                [tableDataSectionsDict setObject:TwoMonthsAgoArray forKey:@"Two Months Ago"];
                [tableDataSectionsDict insertObject:TwoMonthsAgoArray forKey:@"Two Months Ago" atIndex:count];
            }
        }
        else {
            
            [LongAgoArray addObject:item];
            
            if (![[tableDataSectionsDict allKeys]containsObject:@"Long Ago"]) {
//                [tableDataSectionsDict setObject:LongAgoArray forKey:@"Long Ago"];
                [tableDataSectionsDict insertObject:LongAgoArray forKey:@"Long Ago" atIndex:count];
            }
        }
        
    }
    
    
    
    
    NSLog(@"tableDataSectionsDict: %@" ,tableDataSectionsDict);
}

-(int)getIndexOf:(NSString*)c Into:(NSString*)string {
	
	for(int i=0;i<string.length;i++)
		if([c characterAtIndex:0] == [string characterAtIndex:i])
			return i;
	
	return -1;
}


+ (BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate
{
    if ([date compare:beginDate] == NSOrderedAscending)
    	return NO;
    
    if ([date compare:endDate] == NSOrderedDescending)
    	return NO;
    
    return YES;
}



/// following method configures uitableviewcell text when user adds a new item
- (void)configureTextForCell:(UITableViewCell *)cell withChecklistItem:(ChecklistItem *)item
{
    
    UILabel *notesLabel = (UILabel *)[cell viewWithTag:1500];
    
    NSRange rangeOfString = [item.notes rangeOfString:@"."];
    if(rangeOfString.location == NSNotFound)
    {
        // error condition — the text searchKeyword wasn't in 'string'
        notesLabel.text = item.notes;
    }
    else{
        NSLog(@"range position %lu", (unsigned long)rangeOfString.location);
        notesLabel.text = [item.notes substringToIndex:(rangeOfString.location + 1)];
    }
    
    
    
    
    
    if (item.shouldRemind == YES) {
        
        UILabel *dueDateLabel = (UILabel *)[cell viewWithTag:1600];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        dueDateLabel.text = [formatter stringFromDate:item.dueDate];
        
    } else
    {
        UILabel *dueDateLabel = (UILabel *)[cell viewWithTag:1600];
        dueDateLabel.text = nil;
        
    }
    
}



///refresh (aka pulltorefresh activated additem identifier. Upon activation, we stop refreshing.
- (void)refresh
{
    [self performSegueWithIdentifier:@"AddItem" sender:self];
    
    [self.refreshControl endRefreshing];
    
}





#pragma mark - UITableViewDataSource methodes

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [tableDataSectionsDict count];
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *keys = [tableDataSectionsDict allKeys];
    NSString *aKey = [keys objectAtIndex:section];
    
    NSArray *eventsOnThisDay = [tableDataSectionsDict objectForKey:aKey];
    return [eventsOnThisDay count];
}



- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSArray *keys = [tableDataSectionsDict allKeys];
    NSString *aKey = [keys objectAtIndex:section];

    return aKey;
}



//Asks the data source for a cell to insert in a particular location of the table view. (required)
// here we configure uitableview cell. this will be reused for te whole tableview
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChecklistItem"];
    
    
//    ChecklistItem *item = [items objectAtIndex:indexPath.row];
//    [self configureTextForCell:cell withChecklistItem:item];
    
    NSArray *keys = [tableDataSectionsDict allKeys];
    NSString *aKey = [keys objectAtIndex:indexPath.section];

//    NSDate *dateRepresentingThisDay = [items objectAtIndex:indexPath.section];
    NSArray *eventsOnThisDay = [tableDataSectionsDict objectForKey:aKey];
    ChecklistItem *item = [eventsOnThisDay objectAtIndex:indexPath.row];

    

    [self configureTextForCell:cell withChecklistItem:item];
    return cell;

}



//when user swip left to right or right to left, table view enters into editing mode and prepares to delete the data from table view. once user deleted, we remove that particular item from plist.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *keys = [tableDataSectionsDict allKeys];
    NSString *aKey = [keys objectAtIndex:indexPath.section];
    
    NSArray *eventsOnThisDay = [tableDataSectionsDict objectForKey:aKey];
    
    ChecklistItem *item = [eventsOnThisDay objectAtIndex:indexPath.row];
    
    for (int i = 0; i<items.count; i++)
    {
        ChecklistItem *itemToDelete = [items objectAtIndex:i];
        
        if ([item.dueDate isEqualToDate:itemToDelete.dueDate])
        {
//            The following 2 lines is respomsible for table row cell delesion abimation. But those aew occuring error.
//            NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
//            [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationLeft];
            
            [items removeObjectAtIndex:i];
        }
    }

    [self saveChecklistItems];
    [self loadChecklistItems];
    
//    for (int i =1; i<150; i++) {
//        NSLog(@"spend some time here");
//    }
    
    [self.tableView reloadData];
}



///Define whether reorder is allowed. Set to NO if reorder is not allowed
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}



/// Identfy which row is reordered and update the table view and save the plist file.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    id objectToMove = [items objectAtIndex:fromIndexPath.row];
    [items removeObjectAtIndex:fromIndexPath.row];
    [items insertObject:objectToMove atIndex:toIndexPath.row];
    [tableView reloadData];
    [self saveChecklistItems];
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *tempView=[[UIView alloc]initWithFrame:CGRectMake(0,200,300,244)];
    tempView.backgroundColor = NavBarBackgroundColor;
    
    UILabel *tempLabel=[[UILabel alloc]initWithFrame:CGRectMake(15,0,300,20)];
    tempLabel.backgroundColor=[UIColor clearColor];
//    tempLabel.shadowColor = [UIColor blackColor];
//    tempLabel.shadowOffset = CGSizeMake(0,2);
    tempLabel.textColor = TableSectionHeaderTextColorYellow;
    
    NSArray *keys = [tableDataSectionsDict allKeys];
    NSString *aKey = [keys objectAtIndex:section];
    tempLabel.text = aKey;  // probably from array
    
    [tempView addSubview:tempLabel];
    
    return tempView;
}





#pragma mark - UITableViewDelegate methodes

///Set background of uitable view cell with our own custom image. we also set the seperator style between cell to none
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
        
    cell.backgroundColor =  TableCellBackgroundColor;
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
}



///The method allows the delegate to specify rows with varying heights. If this method is implemented, the value it returns overrides the value specified for the rowHeight property of UITableView for the given row.
/// height of uitable view cell which overrides interface builder
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 53;
}



///when the user tap on the particular cell, we display the item.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath
                                                                    *)indexPath
{
    
    NSArray *keys = [tableDataSectionsDict allKeys];
    NSString *aKey = [keys objectAtIndex:indexPath.section];
    
    NSArray *eventsOnThisDay = [tableDataSectionsDict objectForKey:aKey];

    ChecklistItem *item = [eventsOnThisDay objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"EditItem" sender:item];
}



///The delegate usually responds to the tap on the disclosure button (the accessory view) by displaying a new view related to the selected row. This method is not called when an accessory view is set for the row at indexPath.
///When accessory item is tapped, edit item will be presented of the selected item
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    
    NSArray *keys = [tableDataSectionsDict allKeys];
    NSString *aKey = [keys objectAtIndex:indexPath.section];
    
    NSArray *eventsOnThisDay = [tableDataSectionsDict objectForKey:aKey];
    
    ChecklistItem *item = [eventsOnThisDay objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"EditItem" sender:item];
    
}





#pragma mark - AddItemViewControllerDelegate methodes

///The presenting view controller is responsible for dismissing the view controller it presented. If you call this method on the presented view controller itself, it automatically forwards the message to the presenting view controller.
///dismiss view controller presented
- (void)addItemViewControllerDidCancel:(AddNoteViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

///Save the added item and dismiss view controller presented
- (void)addItemViewController:(AddNoteViewController *)controller didFinishAddingItem:(ChecklistItem *)item
{
    int newRowIndex = [items count];
    [items addObject:item];
    [self saveChecklistItems];
    [self loadChecklistItems];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:newRowIndex inSection:0];
    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
    [self.tableView reloadData];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

///Save the edited item and dismiss view controller presented
- (void)addItemViewController:(AddNoteViewController *)controller didFinishEditingItem:(ChecklistItem *)item
{
    int index = [items indexOfObject:item];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [self configureTextForCell:cell withChecklistItem:item];
    [self saveChecklistItems];
    [self loadChecklistItems];
    [self.tableView reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
}





#pragma mark - Segue Delegate methodes

/// When the user taps on "Add" button, "additem" segue is triggered and add new item view controller is presented. wen user tap on accessory button, "edititem" is triggered and item view controller is presented in editing mode.
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AddItem"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        AddNoteViewController *controller = (AddNoteViewController *)navigationController.topViewController;
        controller.delegate = self;
    }else if ([segue.identifier isEqualToString:@"EditItem"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        AddNoteViewController *controller = (AddNoteViewController *)navigationController.topViewController;
        controller.delegate = self;
        controller.itemToEdit = sender;
    }
}





@end
