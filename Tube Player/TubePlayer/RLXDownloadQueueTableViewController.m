//
//  RLXDownloadQueueTableViewController.m
//  Relax
//
//  Created by Justin Proulx on 2018-04-17.
//  Copyright © 2018 Low Budget Animation Studios. All rights reserved.
//

#import "RLXDownloadQueueTableViewController.h"
#import "AppDelegate.h"
#import "RLXSearchTableViewCell.h"
#import "RLXVideoDownload.h"
#import "UIScrollView+EmptyDataSet.h"

@interface RLXDownloadQueueTableViewController () <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@end

@implementation RLXDownloadQueueTableViewController

#define IS_4_INCH_DISPLAY ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

- (void)viewDidLoad
{
    [self.tableView setContentInset:UIEdgeInsetsMake(16, 0, 16, 0)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(aDownloadFinished:) name:@"UpdateBadge" object:nil];
    
    [super viewDidLoad];
    
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)aDownloadFinished:(NSNotification *)notification
{
    [self.tableView reloadData];
}

- (IBAction)Done:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Empty set stuff
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    UIImage *imageToReturn;
    if (IS_4_INCH_DISPLAY)
    {
        imageToReturn = nil;
    }
    else
    {
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        imageToReturn = [delegate.request imageWithImage:[UIImage imageNamed:@"Relax"] scaledToSize:CGSizeMake(256, 256)];
    }
    return imageToReturn;
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"Download Queue";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"You don't have any videos waiting to be downloaded. Videos currently being downloaded can be viewed and managed on the main Downloads page, while queued videos can be viewed and managed from here.";
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0f],
                                 NSForegroundColorAttributeName: [UIColor whiteColor],
                                 NSParagraphStyleAttributeName: paragraph};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    if ([delegate.request.downloadQueue count] == 0)
    {
        return 0;
    }
    else
    {
        return [delegate.request.downloadQueue count] - 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RLXSearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    // Configure the cell...
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    //get thumbnail
    RLXVideoDownload *video = delegate.request.downloadQueue[indexPath.row + 1][@"video"];
    
    NSURL *url = [NSURL URLWithString:video.thumbnailAddress];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *image = [[UIImage alloc] initWithData:data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.thumbnailImageView.image = image;
        });
    });
    
    //set values to the things in the cell
    cell.titleLabel.text = video.title;
    cell.channelLabel.text = video.channel;
    
    cell.tag = indexPath.row;
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate.request.downloadQueue removeObjectAtIndex:indexPath.row+1];
        
        
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
