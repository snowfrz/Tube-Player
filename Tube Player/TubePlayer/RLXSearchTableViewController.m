//
//  RLXSearchTableViewController.m
//  Relax
//
//  Created by Justin Proulx on 2018-03-10.
//  Copyright © 2018 Low Budget Animation Studios. All rights reserved.
//

#import "RLXSearchTableViewController.h"
#import "UIScrollView+EmptyDataSet.h"
#import "RLXRequest.h"
#import "RLXSearchTableViewCell.h"
#import "RLXVideoPlayerViewController.h"
#import "AppDelegate.h"

@interface RLXSearchTableViewController () <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property(nonatomic, retain) UISearchController *searchController;

@end

@implementation RLXSearchTableViewController

#define IS_4_INCH_DISPLAY ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

- (void)viewDidLoad
{
    videoArray = [[NSMutableArray alloc] init];
    [self.tableView setContentInset:UIEdgeInsetsMake(16, 0, 16, 0)];
    
    //UISearchController
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleProminent;
    self.searchController.searchBar.scopeButtonTitles = @[];
    self.searchController.searchBar.tintColor = [UIColor whiteColor];
    self.definesPresentationContext = YES;
    [self.searchController.searchBar sizeToFit];
    self.navigationItem.searchController = self.searchController;
    
    //add activity indicator
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    [self navigationItem].rightBarButtonItem = barButton;
    
    [super viewDidLoad];
    
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    
    // A little trick for removing the cell separators
    self.tableView.tableFooterView = [UIView new];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.hidesSearchBarWhenScrolling = false;
}

- (void)viewDidAppear:(BOOL)animated
{
    self.navigationItem.hidesSearchBarWhenScrolling = true;
}

#pragma mark - Search
- (void)updateSearchResultsForSearchController:(nonnull UISearchController *)searchController
{
    //here, we do nothing.
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    //save search term to history
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"searchHistory"])
    {
        NSMutableArray *tempSearchHistoryArray = [[NSMutableArray alloc] init];
        [[NSUserDefaults standardUserDefaults] setObject:tempSearchHistoryArray forKey:@"searchHistory"];
    }
    
    NSMutableArray *searchHistoryArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"searchHistory"] mutableCopy];
    [searchHistoryArray addObject:self.searchController.searchBar.text];
    [[NSUserDefaults standardUserDefaults] setObject:searchHistoryArray forKey:@"searchHistory"];
    
    NSString *searchTerm = self.searchController.searchBar.text;
    
    //check for special commands
    if ([[searchTerm lowercaseString] containsString:@"#"])
    {
        //get the command
        NSString *command = [[searchTerm substringFromIndex:[searchTerm rangeOfString:@"#"].location + 1] lowercaseString];
        
        //check if the command is boolean
        BOOL isCommandBoolean;
        
        //remove any spaces from beginning and end of command
        while ([[command substringFromIndex:[command length] - 1] isEqualToString:@" "])
        {
            command = [command substringToIndex:[command length] - 1];
        }
        
        while ([[command substringToIndex:1] isEqualToString:@" "])
        {
            command = [command substringFromIndex:1];
        }
        
        if ([command containsString:@" "])
        {
            isCommandBoolean = NO;
        }
        else
        {
            isCommandBoolean = YES;
        }
        
        id commandValue = [[NSString alloc] init];
        if (!isCommandBoolean)
        {
            commandValue = [command substringFromIndex:[searchTerm rangeOfString:@" "].location];
        }
        
        [self specialCommandWithCommand:command andIsBoolean:isCommandBoolean withValue:commandValue];
    }
    
    //focus on ASMR content
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"asmr"] boolValue]) {
        if (![[searchTerm lowercaseString] containsString:@"asmr"])
        {
            if ([[searchTerm substringFromIndex:[searchTerm length] - 1] isEqualToString:@" "])
            {
                searchTerm = [searchTerm stringByAppendingString:@"asmr"];
            }
            else
            {
                searchTerm = [searchTerm stringByAppendingString:@" asmr"];
            }
        }
    }
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [activityIndicator startAnimating];
    [delegate.request getYouTubeSearchResultsWithoutAPIWithSearchTerm:searchTerm andCallback:^(NSMutableSet* returnedVideoList)
    {
        self->videoArray = [[returnedVideoList allObjects] mutableCopy];
        
        //refresh tableview on main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadEmptyDataSet];
            [self.tableView reloadData];
            [self->activityIndicator stopAnimating];
        });
    }];
}

- (void)specialCommandWithCommand:(NSString *)command andIsBoolean:(BOOL)isBoolean withValue:(id)value
{
    if (isBoolean)
    {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:command] boolValue] != YES)
        {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:command];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:command];
        }
    }
    else
    {
        NSMutableCharacterSet * decimalSet = [[NSMutableCharacterSet decimalDigitCharacterSet] mutableCopy];
        NSMutableCharacterSet * periodSet = [NSMutableCharacterSet characterSetWithCharactersInString:@"."];
        [decimalSet formUnionWithCharacterSet:periodSet];
        NSMutableCharacterSet * nonDecimalSet = [[decimalSet invertedSet] mutableCopy];
        if ([value rangeOfCharacterFromSet:nonDecimalSet].location == NSNotFound)
        {
            value = [NSNumber numberWithDouble:[value doubleValue]];
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:value forKey:command];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Empty set stuff
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    UIImage *imageToReturn;
    if (IS_4_INCH_DISPLAY)
    {
        imageToReturn = nil;
    }
    else
    {
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        imageToReturn = [delegate.request imageWithImage:[UIImage imageNamed:@"largesearchicon"] scaledToSize:CGSizeMake(200, 200)];
    }
    return imageToReturn;
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"Search";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"Please search for a video or channel";
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0f],
                                 NSForegroundColorAttributeName: [UIColor whiteColor],
                                 NSParagraphStyleAttributeName: paragraph};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [videoArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RLXSearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    // Configure the cell...
    //get thumbnail asynchronously
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // background download
        NSURL *url = [NSURL URLWithString:[self->videoArray[indexPath.row] objectAtIndex:1]];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *image = [[UIImage alloc] initWithData:data];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            // update UI elements on main thread
            cell.thumbnailImageView.image = image;
        });
    });
    
    
    //set values to the things in the cell
    cell.titleLabel.text = [videoArray[indexPath.row] objectAtIndex:2];
    cell.channelLabel.text = [videoArray[indexPath.row] objectAtIndex:3];
    
    
    cell.tag = indexPath.row;
    cell.downloadButton.tag = indexPath.row;
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *videoDirectory = [documentsDirectory stringByAppendingPathComponent:@"videos"];
    NSString *fullPath = [videoDirectory stringByAppendingPathComponent:[videoArray[indexPath.row][0] stringByAppendingString:@".mp4"]];
    
    if ([manager fileExistsAtPath:fullPath])
    {
        cell.downloadButton.hidden = YES;
    }
    
    [cell.downloadButton addTarget:self action:@selector(callActionSheetMethodWithVideoIdentifier:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)callActionSheetMethodWithVideoIdentifier:(UIButton *)sender
{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.request requestActionSheetForDownloadWithID:[videoArray[sender.tag] objectAtIndex:0] andTitle:[videoArray[sender.tag] objectAtIndex:2] andChannel:[videoArray[sender.tag] objectAtIndex:3] andThumbnailURL:[videoArray[sender.tag] objectAtIndex:1]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //go to the player, and pass it the necessary information
    int selectedIndex = (int)indexPath.row;
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    [delegate.mediaViewController stopVideo];
    
    NSMutableArray *downloadedVideosArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"downloadedVideos"];
    BOOL isCached;
    if ([downloadedVideosArray containsObject:[videoArray[indexPath.row] objectAtIndex:0]])
    {
        isCached = YES;
    }
    else
    {
        isCached = NO;
    }
    
    [delegate.mediaViewController setVideoInformationWithIdentifier:[videoArray[selectedIndex] objectAtIndex:0] andTitle:[videoArray[selectedIndex] objectAtIndex:2] andChannel:[videoArray[selectedIndex] objectAtIndex:3] andPlaylist:videoArray andCurrentIndexInPlaylist:selectedIndex andThumbailURL:[videoArray[selectedIndex] objectAtIndex:1] andResetPlayer:YES andIsCached:isCached];
    
    //doing it with this line crashes because the view controller is active in the Now Playing tab
    //[self presentViewController:delegate.mediaPlayerNavigationController animated:YES completion:nil];
    
    for (UIViewController *vc in self.tabBarController.viewControllers)
    {
        if (vc.tabBarItem.tag == 1)
        {
            [self.tabBarController setSelectedIndex:[self.tabBarController.viewControllers indexOfObject:vc]];
        }
    }
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
