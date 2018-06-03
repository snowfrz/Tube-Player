//
//  BlackSFSafariViewController.m
//  MobilePortail
//
//  Created by Justin Proulx on 2017-12-21.
//  Copyright © 2017 Bricc Squad. All rights reserved.
//

#import "BlackSFSafariViewController.h"

@interface BlackSFSafariViewController ()

@end

@implementation BlackSFSafariViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (@available(iOS 10.0, *))
    {
        self.preferredBarTintColor = [UIColor blackColor];
    }
    else
    {
        // Fallback on earlier versions
        // Safari just stays white on iOS 9 I guess
    }
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
