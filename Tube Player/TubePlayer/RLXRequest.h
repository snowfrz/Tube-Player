//
//  RLXRequest.h
//  Relax
//
//  Created by Justin Proulx on 2018-03-11.
//  Copyright © 2018 Low Budget Animation Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCDYouTubeKit.h>

@interface RLXRequest : NSObject <NSURLSessionDownloadDelegate, NSURLSessionDelegate>
{
    NSString *videoTitle;
    NSString *videoChannel;
    NSString *thumbnailURL;
}

@property double downloadProgress;
@property (strong) NSURLSession *session;
@property (nonatomic, strong) NSMutableArray *downloadQueue;
@property NSString *videoIdentifier;

- (void)getYouTubeSearchResultsWithoutAPIWithSearchTerm:(NSString *)searchTerm andCallback:(void (^)(NSMutableSet *))callback;
- (void)requestActionSheetForDownloadWithID:(NSString *)identifier andTitle:(NSString *)title andChannel:(NSString *)channel andThumbnailURL:(NSString *)thumbnailURL;
- (void)cancelDownloadWithIdentifier:(NSString *)videoID;
- (NSDictionary *)getVideoMetadataForVideoWithVideoID:(NSString *)videoID;
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

@end
