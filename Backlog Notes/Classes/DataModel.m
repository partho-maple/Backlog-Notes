
#import "DataModel.h"


@implementation DataModel



///register defaults for the application. We declare yes to firsttime and id for location notification to zero.
- (void)registerDefaults
{
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithBool:YES], @"FirstTime",
                                [NSNumber numberWithInt:0], @"ChecklistItemId",
                                nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
}



///When the app run first time, we need to change the user default for "firstrun" to NO.
- (void)handleFirstTime
{
    BOOL firstTime = [[NSUserDefaults standardUserDefaults] boolForKey:@"FirstTime"];
                      if (firstTime) {
                          
                          [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"FirstTime"];
                          
                      }
}
  


///Once loaded we call the following methods to check whether first time or subsequent time loading.
- (id)init
{
    if ((self = [super init])) {
        [self registerDefaults];
        [self handleFirstTime];
    }
    return self;
}



///Here we assign the ID for first checklist createdto 0 and for each checklist generated subsequently will add  incremental of 1.
+ (int)nextChecklistItemId
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    int itemId = [userDefaults integerForKey:@"ChecklistItemId"];
    [userDefaults setInteger:itemId + 1 forKey:@"ChecklistItemId"];
    [userDefaults synchronize];
    return itemId;
}


@end
