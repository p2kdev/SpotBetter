#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Preferences/PSSpecifier.h>
#import <AudioToolbox/AudioToolbox.h>
#include "PSDetailController.h"
#import "LSApplicationProxy+AltList.h"

@interface UIImage (Private)
    +(instancetype)_applicationIconImageForBundleIdentifier:(NSString*)bundleIdentifier format:(int)format scale:(CGFloat)scale;
    -(UIImage *)_applicationIconImageForFormat:(int)format precomposed:(BOOL)precomposed scale:(CGFloat)scale;
@end

typedef enum {
    SELECTED = 0,
    AVAILABLE
} ItemType;

@interface SpotBetterAppSelectorController : PSDetailController<UITableViewDataSource, UITableViewDelegate,
    UISearchResultsUpdating, UISearchBarDelegate> {
        UISearchController *_searchController;
        NSString *_searchKey;
        UINotificationFeedbackGenerator *_feedback;
    }
    @property (nonatomic) UITableView *tableView;
    @property (nonatomic) NSMutableArray<NSString *> *selectedApps;
    @property (nonatomic) NSMutableArray<LSApplicationProxy *>*appsForSelection;
    @property (nonatomic) NSString *defaults;
    @property (nonatomic) NSString *key;
    -(NSArray<LSApplicationProxy *> *)filteredDisabled;
@end

@implementation SpotBetterAppSelectorController

    -(void)viewDidLoad
    {
        [super viewDidLoad];

        PSSpecifier *specifier = [self specifier];

        self.defaults = [specifier propertyForKey:@"defaults"];
        self.key = [specifier propertyForKey:@"key"];

        self.appsForSelection = [NSMutableArray new];
        self.selectedApps = [NSMutableArray new];

        NSArray *defaults = [[[NSUserDefaults alloc] initWithSuiteName:self.defaults] arrayForKey:self.key];

        [self.selectedApps addObjectsFromArray:defaults];

        for (LSApplicationProxy *proxy in [[LSApplicationWorkspace defaultWorkspace] allApplications]) {
            if (![proxy atl_isHidden]) {
                [self.appsForSelection addObject:proxy];
            }
        }

        [self.appsForSelection sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"atl_fastDisplayName"
                                                                            ascending:YES
                                                                            selector:@selector(localizedCaseInsensitiveCompare:)]]];

        // if (_searchController == nil)
        //     _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        // _searchController.searchResultsUpdater = self;
        // _searchController.obscuresBackgroundDuringPresentation = NO;
        // _searchController.searchBar.delegate = self;

        // self.navigationItem.searchController = _searchController;
        // self.navigationItem.hidesSearchBarWhenScrolling = YES;

        self.definesPresentationContext = YES;

        if (_feedback == nil)
            _feedback = [[UINotificationFeedbackGenerator alloc] init];
        [_feedback prepare];
    }

    -(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
        _searchKey = searchController.searchBar.text;
        [self.tableView reloadData];
    }

    -(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar { return YES; }

    -(void)viewWillAppear:(BOOL)animated
    {
        [super viewWillAppear:animated];

        if (self.tableView == nil) {
            self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
            self.tableView.delegate = self;
            self.tableView.dataSource = self;
            self.tableView.editing = TRUE;

            [self.view addSubview:self.tableView];
        }
    }

    -(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
    {
        switch ((ItemType)section) {
            case SELECTED:
                return @"Selected";
            case AVAILABLE:
                return @"All Apps";
        }
    }

    -(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
    {
        return 2;
    }

    -(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
    {
        switch ((ItemType)section) {
            case SELECTED:
                return self.selectedApps.count;
            case AVAILABLE:
                return self.appsForSelection.count;
        }
    }

    -(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
    {
        NSObject *item;

        switch ((ItemType)indexPath.section) {
            case SELECTED:
                item = self.selectedApps[indexPath.row];
                break;
            case AVAILABLE:
                item = self.appsForSelection[indexPath.row];
                break;
        }
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.p2kdev.spotbetter"];

        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"com.p2kdev.spotbetter"];

            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }

        LSApplicationProxy *proxy;
        if ([item isKindOfClass:[NSString class]]) {
            proxy = [LSApplicationProxy applicationProxyForIdentifier:(NSString*)item];
        } else {
            proxy = (LSApplicationProxy*)item;
        }
        cell.textLabel.text = [proxy atl_nameToDisplay];
        if (cell.textLabel.text == nil) {
            cell.textLabel.text = [proxy bundleIdentifier];
            cell.detailTextLabel.text = nil;
        } else
            cell.detailTextLabel.text = [proxy bundleIdentifier];
        cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];
        cell.imageView.image = [UIImage _applicationIconImageForBundleIdentifier:[proxy bundleIdentifier]
                                                                        format:0
                                                                        scale:[UIScreen mainScreen].scale];
        

        cell.showsReorderControl = indexPath.section == 0 ? YES : FALSE;

        return cell;
    }

    -(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
    {
        return indexPath.section == SELECTED ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleInsert;
    }

    -(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
    {
        return indexPath.section == SELECTED ? YES : FALSE;
    }

    -(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(nonnull NSIndexPath *)sourceIndexPath toIndexPath:(nonnull NSIndexPath *)destinationIndexPath
    {
        switch ((ItemType)sourceIndexPath.section) {
            case SELECTED:
                if (destinationIndexPath.section == SELECTED) {
                    NSString *item = self.selectedApps[sourceIndexPath.row];
                    [self.selectedApps removeObjectAtIndex:sourceIndexPath.row];
                    [self.selectedApps insertObject:item atIndex:destinationIndexPath.row];
                }
                break;
            case AVAILABLE:
                [self.appsForSelection insertObject:self.appsForSelection[sourceIndexPath.row] atIndex:destinationIndexPath.row];
                break;
        }

        [tableView reloadData];

        [[[NSUserDefaults alloc] initWithSuiteName:self.defaults] setObject:self.selectedApps forKey:self.key];
    }

    -(NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
    {
        if (sourceIndexPath.section == SELECTED && proposedDestinationIndexPath.section != SELECTED)
            return [NSIndexPath indexPathForRow:(self.selectedApps.count - 1) inSection:0];

        return proposedDestinationIndexPath;
    }

    -(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(nonnull NSIndexPath *)indexPath
    {
        NSString *item;
        switch ((ItemType)indexPath.section) {
            case SELECTED:
                item = self.selectedApps[indexPath.row];
                break;
            case AVAILABLE:
                item = self.appsForSelection[indexPath.row].bundleIdentifier;
                break;
        }

        [tableView beginUpdates];

        if (editingStyle == UITableViewCellEditingStyleDelete) {
            [self.selectedApps removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [_feedback notificationOccurred:UINotificationFeedbackTypeSuccess];
        } else if (editingStyle == UITableViewCellEditingStyleInsert) {
            if (self.selectedApps.count == 8)
                [_feedback notificationOccurred:UINotificationFeedbackTypeError];
            else
            {
                [self.selectedApps insertObject:item atIndex:self.selectedApps.count];
                [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:([self.selectedApps count] - 1) inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                [_feedback notificationOccurred:UINotificationFeedbackTypeSuccess];
            }            
        }

        [tableView endUpdates];

        [[[NSUserDefaults alloc] initWithSuiteName:self.defaults] setObject:self.selectedApps forKey:self.key];
    }

    -(NSArray<LSApplicationProxy *> *)filteredDisabled {
        if ([_searchKey length] == 0) {
            return self.appsForSelection;
        } else {
            NSMutableArray<LSApplicationProxy *> *filteredArray = [NSMutableArray new];
            for (LSApplicationProxy *proxy in self.appsForSelection) {
                if ([proxy.bundleIdentifier rangeOfString:_searchKey options:NSCaseInsensitiveSearch].location != NSNotFound || [proxy.atl_fastDisplayName rangeOfString:_searchKey options:NSCaseInsensitiveSearch range:NSMakeRange(0, [proxy.atl_fastDisplayName length]) locale:[NSLocale currentLocale]].location != NSNotFound)
                    [filteredArray addObject:proxy];
            }
            return filteredArray;
        }
    }
@end