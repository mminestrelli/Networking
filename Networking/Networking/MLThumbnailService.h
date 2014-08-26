//
//  MLThumbnailService.h
//  Networking
//
//  Created by Mauricio Minestrelli on 8/25/14.
//  Copyright (c) 2014 mercadolibre. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MLThumbnailService : NSObject

- (void)downloadImageWithURL:(NSURL *)url usingQueue:(NSOperationQueue*)queue withCompletionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock;
@end
