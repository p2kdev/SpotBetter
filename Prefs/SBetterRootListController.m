#import <Preferences/Preferences.h>
#import "SparkAppListTableViewController.h"
#import "spawn.h"

@interface SBetterRootListController : PSListController
@end

@implementation SBetterRootListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}
	return _specifiers;
}

// - (void)selectApps {
//     SparkAppListTableViewController* s = [[SparkAppListTableViewController alloc] initWithIdentifier:@"com.p2kdev.spotbetter" andKey:@"pinnedApps"];

//     [self.navigationController pushViewController:s animated:YES];
//     self.navigationItem.hidesBackButton = FALSE;
// }

- (void)visitTwitter {
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://twitter.com/p2kdev"]];
}

- (void)killSpotlight {
	pid_t pid;
	const char* args[] = {"killall", "-9", "Spotlight", NULL, NULL};
	posix_spawn(&pid, "/var/jb/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
}

@end
