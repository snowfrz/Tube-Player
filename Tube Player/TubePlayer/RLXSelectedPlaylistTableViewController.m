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
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)EditTitle:(id)sender
{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Edit Playlist Name" message: @"Change this playlist's name" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
         textField.placeholder = self->_playlistArray[0];
     }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                {
                                    NSArray * textfields = alertController.textFields;
                                    UITextField * nameField = textfields[0];
                                    NSString *userInput = nameField.text;
                                    
                                    NSMutableArray *playlists = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Playlists"] mutableCopy];
                                    
                                    //if the playlist already exists, just add the video to it
                                    BOOL nameExists = NO;
                                    for (NSMutableArray *playlist in playlists)
                                    {
                                        NSString *title = playlist[0];
                                        if ([title isEqualToString:userInput])
                                        {
                                            nameExists = YES;
                                        }
                                    }
                                    
                                    int playlistIndex = (int)[playlists indexOfObject:self->_playlistArray];
                                    
                                    if (nameExists != YES)
                                    {
                                        NSMutableArray *playlist = [playlists[playlistIndex] mutableCopy];
                                        [playlist replaceObjectAtIndex:0 withObject:userInput];
                                        [playlists replaceObjectAtIndex:playlistIndex withObject:playlist];
                                    }
                                    else
                                    {
                                        UIAlertController *anotherAlert = [UIAlertController alertControllerWithTitle:@"Playlist name exists already" message:@"Please choose another playlist name" preferredStyle:UIAlertControllerStyleAlert];
                                        [anotherAlert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                                        [self presentViewController:anotherAlert animated:YES completion:nil];
                                    }
                                    
                                    [[NSUserDefaults standardUserDefaults] setObject:playlists forKey:@"Playlists"];
                                    
                                    self->_playlistArray =  [[[NSUserDefaults standardUserDefaults] objectForKey:@"Playlists"] objectAtIndex:playlistIndex];
                                    
                                    self.title = self->_playlistArray[0];
                                }]];
    [self presentViewController:alertController animated:YES completion:nil];
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
    
    [self reformatArrayWithArray:_playlistArray andSelectedIndex:selectedIndex];
}

- (IBAction)ShuffleVideos:(id)sender
{
    NSMutableArray *shuffleSet = [[NSMutableArray alloc] init];
    
    int maxInt = (int)[_playlistArray count];
    
    NSMutableArray *usedNumbers = [[NSMutableArray alloc] init];
    [usedNumbers addObject:[NSNumber numberWithInt:0]];
    [shuffleSet addObject:_playlistArray[0]];
    
    for (int i = 1; i < maxInt; i++)
    {
        int chosenVideo;
        do
        {
           chosenVideo = arc4random_uniform(maxInt);
        }
        while ([usedNumbers containsObject:[NSNumber numberWithInt:chosenVideo]]);
        
        [usedNumbers addObject:[NSNumber numberWithInt:chosenVideo]];
        [shuffleSet addObject:[_playlistArray objectAtIndex:chosenVideo]];
    }
    
    [self reformatArrayWithArray:shuffleSet andSelectedIndex:0];
}

- (void)reformatArrayWithArray:(NSMutableArray *)videoListArray andSelectedIndex:(int)selectedIndex
{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    [delegate.mediaViewController stopVideo];
    
    NSMutableArray *downloadedVideosArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"downloadedVideos"];
    BOOL isCached;
    if ([downloadedVideosArray containsObject:[videoListArray[selectedIndex + 1] objectForKey:@"videoID"]])
    {
        isCached = YES;
    }
    else
    {
        isCached = NO;
    }
    
    //reformat the array for the player
    NSMutableArray *playlistArrayToSend = [[NSMutableArray alloc] init];
    for (NSDictionary *video in videoListArray)
    {
        if ([videoListArray indexOfObject:video] > 0)
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
    
    [delegate.mediaViewController setVideoInformationWithIdentifier:[videoListArray[selectedIndex + 1] objectForKey:@"videoID"] andTitle:[videoListArray[selectedIndex+ 1] objectForKey:@"videoTitle"] andChannel:[videoListArray[selectedIndex + 1] objectForKey:@"channelName"] andPlaylist:playlistArrayToSend andCurrentIndexInPlaylist:selectedIndex andThumbailURL:[videoListArray[selectedIndex + 1] objectForKey:@"thumbnail"] andResetPlayer:YES andIsCached:isCached];
    
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
