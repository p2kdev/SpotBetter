#import "SparkAppList.h"

@interface SPUISearchViewController : NSObject
  -(void)clearSearchResults;
@end

@interface ATXScoredPrediction
@end

static bool clearResults = YES;
static bool disableActionCards = YES;



//Clears Search Results when dismissing
%hook SPUISearchViewController

-(void)searchViewWillDismissWithReason:(unsigned long long)arg1
{
  %orig;
  if (clearResults)
    [self clearSearchResults];
}

%end

//Removes the Action Suggestions
%hook ATXActionPredictionClient

  -(id)init
  {
    if (disableActionCards)
      return nil;
    else
      return %orig;
  }
%end

//Pinning Favorite Apps in Spotlight Search
%hook ATXResponse

  //iOS13
  -(id)initWithPredictions:(NSArray*)arg1 cacheFileData:(id)arg2 error:(id)arg3
  {
    NSArray* pinnedApps = [SparkAppList getAppListForIdentifier:@"com.p2kdev.spotbetter" andKey:@"pinnedApps"];

    int counter = 1;
    for (ATXScoredPrediction* prediction in arg1)
    {
      if (pinnedApps.count >= counter)
        MSHookIvar<NSString*>(prediction,"_predictedItem") = [pinnedApps objectAtIndex:counter-1];
      else
        break;

      counter++;
    }
    return %orig;
  }

  //iOS14
  -(id)initWithPredictions:(id)arg1 proactiveSuggestions:(id)arg2 uuid:(id)arg3 cacheFileData:(id)arg4 blendingUICacheUpdateUUID:(id)arg5 error:(id)arg6
  {
    NSArray* pinnedApps = [SparkAppList getAppListForIdentifier:@"com.p2kdev.spotbetter" andKey:@"pinnedApps"];

    int counter = 1;
    for (ATXScoredPrediction* prediction in arg1)
    {
      if (pinnedApps.count >= counter)
        MSHookIvar<NSString*>(prediction,"_predictedItem") = [pinnedApps objectAtIndex:counter-1];
      else
        break;

      counter++;
    }
    return %orig;
  }
%end

static void reloadSettings() {

  NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.p2kdev.spotbetter.plist"];

  if(prefs)
  {
      clearResults = [prefs objectForKey:@"clearResults"] ? [[prefs objectForKey:@"clearResults"] boolValue] : clearResults;
      disableActionCards = [prefs objectForKey:@"disableActionCards"] ? [[prefs objectForKey:@"disableActionCards"] boolValue] : disableActionCards;
  }
}

%ctor
{
  reloadSettings();
}
