//
//  RLXVideoPlayerViewController.h
//  Relax
//
//  Created by Justin Proulx on 2018-03-12.
//  Copyright © 2018 Low Budget Animation Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCDYouTubeKit/XCDYouTubeKit.h>

@interface RLXVideoPlayerViewController : UIViewController
{
    NSString *videoID;
    NSString *videoTitle;
    NSString *channelName;
    NSMutableArray *playlistArray;
    int playlistIndex;
    NSString *thumbnailURL;
    BOOL doesResetPlayer;
    BOOL isOffline;
    
    IBOutlet UIView *videoView;
    
    IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *channelLabel;
    
    IBOutlet UILabel *offlineLabel;
    
    XCDYouTubeVideoPlayerViewController *videoPlayerViewController;
    
    IBOutlet UIButton *previousVideoButton;
    IBOutlet UIButton *skipVideoButton;
    IBOutlet UIButton *pausePlayButton;
    
    IBOutlet UIBarButtonItem *downloadButton;
}

- (void)setVideoInformationWithIdentifier:(NSString *)identifier andTitle:(NSString *)title andChannel:(NSString *)channel andPlaylist:(NSMutableArray *)playlist andCurrentIndexInPlaylist:(int)indexInArray andThumbailURL:(NSString *)thumbnailAddress andResetPlayer:(BOOL)resetPlayer andIsCached:(BOOL)isCached;
- (void)stopVideo;
- (void)loadVideo;

- (IBAction)playPause:(id)sender;


@end
