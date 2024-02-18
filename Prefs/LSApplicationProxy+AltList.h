#import <Foundation/Foundation.h>

@interface LSApplicationRecord : NSObject
    @property (nonatomic,readonly) NSArray* appTags;
    @property (getter=isLaunchProhibited,readonly) BOOL launchProhibited;
@end

@interface LSApplicationProxy : NSObject
    @property (nonatomic,readonly) NSArray* appTags;
    @property (getter=isLaunchProhibited,nonatomic,readonly) BOOL launchProhibited;
    @property (nonatomic,readonly) NSString* localizedName;
    +(LSApplicationProxy *)applicationProxyForIdentifier:(NSString *)id;
    -(NSString *)localizedNameForContext:(id)arg;
    -(NSURL *)bundleURL;
    -(NSString *)bundleIdentifier;
    -(LSApplicationRecord *)correspondingApplicationRecord;
@end

@interface LSApplicationProxy (AltList)
    -(BOOL)atl_isHidden;
    -(NSString *)atl_fastDisplayName;
    -(NSString *)atl_nameToDisplay;
@end

@interface LSApplicationWorkspace : NSObject
    +(LSApplicationWorkspace *)defaultWorkspace;
    -(NSArray<LSApplicationWorkspace *> *)allApplications;
@end