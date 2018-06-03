//
//  RLXVideoDownload.h
//  Relax
//
//  Created by Justin Proulx on 2018-04-16.
//  Copyright © 2018 Low Budget Animation Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RLXVideoDownload : NSObject

@property NSString *identifier;
@property NSString *title;
@property NSString *channel;
@property NSString *thumbnailAddress;

- (id)init;

@end
