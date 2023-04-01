@interface SPUISearchViewController : NSObject
  -(void)clearSearchResults;
@end

@interface ATXScoredPrediction
@end

static NSArray* pinnedApps;
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

		static CFStringRef prefsKey = CFSTR("com.p2kdev.spotbetter");
		CFPreferencesAppSynchronize(prefsKey);

		if (CFBridgingRelease(CFPreferencesCopyAppValue((CFStringRef)@"clearResults", prefsKey))) {
			clearResults = [(id)CFBridgingRelease(CFPreferencesCopyAppValue((CFStringRef)@"clearResults", prefsKey)) boolValue];
		}

		if (CFBridgingRelease(CFPreferencesCopyAppValue((CFStringRef)@"disableActionCards", prefsKey))) {
			disableActionCards = [(id)CFBridgingRelease(CFPreferencesCopyAppValue((CFStringRef)@"disableActionCards", prefsKey)) boolValue];
		}  

		if (CFBridgingRelease(CFPreferencesCopyAppValue((CFStringRef)@"pinnedApps", prefsKey))) {
			pinnedApps = [[NSArray alloc] initWithArray:(id)CFBridgingRelease(CFPreferencesCopyAppValue((CFStringRef)@"pinnedApps", prefsKey))];
		}   
}

%ctor
{
  reloadSettings();
}
