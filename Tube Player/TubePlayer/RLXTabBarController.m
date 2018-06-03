//
//  RLXTabBarController.m
//  Relax
//
//  Created by Justin Proulx on 2018-03-16.
//  Copyright © 2018 Low Budget Animation Studios. All rights reserved.
//

#import "RLXTabBarController.h"
#import "AppDelegate.h"

@interface RLXTabBarController ()

@end

@implementation RLXTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSMutableArray *vcArray = [self.viewControllers mutableCopy];
    
    //show downloads if applicable
    BOOL canDownload = [[[NSUserDefaults standardUserDefaults] objectForKey:@"devdl"] boolValue];
    if (canDownload == YES)
    {
        UINavigationController *downloadsNavController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"Downloads"];
        
        [vcArray addObject:downloadsNavController];
        
        downloadsNavController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Downloads" image:[UIImage imageNamed:@"download"] tag:2];
        downloadsNavController.tabBarItem.tag = 2;
    }
    
    //show now playing
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.mediaViewController stopVideo];
    
    UIViewController *playerView = delegate.mediaPlayerNavigationController;
    
    [vcArray addObject:playerView];
    
    [self setViewControllers:vcArray];
    
    playerView.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Now Playing" image:[UIImage imageNamed:@"NowPlaying"] tag:1];
    playerView.tabBarItem.tag = 1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
