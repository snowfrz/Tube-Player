//
//  RLXDownloadTrackerTableViewController.h
//  Relax
//
//  Created by Justin Proulx on 2018-03-14.
//  Copyright © 2018 Low Budget Animation Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RLXDownloadTrackerTableViewController : UITableViewController
{
    IBOutlet UIBarButtonItem *queueButton;
}
@property NSMutableArray * downloadedVideosArray;

@end
