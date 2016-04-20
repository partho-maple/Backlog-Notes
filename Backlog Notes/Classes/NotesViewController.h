
#import <UIKit/UIKit.h>
#import "AddNoteViewController.h"
#import "iOS_Constants.h"
#import "CHOrderedDictionary.h"



@interface NotesViewController : UITableViewController <AddItemViewControllerDelegate> {
    
}


- (NSString *) documentsDirectory;
- (NSString *) dataFilePath;
- (void) saveChecklistItems;
- (void) loadChecklistItems;

//    Sort the table date on it's date
- (void) sortTableDateToIndecesByDateWith:(NSMutableArray *)listItems;

- (int) getIndexOf:(NSString*)c Into:(NSString*)string;
+ (BOOL) date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate;
- (void) configureTextForCell:(UITableViewCell *)cell withChecklistItem:(ChecklistItem *)item;
- (void) refresh;


-(void)customizeAppearance;

@end
