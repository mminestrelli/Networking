//
//  MLItemListViewController.h
//  Networking
//
//  Created by Mauricio Minestrelli on 8/25/14.
//  Copyright (c) 2014 mercadolibre. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLAbstractViewController.h"
@interface MLItemListViewController : MLAbstractViewController<UITableViewDataSource, UITableViewDelegate>
- (id)initWithInput:(NSString*)input;
@end