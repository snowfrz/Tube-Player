//
//  JPOSUpdateChecker.m
//  Tube Player
//
//  Created by Justin Proulx on 2018-06-02.
//  Copyright © 2018 Low Budget Animation Studios. All rights reserved.
//

#import "JPOSUpdateChecker.h"

@implementation JPOSUpdateChecker

- (void)checkForUpdatesAtURL:(NSString *)appInfoPlistURL withAppName:(NSString *)appName andAppHost:(NSString *)appHost andHostURL:(NSString *)hostURL
{
    NSData *appInfoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:appInfoPlistURL]];
    
    if (appInfoData)
    {
        //get documents directory
        NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"appinfo.plist"];
        [appInfoData writeToFile:filePath atomically:YES];
        
        NSDictionary *appInfoDictionary = [NSDictionary dictionaryWithContentsOfFile:filePath];
        
        NSString *latestVersion = appInfoDictionary[@"Version"];
        NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        
        if ([latestVersion compare:currentVersion options:NSNumericSearch] == NSOrderedDescending)
        {
            // latest version is higher than the current version
            // don't change versionning convention from major.minor.increment
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Update Available" message:[[[[[[@"A new version of " stringByAppendingString:appName] stringByAppendingString:@" has been released. Please download version "] stringByAppendingString:latestVersion] stringByAppendingString:@" from "] stringByAppendingString:appHost] stringByAppendingString:@" and install it using Impactor"] preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *githubLinkButtonAction = [UIAlertAction actionWithTitle:@"GitHub" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:hostURL] options:@{} completionHandler:nil];
            }];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
            [alert addAction:githubLinkButtonAction];
            [[self getTopController] presentViewController:alert animated:YES completion:nil];
        }
    }
}

- (UIViewController *)getTopController
{
    //necessary stuff to show an alert from an NSObject subclass
    //finds the current view controller
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    //honestly not quire sure what this does
    while (topController.presentedViewController)
    {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

@end
