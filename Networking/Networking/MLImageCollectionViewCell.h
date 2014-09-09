//
//  MLImageCollectionViewCell.h
//  Networking
//
//  Created by Mauricio Minestrelli on 8/27/14.
//  Copyright (c) 2014 mercadolibre. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLImageCollectionViewCell : UICollectionViewCell

-(void) setImage:(UIImage*) image;
-(void) loadImageWithUrl:(NSURL*) url andIdentification:(NSString*)imgId;
@end
