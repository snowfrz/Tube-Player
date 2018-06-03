//
//  RLXDownloadTrackerTableViewController.m
//  Relax
//
//  Created by Justin Proulx on 2018-03-14.
//  Copyright © 2018 Low Budget Animation Studios. All rights reserved.
//

#import "RLXDownloadTrackerTableViewController.h"
#import "RLXSearchTableViewCell.h"
#import "RLXRequest.h"
#import "AppDelegate.h"
#import "UIScrollView+EmptyDataSet.h"

@interface RLXDownloadTrackerTableViewController () <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@end

@implementation RLXDownloadTrackerTableViewController

#define IS_4_INCH_DISPLAY ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

- (void)viewDidLoad
{
    _downloadedVideosArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"metadata"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateData:) name:@"DownloadProgressed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTabBadge:) name:@"UpdateBadge" object:nil];
    [self.tableView setContentInset:UIEdgeInsetsMake(16, 0, 16, 0)];
    
    [super viewDidLoad];
    
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self updateData:nil];
}

- (void)updateData:(NSNotification *)notification
{
    _downloadedVideosArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"metadata"];
    [self.tableView reloadData];
}

- (void)updateTabBadge:(NSNotification *)notification
{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if ([delegate.request.downloadQueue count] > 0)
    {
        [[self navigationController] tabBarItem].badgeValue = [NSString stringWithFormat:@"%lu", (unsigned long)[delegate.request.downloadQueue count]];
    }
    else
    {
        [[self navigationController] tabBarItem].badgeValue = nil;
    }
}

- (void)didReceiveMemoryWarning {
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
        imageToReturn = [delegate.request imageWithImage:[UIImage imageNamed:@"Relax"] scaledToSize:CGSizeMake(256, 256)];
    }
    return imageToReturn;
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"Downloads";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"You have no downloaded videos. When you begin downloading a video, it will appear here.";
    
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
    return [_downloadedVideosArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RLXSearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    // Configure the cell...
    //get thumbnail
    NSURL *url = [NSURL URLWithString:[_downloadedVideosArray[indexPath.row] objectForKey:@"thumbnail"]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *image = [[UIImage alloc] initWithData:data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.thumbnailImageView.image = image;
        });
    });
    
    //set values to the things in the cell
    cell.titleLabel.text = [_downloadedVideosArray[indexPath.row] objectForKey:@"Title"];
    cell.channelLabel.text = [_downloadedVideosArray[indexPath.row] objectForKey:@"Channel"];
    
    cell.tag = indexPath.row;
    
    if ([[_downloadedVideosArray[indexPath.row] objectForKey:@"DLProgress"] doubleValue] < 1)
    {
        [cell.progressBar setProgress:[[_downloadedVideosArray[indexPath.row] objectForKey:@"DLProgress"] doubleValue] animated:YES];
        cell.downloadComplete.hidden = YES;
        cell.shareButton.hidden = YES;
    }
    else
    {
        cell.progressBar.hidden = YES;
        cell.shareButton.hidden = NO;
    }
    
    cell.shareButton.tag = indexPath.row;
    [cell.shareButton addTarget:self action:@selector(exportVideoWithSender:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        if ([[_downloadedVideosArray[indexPath.row] objectForKey:@"DLProgress"] doubleValue] == 1)
        {
            //delete the associated file
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
            NSString *videoDirectory = [documentsDirectory stringByAppendingPathComponent:@"videos"];
            NSString *fullPath = [[videoDirectory stringByAppendingPathComponent:[[_downloadedVideosArray objectAtIndex:indexPath.row] objectForKey:@"ID"]] stringByAppendingString:@".mp4"];
            NSError *error;
            
            if ([fileManager fileExistsAtPath:fullPath])
            {
                [fileManager removeItemAtPath:fullPath error:&error];
            }

        }
        else
        {
            AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [delegate.request cancelDownloadWithIdentifier:[[_downloadedVideosArray objectAtIndex:indexPath.row] objectForKey:@"ID"]];
        }
        
        //delete cached confirmation while the metadata still exists
        NSMutableArray *cachedVideos = [[[NSUserDefaults standardUserDefaults] objectForKey:@"downloadedVideos"] mutableCopy];
        if ([cachedVideos containsObject:[[_downloadedVideosArray objectAtIndex:indexPath.row] objectForKey:@"ID"]])
        {
            if ([cachedVideos count] > 1)
            {
                [cachedVideos removeObject:[[_downloadedVideosArray objectAtIndex:indexPath.row] objectForKey:@"ID"]];
            }
            else
            {
                cachedVideos = nil;
            }
            
        }
        [[NSUserDefaults standardUserDefaults] setObject:cachedVideos forKey:@"downloadedVideos"];
        
        
        //delete the metadata
        NSMutableArray *tempDownloadedVideosArray = [_downloadedVideosArray mutableCopy];
        [tempDownloadedVideosArray removeObjectAtIndex:indexPath.row];
        _downloadedVideosArray = tempDownloadedVideosArray;
        //save the new metadata
        [[NSUserDefaults standardUserDefaults] setObject:_downloadedVideosArray forKey:@"metadata"];
        
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [tableView reloadData];
        [self updateTabBadge:nil];
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
    if ([downloadedVideosArray containsObject:[_downloadedVideosArray[indexPath.row] objectForKey:@"ID"]])
    {
        isCached = YES;
    }
    else
    {
        isCached = NO;
    }
    
    NSMutableArray *playerPlaylist = [self convertDownloadPlaylistToPlayerPlaylistWithPlaylist:_downloadedVideosArray];
    
    [delegate.mediaViewController setVideoInformationWithIdentifier:[_downloadedVideosArray[selectedIndex] objectForKey:@"ID"] andTitle:[_downloadedVideosArray[selectedIndex] objectForKey:@"Title"] andChannel:[_downloadedVideosArray[selectedIndex] objectForKey:@"Channel"] andPlaylist:playerPlaylist andCurrentIndexInPlaylist:selectedIndex andThumbailURL:[_downloadedVideosArray[selectedIndex] objectForKey:@"thumbnail"] andResetPlayer:YES andIsCached:isCached];
    
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

#pragma mark - Other stuff

- (NSMutableArray *)convertDownloadPlaylistToPlayerPlaylistWithPlaylist:(NSMutableArray *)playlist
{
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    
    for (NSDictionary * dict in playlist)
    {
        NSMutableArray *videoArray = [[NSMutableArray alloc] init];
        
        videoArray[0] = [[playlist objectAtIndex:[playlist indexOfObject:dict]] objectForKey:@"ID"];
        videoArray[1] = [[playlist objectAtIndex:[playlist indexOfObject:dict]] objectForKey:@"thumbnail"];
        videoArray[2] = [[playlist objectAtIndex:[playlist indexOfObject:dict]] objectForKey:@"Title"];
        videoArray[3] = [[playlist objectAtIndex:[playlist indexOfObject:dict]] objectForKey:@"Channel"];
        
        [returnArray addObject:videoArray];
    }
    
    return returnArray;
}

- (void)exportVideoWithSender:(UIButton *)sender
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *path = [[[documentsDirectory stringByAppendingPathComponent:@"videos"] stringByAppendingPathComponent:[_downloadedVideosArray objectAtIndex:sender.tag][@"ID"]] stringByAppendingPathExtension:@"mp4"];
    
    NSString *videoLink = [@"https://www.youtube.com/watch?v=" stringByAppendingString:[_downloadedVideosArray objectAtIndex:sender.tag][@"ID"]];
    
    NSURL *url = [NSURL fileURLWithPath:path];
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[url, videoLink] applicationActivities:nil];
    
    // Present the controller
    [self presentViewController:controller animated:YES completion:nil];
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
