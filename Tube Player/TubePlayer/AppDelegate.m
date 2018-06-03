//
//  AppDelegate.m
//  Relax
//
//  Created by Justin Proulx on 2018-03-10.
//  Copyright © 2018 Low Budget Animation Studios. All rights reserved.
//

#import "AppDelegate.h"
@import AVFoundation;
#import <XCDYouTubeKit/XCDYouTubeKit.h>
#import "PlayerEventLogger.h"
#import "MPMoviePlayerController+BackgroundPlayback.h"
#import "RLXVideoPlayerViewController.h"
#import "RLXRequest.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    InitializeAudioSession();
    
    [self setDefaultSettings];
    
    #pragma GCC diagnostic push
    #pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    [MPMoviePlayerController load];
    #pragma GCC diagnostic pop
    
    [self clearFailedDownloads];
    [self clearCancelledDownloads];
    
    
    _request = [RLXRequest new];
    
    return YES;
}

- (void)setDefaultSettings
{
    //downloading
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"devdl"])
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"devdl"];
    }
    
    //piracy notice
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"devpirate"])
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"devpirate"];
    }
    
    //asmr
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"asmr"])
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"asmr"];
    }
}

- (void)clearFailedDownloads
{
    NSMutableArray *videoDownloadArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"metadata"];
    NSMutableArray *tempVideoDownloadArray = [videoDownloadArray mutableCopy];
    for (NSMutableDictionary *dict in videoDownloadArray)
    {
        if ([dict[@"DLProgress"] doubleValue] < 1)
        {
            [tempVideoDownloadArray removeObject:dict];
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:tempVideoDownloadArray forKey:@"metadata"];
}

- (void)clearCancelledDownloads
{
    NSMutableArray *cancelArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"canceledDownloads"];
    NSMutableArray *tempCancelArray = [cancelArray mutableCopy];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *videoDirectory = [documentsDirectory stringByAppendingPathComponent:@"videos"];
    
    for (NSString *identifier in cancelArray)
    {
        NSString *fullPath = [[videoDirectory stringByAppendingPathComponent:identifier] stringByAppendingString:@".mp4"];
        NSError *error;
        
        if ([manager fileExistsAtPath:fullPath])
        {
            [manager removeItemAtPath:fullPath error:&error];
        }
        
        [tempCancelArray removeObject:identifier];
    }
    
    cancelArray = tempCancelArray;
    
    [[NSUserDefaults standardUserDefaults] setObject:cancelArray forKey:@"canceledDownloads"];
    
}

- (UINavigationController *)mediaPlayerNavigationController
{
    if (_mediaPlayerNavigationController != nil)
    {
        return _mediaPlayerNavigationController;
    }
    // initialize view controller (for a storyboard, you'd do it like so, making sure your storyboard filename and view controller identifier are set properly):
    _mediaPlayerNavigationController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"VideoPlayer"];
    return _mediaPlayerNavigationController;
}

- (RLXVideoPlayerViewController *)mediaViewController
{
    return (RLXVideoPlayerViewController *)self.mediaPlayerNavigationController.topViewController;
}

static void InitializeAudioSession(void)
{
    NSError *error = nil;
    BOOL success = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (!success)
    {
        NSLog(@"Audio Session Category error: %@", error);
    }
}

- (instancetype) init
{
    if (!(self = [super init]))
        return nil;
    
    _playerEventLogger = [PlayerEventLogger new];
    
    return self;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
}

@end
