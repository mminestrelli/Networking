//
//  MLAbstractViewController.m
//  Networking
//
//  Created by Mauricio Minestrelli on 8/25/14.
//  Copyright (c) 2014 mercadolibre. All rights reserved.
//

#import "MLAbstractViewController.h"
#define kOffsetBlock 15
@interface MLAbstractViewController ()

@end

@implementation MLAbstractViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.thumbnailDownloadQueue = [[NSOperationQueue alloc] init];
        self.thumbnailDownloadQueue.name = @"Download Queue";
        self.thumbnailDownloadQueue.maxConcurrentOperationCount=kOffsetBlock;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.barTintColor=[UIColor blackColor];
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark progress hud animation
-(void)endHud{
    self.progressHud.mode = MBProgressHUDModeText;
	self.progressHud.labelText = @"Listo!";
    //[HUD hide:YES afterDelay:0.3];
    [self.progressHud hide:YES];
}
-(void) loadingHud{
    [self endHud];
    
    self.progressHud = [[MBProgressHUD alloc] initWithView:self.view];
    self.progressHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	// Configure for text only and offset down
	self.progressHud.mode = MBProgressHUDModeIndeterminate;
	self.progressHud.labelText = @"Conectando";
	self.progressHud.removeFromSuperViewOnHide = YES;
    
}

@end
