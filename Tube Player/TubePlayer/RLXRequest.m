//
//  RLXRequest.m
//  Relax
//
//  Created by Justin Proulx on 2018-03-11.
//  Copyright © 2018 Low Budget Animation Studios. All rights reserved.
//

#import "RLXRequest.h"
#import "AFNetworking.h"
#import "HTMLReader.h"
#import "RLXVideoDownload.h"
#import <XCDYouTubeKit.h>
#import "RLXDownloadTrackerTableViewController.h"
#import <RNCryptor-objc/RNDecryptor.h>
#import <RNCryptor-objc/RNEncryptor.h>

@implementation RLXRequest


#pragma mark - Get search results
- (void)getYouTubeSearchResultsWithoutAPIWithSearchTerm:(NSString *)searchTerm andCallback:(void (^)(NSMutableSet *))callback
{
    NSMutableSet *videoInfo = [[NSMutableSet alloc] init];
    
    NSString *getRequestURL = [[@"https://www.youtube.com/results?search_query=" stringByAppendingString:[searchTerm stringByReplacingOccurrencesOfString:@" " withString:@"+"]] stringByAppendingString:@"&app=desktop"];
    
    //set up internet connection things
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects: @"text/html", @"application/xhtml+xml", @"application/xml", @"application/json", @"text/json", @"text/plain", nil];
    
    manager.responseSerializer = responseSerializer;
    
    //set the custom user agent
    NSString *userAgent = [manager.requestSerializer  valueForHTTPHeaderField:@"User-Agent"];
    userAgent = [@"" stringByAppendingPathComponent:@"Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36"];
    [manager.requestSerializer setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    
    [manager GET:getRequestURL parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
    {
        //convert data to a parseable string of HTMLs
        NSString *HTMLString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        //make an HTML document for HTMLReader to parse
        HTMLDocument *document = [HTMLDocument documentWithString:HTMLString];
        
        HTMLNode *videoTable = [document firstNodeMatchingSelector:@".item-section"];
        
        for (HTMLNode *node in [videoTable children])
        {
            if ([node.description containsString:@"li"])
            {
                BOOL somethingFailed = NO;
                
                NSMutableArray *individualVideoArray = [[NSMutableArray alloc] init];
                
                HTMLNode *innerNode = [node childAtIndex:0];
                NSString *idSectionString = [innerNode serializedFragment];
                
                NSString *videoID;
                NSString *thumbnailURL;
                NSString *title;
                NSString *channel;
                
                //video ID
                @try
                {
                    //get video id
                    videoID = [self cutStringDownWithOriginalString:idSectionString andPrecedingStringGuide:@"data-context-item-id=\"" plusSucceedingStringGuide:@"\""];
                }
                @catch (NSException *exception)
                {
                    //NSLog(@"WEIRD VIDEO ID");
                    somethingFailed = YES;
                }
                
                
                if (!somethingFailed)
                {
                    NSDictionary *json = [self getVideoMetadataForVideoWithVideoID:videoID];
                    
                    thumbnailURL = json[@"thumbnail_url"];
                    title = json[@"title"];
                    channel = json[@"author_name"];
                }
                
                //add stuff to array at the end
                if (!somethingFailed)
                {
                    //add items to the video's specific array
                    [individualVideoArray addObject:videoID];
                    @try
                    {
                        [individualVideoArray addObject:thumbnailURL];
                        [individualVideoArray addObject:title];
                        [individualVideoArray addObject:channel];
                    }
                    @catch (NSException *exception)
                    {
                        [individualVideoArray addObject:[[NSBundle mainBundle] pathForResource:@"Relax logo" ofType:@"png"]];
                        [individualVideoArray addObject:@"Unable to load title"];
                        [individualVideoArray addObject:@"Unable to load channel"];
                    }
                    
                    
                    //add the video array to the main set
                    [videoInfo addObject:individualVideoArray];
                    
                    callback((NSMutableSet*) videoInfo);
                }
            }
        }
    }
    failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
    {
        NSLog(@"Failed");
        
        callback((NSMutableSet*) videoInfo);
    }];
}

- (NSDictionary *)getVideoMetadataForVideoWithVideoID:(NSString *)videoID
{
    NSData *videoJSON = [NSData dataWithContentsOfURL:[NSURL URLWithString:[@"https://www.youtube.com/oembed?format=json&url=https://www.youtube.com/watch?v=" stringByAppendingString:videoID]]];
    
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:videoJSON options:NSJSONReadingMutableContainers error:&error];
    
    return json;
}

- (NSString *)cutStringDownWithOriginalString:(NSString *)originalString andPrecedingStringGuide:(NSString *)preceding plusSucceedingStringGuide:(NSString *)succeeding
{
    return [[originalString substringFromIndex:[originalString rangeOfString:preceding].location + [preceding length]] substringToIndex:[originalString rangeOfString:succeeding].location];
}

#pragma mark - Download video
- (void)requestActionSheetForDownloadWithID:(NSString *)identifier andTitle:(NSString *)title andChannel:(NSString *)channel andThumbnailURL:(NSString *)thumbnailAddress
{
    //there used to be some IAP stuff here. Now the extra step before downloading is useless. Oh well
    
    [self showActionSheetForDownloadWithID:identifier andTitle:title andChannel:channel andThumbnailURL:thumbnailAddress andCreditTypeUnlimited:YES];
}

- (void)showActionSheetForDownloadWithID:(NSString *)identifier andTitle:(NSString *)title andChannel:(NSString *)channel andThumbnailURL:(NSString *)thumbnailAddress andCreditTypeUnlimited:(BOOL)isUnlimited
{
    UIViewController *topController = [self getTopController];
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Choose a resolution" message:@"Lower resolutions take up less space, but higher ones look better." preferredStyle:UIAlertControllerStyleActionSheet];
    
    RLXVideoDownload *video = [RLXVideoDownload new];
    video.identifier = identifier;
    video.title = title;
    video.channel = channel;
    video.thumbnailAddress = thumbnailAddress;
    
    //init queue array if it doesn't exist yet
    if ([_downloadQueue count] == 0)
    {
        _downloadQueue = [[NSMutableArray alloc] init];
    }
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        // Cancel button tappped.
        [actionSheet dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"240p" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // OK button tapped.
        [actionSheet dismissViewControllerAnimated:YES completion:nil];
        [self addVideoToDownloadQueue:video withResolution:XCDYouTubeVideoQualitySmall240 andCreditTypeUnlimited:isUnlimited];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"360p" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        // OK button tapped.
        
        [actionSheet dismissViewControllerAnimated:YES completion:nil];
        [self addVideoToDownloadQueue:video withResolution:XCDYouTubeVideoQualityMedium360 andCreditTypeUnlimited:isUnlimited];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"720p" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        // OK button tapped.
        
        [actionSheet dismissViewControllerAnimated:YES completion:nil];
        [self addVideoToDownloadQueue:video withResolution:XCDYouTubeVideoQualityHD720 andCreditTypeUnlimited:isUnlimited];
    }]];
    
    // Present action sheet.
    //iPad stuff
    actionSheet.popoverPresentationController.sourceView = topController.view;
    actionSheet.popoverPresentationController.sourceRect = CGRectMake(topController.view.center.x, topController.view.frame.size.height, 0, 0);
    
    [topController presentViewController:actionSheet animated:YES completion:nil];
}

- (void)addVideoToDownloadQueue:(RLXVideoDownload *)video withResolution:(int)resolution andCreditTypeUnlimited:(BOOL)isUnlimited
{
    if (!isUnlimited)
    {
        //pay as you go credits
        NSError *error;
        NSData *encryptedData = [[NSUserDefaults standardUserDefaults] objectForKey:@"Key2"];
        NSData *decryptedData = [RNDecryptor decryptData:encryptedData withPassword:[[[UIDevice currentDevice] identifierForVendor] UUIDString] error:&error];
        int i;
        [decryptedData getBytes: &i length: sizeof(i)];
        
        i--;
        
        NSData *data = [NSData dataWithBytes: &i length: sizeof(i)];
        encryptedData = [RNEncryptor encryptData:data withSettings:kRNCryptorAES256Settings password:[[[UIDevice currentDevice] identifierForVendor] UUIDString] error:&error];
        [[NSUserDefaults standardUserDefaults] setObject:encryptedData forKey:@"Key2"];
    }
    
    //actual download stuff
    NSDictionary *downloadDict = [NSDictionary dictionaryWithObjectsAndKeys:video, @"video", [NSNumber numberWithInt:resolution], @"resolution", nil];
    
    [_downloadQueue addObject:downloadDict];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateBadge" object:self];
    
    if ([_downloadQueue count] == 1)
    {
        [self downloadAndSaveVideoWithVideo:video andResolution:resolution];
    }
}

- (void)nextDownload
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateBadge" object:self];
    if ([_downloadQueue count] > 0)
    {
        [self downloadAndSaveVideoWithVideo:_downloadQueue[0][@"video"] andResolution:[_downloadQueue[0][@"resolution"] intValue]];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DownloadProgressed" object:nil];
}

- (void)downloadAndSaveVideoWithVideo:(RLXVideoDownload *)video andResolution:(int)resolution
{
    videoTitle = video.title;
    videoChannel = video.channel;
    thumbnailURL = video.thumbnailAddress;
    
    NSString * const metadata = @"metadata";
    
    NSMutableArray *downloadedVideoMetadataArray;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:metadata])
    {
        downloadedVideoMetadataArray = [[[NSUserDefaults standardUserDefaults] objectForKey:metadata] mutableCopy];
    }
    else
    {
        downloadedVideoMetadataArray = [[NSMutableArray alloc] init];
    }
    
    NSMutableArray *tempDownloadedVideoMetadataArray = downloadedVideoMetadataArray;
    
    for (NSMutableDictionary *dict in tempDownloadedVideoMetadataArray)
    {
        if ([dict[@"ID"] isEqualToString:video.identifier])
        {
            [downloadedVideoMetadataArray removeObject:dict];
        }
    }
    
    NSMutableDictionary *currentVideoDict = [[NSMutableDictionary alloc] init];
    
    [currentVideoDict setObject:video.identifier forKey:@"ID"];
    [currentVideoDict setObject:videoTitle forKey:@"Title"];
    [currentVideoDict setObject:videoChannel forKey:@"Channel"];
    [currentVideoDict setObject:[NSNumber numberWithInteger:0] forKey:@"DLProgress"];
    [currentVideoDict setObject:thumbnailURL forKey:@"thumbnail"];
    
    [downloadedVideoMetadataArray addObject:currentVideoDict];
    
    [[NSUserDefaults standardUserDefaults] setObject:downloadedVideoMetadataArray forKey:metadata];
    
    [[XCDYouTubeClient defaultClient] getVideoWithIdentifier:video.identifier completionHandler:^(XCDYouTubeVideo * _Nullable xcdvideo, NSError * _Nullable error)
    {
        //get the url for the raw video file at the chosen resolution
        NSURL *urlToDownloadFrom = xcdvideo.streamURLs[@(resolution)];
        
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession * session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:[NSOperationQueue mainQueue]] ;
        NSURLRequest *request = [NSURLRequest requestWithURL:urlToDownloadFrom];
        
        self->_videoIdentifier = video.identifier;
        
        //do the download
        NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request];
        downloadTask.accessibilityAttributedLabel = [[NSAttributedString alloc] initWithString:video.identifier];
        [downloadTask resume];
    }];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    double progress = (double)totalBytesWritten/(double)totalBytesExpectedToWrite;
    //NSLog(@"Progress: %d%%", (int)(100*progress));
    
    _downloadProgress = (progress);
    
    NSMutableArray *metadataArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"metadata"] mutableCopy];
    for (NSMutableDictionary *dict in metadataArray)
    {
        if ([dict[@"ID"] isEqualToString:[downloadTask.accessibilityAttributedLabel string]])
        {
            NSMutableDictionary *mutableDict = [dict mutableCopy];
            
            [mutableDict setObject:[NSNumber numberWithDouble:_downloadProgress] forKey:@"DLProgress"];
            
            [metadataArray replaceObjectAtIndex:[metadataArray indexOfObject:dict] withObject:mutableDict];
            
            [[NSUserDefaults standardUserDefaults] setObject:metadataArray forKey:@"metadata"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DownloadProgressed" object:nil];
        }
    }
}

- (void)URLSession:(nonnull NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(nonnull NSURL *)location
{
    //save the video file
    NSData *videoData = [NSData dataWithContentsOfURL:location];
    [self completedDownloadWithVideoData:videoData fromIdentifier:_videoIdentifier];
    
    NSMutableArray *downloadedVideos = [[NSMutableArray alloc] init];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"downloadedVideos"])
    {
        downloadedVideos = [[[NSUserDefaults standardUserDefaults] objectForKey:@"downloadedVideos"] mutableCopy];
    }

    [downloadedVideos addObject:_videoIdentifier];
    [[NSUserDefaults standardUserDefaults] setObject:downloadedVideos forKey:@"downloadedVideos"];
    //NSLog(@"Done downloading");
    
    //remove the download and proceed to the next one
    [_downloadQueue removeObjectAtIndex:0];
    [self nextDownload];
}


- (void)completedDownloadWithVideoData:(NSData *)videoData fromIdentifier:(NSString *)identifier
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    //save the video to the correct directory
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *videoDirectory = [documentsDirectory stringByAppendingPathComponent:@"videos"];
    
    if (![fileManager fileExistsAtPath:videoDirectory])
    {
        [fileManager createDirectoryAtPath:videoDirectory withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    NSString *filePath = [videoDirectory stringByAppendingPathComponent:[identifier stringByAppendingString:@".mp4"]];
    [videoData writeToFile:filePath atomically:YES];
}

- (void)cancelDownloadWithIdentifier:(NSString *)videoID
{
    //bootleg way of cancelling downloads
    //it saves a list of videos to delete next time the app opens
    NSMutableArray *cancelArray;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"canceledDownloads"])
    {
        cancelArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"canceledDownloads"] mutableCopy];
    }
    else
    {
        cancelArray = [[NSMutableArray alloc] init];
    }
    
    [cancelArray addObject:videoID];
    [[NSUserDefaults standardUserDefaults] setObject:cancelArray forKey:@"canceledDownloads"];
    
    [_downloadQueue removeObjectAtIndex:0];
    [self nextDownload];
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

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


@end




