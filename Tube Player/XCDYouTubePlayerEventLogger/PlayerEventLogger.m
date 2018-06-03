//
//  Copyright (c) 2013-2016 Cédric Luthi. All rights reserved.
//

#import "PlayerEventLogger.h"
#import "RLXVideoPlayerViewController.h"

@import MediaPlayer;

@implementation PlayerEventLogger

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"


- (instancetype) init
{
	if (!(self = [super init]))
		return nil;
	
	self.enabled = YES;
	
	return self;
}

- (void) setEnabled:(BOOL)enabled
{
	if (_enabled == enabled)
		return;
	
	_enabled = enabled;
	
	NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
	if (enabled)
	{
		[defaultCenter addObserver:self selector:@selector(moviePlayerPlaybackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
		[defaultCenter addObserver:self selector:@selector(moviePlayerPlaybackStateDidChange:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
		[defaultCenter addObserver:self selector:@selector(moviePlayerLoadStateDidChange:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
		[defaultCenter addObserver:self selector:@selector(moviePlayerNowPlayingMovieDidChange:) name:MPMoviePlayerNowPlayingMovieDidChangeNotification object:nil];
	}
	else
	{
        [defaultCenter removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
		[defaultCenter removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
		[defaultCenter removeObserver:self name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
		[defaultCenter removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
		[defaultCenter removeObserver:self name:MPMoviePlayerNowPlayingMovieDidChangeNotification object:nil];
	}
}

- (void) moviePlayerPlaybackDidFinish:(NSNotification *)notification
{
	MPMovieFinishReason finishReason = [notification.userInfo[MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] integerValue];
	NSString *reason = @"Unknown";
	switch (finishReason)
	{
		case MPMovieFinishReasonPlaybackEnded:
			reason = @"Playback Ended";
			break;
		case MPMovieFinishReasonPlaybackError:
			reason = @"Playback Error";
			break;
		case MPMovieFinishReasonUserExited:
			reason = @"User Exited";
			break;
	}
}

- (void) moviePlayerPlaybackStateDidChange:(NSNotification *)notification
{
	MPMoviePlayerController *moviePlayerController = notification.object;
	NSString *playbackState = @"Unknown";
	switch (moviePlayerController.playbackState)
	{
		case MPMoviePlaybackStateStopped:
			playbackState = @"Stopped";
			break;
		case MPMoviePlaybackStatePlaying:
			playbackState = @"Playing";
			break;
		case MPMoviePlaybackStatePaused:
			playbackState = @"Paused";
            NSTimeInterval start = CACurrentMediaTime();
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:start] forKey:@"lastPause"];
			break;
		case MPMoviePlaybackStateInterrupted:
			playbackState = @"Interrupted";
			break;
		case MPMoviePlaybackStateSeekingForward:
			playbackState = @"Seeking Forward";
			break;
		case MPMoviePlaybackStateSeekingBackward:
			playbackState = @"Seeking Backward";
			break;
    }
    
    //RLXVideoPlayerViewController *videoPlayerVC = [RLXVideoPlayerViewController new];
}

- (void) moviePlayerLoadStateDidChange:(NSNotification *)notification
{
	MPMoviePlayerController *moviePlayerController = notification.object;
	
	NSMutableString *loadState = [NSMutableString new];
	MPMovieLoadState state = moviePlayerController.loadState;
	if (state & MPMovieLoadStatePlayable)
		[loadState appendString:@" | Playable"];
	if (state & MPMovieLoadStatePlaythroughOK)
		[loadState appendString:@" | Playthrough OK"];
	if (state & MPMovieLoadStateStalled)
		[loadState appendString:@" | Stalled"];
	
}

- (void) moviePlayerNowPlayingMovieDidChange:(NSNotification *)notification
{
	//MPMoviePlayerController *moviePlayerController = notification.object;
}
#pragma clang diagnostic pop
@end
