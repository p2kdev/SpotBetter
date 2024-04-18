@interface SPUISearchViewController : NSObject
  -(void)clearSearchResults;
  -(void)clearSearchResultsAndFetchZKW:(BOOL)arg1;
@end

@interface ATXScoredPrediction
@end

@interface SSRecentResultsManager : NSObject
  +(void)deleteAllRecents;
@end

@interface SFResultSection
  @property (nonatomic,copy) NSString * bundleIdentifier;
@end

static NSArray* pinnedApps;
static BOOL clearResults = YES;
static BOOL disableActionCards = YES;
static BOOL clearRecentSearches = YES;

//Clears Search Results when dismissing
%hook SPUISearchViewController

  -(void)searchViewWillDismissWithReason:(unsigned long long)arg1
  {
    %orig;
    if (clearResults) {
      if ([self respondsToSelector:@selector(clearSearchResults:)])
        [self clearSearchResults];
      else if ([self respondsToSelector:@selector(clearSearchResultsAndFetchZKW:)])
        [self clearSearchResultsAndFetchZKW:NO];
    }       
  }

%end

//Clear Recent Searches
%hook SFResultSection

  -(void)setResults:(NSArray*)results {
    if ([self.bundleIdentifier isEqualToString:@"com.apple.spotlight.dec.zkw.recents"] && clearRecentSearches)
      results = nil;

    %orig;
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

//Removes the Action Suggestions on iOS16+
%hook ATXProactiveSuggestionClient

  -(id)init
  {
    if (disableActionCards)
      return nil;
    else
      return %orig;
  }
    
  -(id)initWithConsumerSubType:(unsigned char)arg1 {
    if (disableActionCards)
      return nil;
    else
      return %orig;
  }
%end

//Pinning Favorite Apps in Spotlight Search
%hook ATXResponse

  //iOS13
  -(id)initWithPredictions:(id)arg1 cacheFileData:(id)arg2 error:(id)arg3
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

  //iOS14 & up
  -(id)initWithPredictions:(id)arg1 proactiveSuggestions:(id)arg2 uuid:(id)arg3 cacheFileData:(id)arg4 blendingUICacheUpdateUUID:(id)arg5 error:(id)arg6 {
    int counter = 1;
    for (ATXScoredPrediction* prediction in arg1)
    {
      if (pinnedApps.count >= counter)
        MSHookIvar<NSString*>(prediction,"_predictedItem") = [pinnedApps objectAtIndex:counter-1];
      else
        break;

      counter++;
    }
    return %orig(arg1,nil,arg3,arg4,arg5,arg6);
  }

%end

static void reloadSettings() {

		static CFStringRef prefsKey = CFSTR("com.p2kdev.spotbetter");
		CFPreferencesAppSynchronize(prefsKey);

		if (CFBridgingRelease(CFPreferencesCopyAppValue((CFStringRef)@"clearResults", prefsKey))) {
			clearResults = [(id)CFBridgingRelease(CFPreferencesCopyAppValue((CFStringRef)@"clearResults", prefsKey)) boolValue];
		}

		if (CFBridgingRelease(CFPreferencesCopyAppValue((CFStringRef)@"clearRecentSearches", prefsKey))) {
			clearRecentSearches = [(id)CFBridgingRelease(CFPreferencesCopyAppValue((CFStringRef)@"clearRecentSearches", prefsKey)) boolValue];
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
