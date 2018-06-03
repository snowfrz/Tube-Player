//
//  RLXSelectedPlaylistTableViewController.m
//  Relax
//
//  Created by Justin Proulx on 2018-04-02.
//  Copyright © 2018 Low Budget Animation Studios. All rights reserved.
//

#import "RLXSelectedPlaylistTableViewController.h"
#import "RLXSearchTableViewCell.h"
#import "RLXRequest.h"
#import "AppDelegate.h"

@interface RLXSelectedPlaylistTableViewController ()

@end

@implementation RLXSelectedPlaylistTableViewController

- (void)viewDidLoad
{
    self.title = _playlistArray[0];
    
    [self.tableView setContentInset:UIEdgeInsetsMake(16, 0, 16, 0)];
    
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_playlistArray count] - 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RLXSearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    // Configure the cell...
    //get thumbnail
    NSString *stringToURL = [_playlistArray[indexPath.row + 1] objectForKey:@"thumbnail"];
    NSURL *url = [NSURL URLWithString:stringToURL];
    //get the URL for the thumbnail if it originally failed
    if ([stringToURL length] == 0)
    {
        //request the thumbnail
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        NSDictionary *videoMetadataJSON = [delegate.request getVideoMetadataForVideoWithVideoID:[_playlistArray[indexPath.row + 1] objectForKey:@"videoID"]];
        stringToURL = videoMetadataJSON[@"thumbnail_url"];
        url = [NSURL URLWithString:stringToURL];
        
        //save the info back to disk, by updating the hierarchy of arrays and stuff
        NSMutableArray *playlistsArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Playlists"] mutableCopy];
        int playlistIndex = (int)[playlistsArray indexOfObject:_playlistArray];
        
        NSMutableDictionary *videoDict = [_playlistArray[indexPath.row + 1] mutableCopy];
        
        [videoDict setObject:stringToURL forKey:@"thumbnail"];
        
        [_playlistArray replaceObjectAtIndex:indexPath.row+1 withObject:[videoDict copy]];
        
        [playlistsArray replaceObjectAtIndex:playlistIndex withObject:[_playlistArray copy]];
        
        [[NSUserDefaults standardUserDefaults] setValue:[playlistsArray copy] forKey:@"Playlists"];
    }
    
    
    //set values to the things in the cell
    cell.titleLabel.text = [_playlistArray[indexPath.row + 1] objectForKey:@"videoTitle"];
    cell.channelLabel.text = [_playlistArray[indexPath.row + 1] objectForKey:@"channelName"];
    
    //get the thumbnail image asynchronously
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *image = [[UIImage alloc] initWithData:data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.thumbnailImageView.image = image;
        });
    });
    
    cell.downloadButton.tag = indexPath.row + 1;
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *videoDirectory = [documentsDirectory stringByAppendingPathComponent:@"videos"];
    NSString *fullPath = [[videoDirectory stringByAppendingPathComponent:[_playlistArray[indexPath.row + 1] objectForKey:@"videoID"]] stringByAppendingString:@".mp4"];
    
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
    [delegate.request requestActionSheetForDownloadWithID:[_playlistArray[sender.tag] objectForKey:@"videoID"] andTitle:[_playlistArray[sender.tag] objectForKey:@"videoTitle"] andChannel:[_playlistArray[sender.tag] objectForKey:@"channelName"] andThumbnailURL:[_playlistArray[sender.tag] objectForKey:@"thumbnail"]];
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSMutableArray *playlistsArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Playlists"] mutableCopy];
        int playlistIndex = (int)[playlistsArray indexOfObject:_playlistArray];
        
        [_playlistArray removeObjectAtIndex:indexPath.row + 1];
        [playlistsArray replaceObjectAtIndex:playlistIndex withObject:_playlistArray];
        
        [[NSUserDefaults standardUserDefaults] setObject:playlistsArray forKey:@"Playlists"];
        
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
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
    if ([downloadedVideosArray containsObject:[_playlistArray[indexPath.row + 1] objectForKey:@"videoID"]])
    {
        isCached = YES;
    }
    else
    {
        isCached = NO;
    }
    
    //reformat the array for the player
    NSMutableArray *playlistArrayToSend = [[NSMutableArray alloc] init];
    for (NSDictionary *video in _playlistArray)
    {
        if ([_playlistArray indexOfObject:video] > 0)
        {
            NSMutableArray *arrayToAdd = [[NSMutableArray alloc] init];
            [arrayToAdd addObject:video[@"videoID"]];
            if (video[@"thumbnail"])
            {
                [arrayToAdd addObject:video[@"thumbnail"]];
            }
            else
            {
                [arrayToAdd addObject:@"N/A"];
            }
            [arrayToAdd addObject:video[@"videoTitle"]];
            [arrayToAdd addObject:video[@"channelName"]];
            [playlistArrayToSend addObject:arrayToAdd];
        }
    }
    
    [delegate.mediaViewController setVideoInformationWithIdentifier:[_playlistArray[indexPath.row + 1] objectForKey:@"videoID"] andTitle:[_playlistArray[indexPath.row + 1] objectForKey:@"videoTitle"] andChannel:[_playlistArray[indexPath.row + 1] objectForKey:@"channelName"] andPlaylist:playlistArrayToSend andCurrentIndexInPlaylist:selectedIndex andThumbailURL:[_playlistArray[indexPath.row + 1] objectForKey:@"thumbnail"] andResetPlayer:YES andIsCached:isCached];
    
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
