//
//  MLItemListViewController.m
//  Networking
//
//  Created by Mauricio Minestrelli on 8/25/14.
//  Copyright (c) 2014 mercadolibre. All rights reserved.
//

#import "MLItemListViewController.h"
#import "ProductTableViewCell.h"
#import "SearchItem.h"
#import "MLItemDetailViewController.h"
#import "MLSearchService.h"
#define kProductCellHeight 72

@interface MLItemListViewController ()<SearchManagerDelegate>

@property (nonatomic,strong) NSMutableArray *items;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,copy) NSString* input;
@property (nonatomic,strong) ProductTableViewCell* lastVisibleCell;
@property (nonatomic,strong) MLSearchService* searchService;


@end

@implementation MLItemListViewController

- (id)initWithInput:(NSString*)input
{
    self = [super init];
    if (self) {
        self.input=input;
        self.searchService = [[MLSearchService alloc]init];
        //[input stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.manager = [[SearchManager alloc] init];
//    self.manager.communicator = [[SearchCommunicator alloc] init];
//    self.manager.communicator.delegate = self.manager;
//    self.manager.delegate = self;
    
    self.searchService.delegate=self;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self setTitle:@"Resultados"];
    [self.searchService startFetchingItemsWithInput:self.input andOffset:0];
    //[self startFetchingItemsWithInput];
}

#pragma mark - Notification Observer
//- (void)startFetchingItemsWithInput
//{
//    [self loadingHud];
//    [self.manager fetchItemsWithInput:self.input];
//}

#pragma mark - SearchManagerDelegate
- (void)didReceiveItems:(NSArray *)items
{
    if (self.items == nil){
        self.items= [NSMutableArray arrayWithArray:items] ;
    }else{
        [self.items addObjectsFromArray:items];
    }
    //????
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        //[self finishingHUD];
    });
    
}

- (void)fetchingItemsFailedWithError:(NSError *)error
{
    NSLog(@"Error %@; %@", error, [error localizedDescription]);
}

-(void)didNotReceiveItems{
    
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kProductCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProductTableViewCell * cell = (ProductTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ProductTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    SearchItem *item = self.items[indexPath.row];
    [cell.labeltitle setText:item.title];
    NSString* soldQty=[NSString stringWithFormat:@"%d%@",item.sold_quantity,@" vendidos." ];
    [cell.labelPrice setText:[NSString stringWithFormat:@"%@",item.price ]];
    [cell.labelSubtitle setText:soldQty];
    if([item.thumbnail class]!=[NSNull class]){
        NSURL *url = [NSURL URLWithString:item.thumbnail];
        NSData *data = [NSData dataWithContentsOfURL:url];
        cell.imageViewPreview.image= [UIImage imageWithData:data];
    }
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSArray *visibleRows = [self.tableView visibleCells];
    ProductTableViewCell *lastCell = [visibleRows lastObject];
    NSIndexPath *path = [self.tableView indexPathForCell:lastCell];
    if(path.row == [self.items count]-1)
    {
        if(lastCell!= self.lastVisibleCell){
            self.lastVisibleCell=lastCell;
//            UIActivityIndicatorView * spinner= [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//            [spinner startAnimating];
//            spinner.frame = CGRectMake(0, 0, 320, 44);
//            self.tableViewSearch.tableFooterView =spinner;
            [self.searchService fetchNextPage];
        }
    }
}


-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SearchItem *item = self.items[indexPath.row];
    MLItemDetailViewController * detailView= [[MLItemDetailViewController alloc] initWithNibName:nil bundle:nil andItem:item ];
    [self.navigationController pushViewController:detailView animated:YES];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark progress hud animation
-(void)finishingHUD{
    HUD.mode = MBProgressHUDModeText;
	HUD.labelText = @"Listo!";
    [HUD hide:YES afterDelay:0.3];
    //[HUD hide:YES];
}
-(void) loadingHud{
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
	// Configure for text only and offset down
	HUD.mode = MBProgressHUDModeIndeterminate;
	HUD.labelText = @"Conectando";
	HUD.removeFromSuperViewOnHide = YES;
    
}

@end