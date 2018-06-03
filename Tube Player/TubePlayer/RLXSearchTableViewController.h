//
//  RLXSearchTableViewController.h
//  Relax
//
//  Created by Justin Proulx on 2018-03-10.
//  Copyright © 2018 Low Budget Animation Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RLXSearchTableViewController : UITableViewController <UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>
{
    NSMutableArray *videoArray;
    UIActivityIndicatorView *activityIndicator;
}

@end
