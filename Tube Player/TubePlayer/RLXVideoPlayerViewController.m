//
//  RLXVideoPlayerViewController.m
//  Relax
//
//  Created by Justin Proulx on 2018-03-12.
//  Copyright © 2018 Low Budget Animation Studios. All rights reserved.
//

#import "RLXVideoPlayerViewController.h"
#import "RLXSearchTableViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "MPMoviePlayerController+BackgroundPlayback.h"
#import "RLXRequest.h"
#import "AppDelegate.h"

@interface RLXVideoPlayerViewController ()

@end

@implementation RLXVideoPlayerViewController

- (void)viewDidLoad
{
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [defaultCenter addObserver:self selector:@selector(moviePlayerPlaybackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    #pragma clang diagnostic pop
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //hide download features
    BOOL canDownload = [[[NSUserDefaults standardUserDefaults] objectForKey:@"devdl"] boolValue];
    if (canDownload != YES)
    {
        [self.navigationItem setLeftBarButtonItem:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([playlistArray count] > 0)
    {
        if (doesResetPlayer)
        {
            [self loadVideo];
            
            //don't reset until the next time it is specified
            doesResetPlayer = NO;
            
            pausePlayButton.enabled = YES;
        }
    }
    else
    {
        previousVideoButton.enabled = NO;
        skipVideoButton.enabled = NO;
        pausePlayButton.enabled = NO;
        titleLabel.text = @"No video loaded";
        channelLabel.text = @"Please select a video";
    }
}

- (void)loadVideo
{
    if (playlistIndex == 0)
    {
        previousVideoButton.enabled = NO;
    }
    else
    {
        previousVideoButton.enabled = YES;
    }
    
    if (playlistIndex >= [playlistArray count] - 1)
    {
        skipVideoButton.enabled = NO;
    }
    else
    {
        skipVideoButton.enabled = YES;
    }
    
    //set up player
    videoPlayerViewController = nil;
    if (!isOffline)
    {
        videoPlayerViewController = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:videoID];
        offlineLabel.hidden = YES;
    }
    else
    {
        NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *videoDirectory = [documentsDirectory stringByAppendingPathComponent:@"videos"];
        NSString *fullPath = [[videoDirectory stringByAppendingPathComponent:videoID] stringByAppendingString:@".mp4"];
        videoPlayerViewController = [[XCDYouTubeVideoPlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:fullPath]];
        offlineLabel.hidden = NO;
    }
    
    
    //set up background play
    videoPlayerViewController.moviePlayer.backgroundPlaybackEnabled = YES;
    
    [videoPlayerViewController presentInView:videoView];
    [videoPlayerViewController.moviePlayer play];
    
    titleLabel.text = videoTitle;
    channelLabel.text = channelName;
    
    pausePlayButton.imageView.image = [UIImage imageNamed:@"pause"];
    
    //save video id to history
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"viewingHistory"])
    {
        NSMutableArray *tempHistoryArray = [[NSMutableArray alloc] init];
        [[NSUserDefaults standardUserDefaults] setObject:tempHistoryArray forKey:@"viewingHistory"];
    }
    
    NSMutableArray *historyArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"viewingHistory"] mutableCopy];
    [historyArray addObject:videoID];
    [[NSUserDefaults standardUserDefaults] setObject:historyArray forKey:@"viewingHistory"];
}

- (void)setVideoInformationWithIdentifier:(NSString *)identifier andTitle:(NSString *)title andChannel:(NSString *)channel andPlaylist:(NSMutableArray *)playlist andCurrentIndexInPlaylist:(int)indexInArray andThumbailURL:(NSString *)thumbnailAddress andResetPlayer:(BOOL)resetPlayer andIsCached:(BOOL)isCached
{
    videoID = identifier;
    videoTitle = title;
    channelName = channel;
    playlistArray = playlist;
    NSLog(@"%@", playlistArray);
    playlistIndex = indexInArray;
    thumbnailURL = thumbnailAddress;
    doesResetPlayer = resetPlayer;
    isOffline = isCached;
    
    self.title = @"Now Playing";
}

- (void)stopVideo
{
    //kinda bootleg
    @try
    {
        //the correct code
        [videoPlayerViewController.moviePlayer stop];
    }
    @catch (NSException *exception)
    {
        //for some reason, the normal one crashes if you play an online video right after an offline one, so this will do for now.
        [videoPlayerViewController.moviePlayer pause];
        videoPlayerViewController = nil;
    }
}

- (void) moviePlayerPlaybackDidFinish:(NSNotification *)notification
{
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
    MPMovieFinishReason finishReason = [notification.userInfo[MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] integerValue];
    if (finishReason == MPMovieFinishReasonPlaybackEnded)
    {
        if ([videoPlayerViewController.moviePlayer endPlaybackTime] <= 0)
        {
            [videoPlayerViewController.moviePlayer setFullscreen:NO animated:YES];
            
            if (playlistIndex < [playlistArray count] - 1)
            {
                [self skipVideo:nil];
            }
        }
    }
    #pragma clang diagnostic pop
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)videoPlayingStatus
{
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (videoPlayerViewController.moviePlayer.playbackState == MPMoviePlaybackStatePlaying)
    {
        return YES;
    }
    else
    {
        return NO;
    }
    #pragma clang diagnostic pop
}

- (void)setPlayPauseButtonWithStatus:(BOOL)status
{
    NSString *imageFileName;
    if (status)
    {
        imageFileName = @"pause";
    }
    else
    {
        imageFileName = @"play";
    }
    
    pausePlayButton.imageView.image = [UIImage imageNamed:imageFileName];
}

- (void)playPauseFromStatus:(BOOL)status
{
    //pause if it is, play if it's not
    if (status)
    {
        [videoPlayerViewController.moviePlayer pause];
    }
    else
    {
        [videoPlayerViewController.moviePlayer play];
    }
}

- (IBAction)playPause:(id)sender
{
    //change the playing state
    [self playPauseFromStatus:[self videoPlayingStatus]];
    
    //set the button image from the new status
    [self setPlayPauseButtonWithStatus:[self videoPlayingStatus]];
}

- (IBAction)previousVideo:(id)sender
{
    [videoPlayerViewController.moviePlayer stop];
    
    if (playlistIndex > 0)
    {
        playlistIndex--;
    }
    
    [self updateParametersAndReloadVideo];
}

- (IBAction)skipVideo:(id)sender
{
    [videoPlayerViewController.moviePlayer stop];
    
    if (playlistIndex < [playlistArray count] - 1)
    {
        playlistIndex++;
    }
    
    [self updateParametersAndReloadVideo];
}

- (void)updateParametersAndReloadVideo
{
    videoID = [playlistArray[playlistIndex] objectAtIndex:0];
    videoTitle = [playlistArray[playlistIndex] objectAtIndex:2];
    channelName = [playlistArray[playlistIndex] objectAtIndex:3];
    self.title = @"Now Playing";
    
    [self loadVideo];
}

- (IBAction)downloadCurrentVideo:(id)sender
{
    if ([playlistArray count] > 0)
    {
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate.request requestActionSheetForDownloadWithID:videoID andTitle:videoTitle andChannel:channelName andThumbnailURL:thumbnailURL];
    }
    else
    {
        [self notifyOfLackOfPlayingVideo];
    }
}

- (IBAction)addToPlaylist:(id)sender
{
    if ([playlistArray count] > 0)
    {
        //create an alert to ask if you want to select a new or existing playlist
        UIAlertAction *existingAction = [UIAlertAction actionWithTitle:@"Existing" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
        {
            NSMutableArray *actions = [[NSMutableArray alloc] init];
            NSMutableArray *playlists = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Playlists"] mutableCopy];
            NSMutableArray *playlistsCopy = [playlists mutableCopy];
            for (NSMutableArray *playlist in playlistsCopy)
            {
                //first object in the playlist is reserved for the playlist name. probably should have set it to a metadata array or something but oh well, i didn't.
                //show existing playlists
                UIAlertAction *selectionAction = [UIAlertAction actionWithTitle:[playlist objectAtIndex:0] style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                {
                    NSMutableArray *playlistCopy = [playlist mutableCopy];
                    NSDictionary *itemToAdd = [[NSDictionary alloc] initWithObjectsAndKeys:self->videoID, @"videoID", self->videoTitle, @"videoTitle", self->channelName, @"channelName", self->thumbnailURL, @"thumbnail", nil];
                    [playlistCopy addObject:itemToAdd];
                    [playlists replaceObjectAtIndex:[playlists indexOfObject:playlist] withObject:playlistCopy];
                    [[NSUserDefaults standardUserDefaults] setObject:playlists forKey:@"Playlists"];
                }];
                [actions addObject:selectionAction];
            }
                                             
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
            [actions addObject:cancelAction];
            [self putUpAlertWithTitle:@"Choose a playlist" andMessage:@"" withActions:actions];
        }];
        UIAlertAction *newAction = [UIAlertAction actionWithTitle:@"New" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
        {
            UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"New Playlist" message: @"Add a name to the new playlist" preferredStyle:UIAlertControllerStyleAlert];
            [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
            {
                textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
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
                NSDictionary *itemToAdd = [[NSDictionary alloc] initWithObjectsAndKeys:self->videoID, @"videoID", self->videoTitle, @"videoTitle", self->channelName, @"channelName", nil];
                [playlist addObject:nameField.text];
                [playlist addObject:itemToAdd];
                
                //if the playlist already exists, just add the video to it
                BOOL nameExists = NO;
                for (NSMutableArray *playlist in playlists)
                {
                    if ([playlist[0] isEqualToString:nameField.text])
                    {
                        nameExists = YES;
                        [playlist addObject:itemToAdd];
                    }
                }
                
                if (nameExists != YES)
                {
                    [playlists addObject:playlist];
                }
                
                [[NSUserDefaults standardUserDefaults] setObject:playlists forKey:@"Playlists"];
            }]];
            [self presentViewController:alertController animated:YES completion:nil];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        NSMutableArray *actions = [NSMutableArray arrayWithObjects:existingAction, newAction, cancelAction, nil];
        [self putUpAlertWithTitle:@"Playlist selection" andMessage:@"Would you like to use an existing playlist or a new one?" withActions:actions];
    }
    else
    {
        [self notifyOfLackOfPlayingVideo];
    }
}

- (void)notifyOfLackOfPlayingVideo
{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"No video loaded" message: @"Please choose a video before adding it to a playlist or downloading it." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)putUpAlertWithTitle:(NSString *)title andMessage:(NSString *)message withActions:(NSMutableArray *)actionArray
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    for (UIAlertAction *action in actionArray)
    {
        [alert addAction:action];
    }
    
    [self presentViewController:alert animated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
