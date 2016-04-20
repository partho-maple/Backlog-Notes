
#import <Foundation/Foundation.h>
#import "DataModel.h"


@interface ChecklistItem : NSObject <NSCoding>

///declare propertis of the items we want to store

@property (nonatomic, copy) NSString *notes;


@property (nonatomic, copy) NSDate *dueDate;
@property (nonatomic, assign) BOOL shouldRemind;
@property (nonatomic, assign) int itemId;



///declare method to schedule local notification
- (void)scheduleNotification;





@end