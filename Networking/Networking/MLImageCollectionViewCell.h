//
//  MLImageCollectionViewCell.h
//  Networking
//
//  Created by Mauricio Minestrelli on 8/27/14.
//  Copyright (c) 2014 mercadolibre. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLImageCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) NSString *imageName;
-(void)updateCell;
-(void) setImage:(UIImage*) image;
@end