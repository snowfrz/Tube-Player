//
//  AppDelegate.h
//  Relax
//
//  Created by Justin Proulx on 2018-03-10.
//  Copyright © 2018 Low Budget Animation Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerEventLogger.h"
#import "RLXVideoPlayerViewController.h"
#import "RLXRequest.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, readonly) PlayerEventLogger *playerEventLogger;

@property (nonatomic, strong) UINavigationController *mediaPlayerNavigationController;

@property (nonatomic, retain) RLXRequest *request;

- (RLXVideoPlayerViewController *)mediaViewController;


@end

