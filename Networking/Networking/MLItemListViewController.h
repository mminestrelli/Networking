//
//  MLItemListViewController.h
//  Networking
//
//  Created by Mauricio Minestrelli on 8/25/14.
//  Copyright (c) 2014 mercadolibre. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
@interface MLItemListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>{
    MBProgressHUD *HUD;
}
- (id)initWithInput:(NSString*)input;
@end