//
//  RLXPlaylistTableViewController.m
//  Relax
//
//  Created by Justin Proulx on 2018-03-24.
//  Copyright © 2018 Low Budget Animation Studios. All rights reserved.
//

#import "RLXPlaylistTableViewController.h"
#import "RLXSearchTableViewCell.h"
#import "RLXSelectedPlaylistTableViewController.h"
#import "AppDelegate.h"
#import "UIScrollView+EmptyDataSet.h"
#import "BlackSFSafariViewController.h"
#import "JPOSUpdateChecker.h"

@interface RLXPlaylistTableViewController () <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@end

@implementation RLXPlaylistTableViewController
{
    JPOSUpdateChecker *updateChecker;
};

#define IS_4_INCH_DISPLAY ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

- (void)viewDidLoad
{
    [self refreshData];
    
    [self.tableView setContentInset:UIEdgeInsetsMake(16, 0, 16, 0)];
    
    [super viewDidLoad];
    
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    
    updateChecker = [JPOSUpdateChecker new];
    
    // A little trick for removing the cell separators
    self.tableView.tableFooterView = [UIView new];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
     [updateChecker checkForUpdatesAtURL:@"https://raw.githubusercontent.com/Sn0wCh1ld/Various-Files/master/TubePlayerAppInfo.plist" withAppName:@"Tube Player" andAppHost:@"GitHub" andHostURL:@"https://github.com/Sn0wCh1ld/Tube-Player"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self refreshData];
    [self noPirate];
}

- (void)noPirate
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"DevPirate"] boolValue])
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Notice" message:@"This application is not designed for piracy, and is rather meant to be used to easily download and share your own videos, or videos where the author has given permission to download. Please support content creators and do not pirate." preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:^{
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"DevPirate"];
        }];
    }
}

- (IBAction)help:(id)sender
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=JustinAlexP"] options:@{} completionHandler:nil];
    }
    else
    {
        BlackSFSafariViewController *safari = [[BlackSFSafariViewController alloc] initWithURL:[NSURL URLWithString:@"http://twitter.com/JustinAlexP"]];
        [self presentViewController:safari animated:YES completion:nil];
    }
}

- (IBAction)donate:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://paypal.me/Sn0wCh1ld"] options:@{} completionHandler:nil];
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
        imageToReturn = [delegate.request imageWithImage:[UIImage imageNamed:@"Relax"] scaledToSize:CGSizeMake(256, 256)];
    }
    return imageToReturn;
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"Tube Player";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"Welcome to Tube Player! If you like this app, please consider donating using the shopping cart button in the top left corner, so I can continue to make apps";
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0f],
                                 NSForegroundColorAttributeName: [UIColor whiteColor],
                                 NSParagraphStyleAttributeName: paragraph};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

#pragma mark - Other
- (void)refreshData
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"Playlists"])
    {
        playlistArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Playlists"] mutableCopy];
    }
    else
    {
        playlistArray = [[NSMutableArray alloc] init];
    }
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)newPlaylist:(id)sender
{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"New Playlist" message: @"Add a name to the new playlist" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Playlist Name";
     }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
    {
        NSArray * textfields = alertController.textFields;
        UITextField * nameField = textfields[0];
        NSMutableArray *playlists = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Playlists"] mutableCopy];
        if ([playlists count] == 0)
        {
            playlists = [[NSMutableArray alloc] init];
        }
        NSMutableArray *playlist = [[NSMutableArray alloc] init];
        [playlist addObject:nameField.text];
                                    
        BOOL nameExists = NO;
        for (NSMutableArray *playlist in playlists)
        {
            if ([playlist[0] isEqualToString:nameField.text])
            {
                nameExists = YES;
            }
        }
                                    
        if (nameExists != YES)
        {
            [playlists addObject:playlist];
        }
                                    
        [[NSUserDefaults standardUserDefaults] setObject:playlists forKey:@"Playlists"];
        [self refreshData];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [playlistArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RLXSearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.titleLabel.text = [[playlistArray objectAtIndex:indexPath.row] objectAtIndex:0];
    
    cell.titleLabel.textColor = [UIColor whiteColor];
    cell.tag = indexPath.row;
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //request the thumbnail
        UIImage * image;
        @try
        {
            NSDictionary *videoMetadataJSON = [delegate.request getVideoMetadataForVideoWithVideoID:[self->playlistArray[indexPath.row][1] objectForKey:@"videoID"]];
            NSString *stringToURL = videoMetadataJSON[@"thumbnail_url"];
            NSURL * url = [NSURL URLWithString:stringToURL];
            NSData * data = [NSData dataWithContentsOfURL:url];
            image = [[UIImage alloc] initWithData:data];
        }
        @catch (NSException *exception)
        {
            image = [UIImage imageNamed:@"Relax"];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.thumbnailImageView.image = image;
        });
    });
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        //delete the data
        [playlistArray removeObjectAtIndex:indexPath.row];
        [[NSUserDefaults standardUserDefaults] setObject:playlistArray forKey:@"Playlists"];
        
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"playlistsToPlaylist"])
    {
        NSMutableArray *selectedPlaylist = playlistArray[sender.tag];
        RLXSelectedPlaylistTableViewController *destinationVC = segue.destinationViewController;
        destinationVC.playlistArray = [selectedPlaylist mutableCopy];
    }
}

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
