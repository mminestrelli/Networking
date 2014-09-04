//
//  MLItemListViewController.m
//  Networking
//
//  Created by Mauricio Minestrelli on 8/25/14.
//  Copyright (c) 2014 mercadolibre. All rights reserved.
//

#import "MLItemListViewController.h"
#import "ProductTableViewCell.h"
#import "MLSearchItem.h"
#import "MLItemDetailViewController.h"
#import "MLSearchService.h"
#import "MLImageService.h"
#import "MLDaoImageManager.h"
#import "MLNoResultsViewController.h"
#define kProductCellHeight 72

@interface MLItemListViewController ()<MLSearchManagerDelegate>

@property (nonatomic,strong) NSMutableArray *items;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,copy) NSString* input;
@property (nonatomic,strong) ProductTableViewCell* lastVisibleCell;
@property (nonatomic,strong) MLSearchService* searchService;
@property (nonatomic,strong) MLImageService* thumbnailService;
@property (nonatomic,strong) NSOperationQueue* thumbnailDownloadQueue;

@property (nonatomic,copy) NSString * myString;

@end

@implementation MLItemListViewController

-(instancetype) init{
    
    if (self = [super init]){
        
        self.searchService = [[MLSearchService alloc]init];
        self.thumbnailService=[[MLImageService
                                alloc]init];
    }
    return self;
}

- (id)initWithInput:(NSString*)input
{
    self = [self init];
    if (self) {
        self.input=input;
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
    
    self.searchService.delegate=self;
    //thumbnaildelegate
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self setTitle:@"Resultados"];
    
    [self showLoadingHud];
    [self.searchService startFetchingItemsWithInput:self.input andOffset:0];
    [self.tableView registerNib:[UINib nibWithNibName:@"ProductTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ProductCellIdentifier"];
}
-(void) viewWillDisappear:(BOOL)animated{
#warning search searvice should be implemented so that it supports cancel method
    //[self.searchService cancel];
}

#pragma mark - SearchManagerDelegate
- (void)didReceiveItems:(NSArray *)items
{
    [self removeLoadingHud];
    if (self.items == nil){
        self.items= [NSMutableArray arrayWithArray:items] ;
    }else{
        [self.items addObjectsFromArray:items];
    }
    
    [self.tableView reloadData];
    
    
}

- (void)fetchingItemsFailedWithError:(NSError *)error
{
    NSLog(@"Error %@; %@", error, [error localizedDescription]);
}

-(void)didNotReceiveItems{
    //Sets a noResultsView
    [self removeLoadingHud];
    
    MLNoResultsViewController * noResultsView = [[MLNoResultsViewController alloc]initWithNibName:nil bundle:nil];
    [self.view addSubview:noResultsView.view];

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
    ProductTableViewCell * productCell = [tableView dequeueReusableCellWithIdentifier:@"ProductCellIdentifier"];
    return productCell;
}


-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    MLSearchItem *item = self.items[indexPath.row];
    [(ProductTableViewCell*)cell fillCellWithItem:item];
}
-(void) tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //Cancel
    
    [(ProductTableViewCell *)cell cancelService];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSArray *visibleRows = [self.tableView visibleCells];
    ProductTableViewCell *lastCell = [visibleRows lastObject];
    NSIndexPath *path = [self.tableView indexPathForCell:lastCell];
    if(path.row == [self.items count]-1)
    {
        if(lastCell!= self.lastVisibleCell){
            self.lastVisibleCell=lastCell;
            UIActivityIndicatorView * spinner= [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [spinner startAnimating];
            spinner.frame = CGRectMake(0, 0, 320, 44);
            self.tableView.tableFooterView =spinner;
            [self.searchService fetchNextPage];
        }
    }
}


-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MLSearchItem *item = self.items[indexPath.row];
    MLItemDetailViewController * detailView= [[MLItemDetailViewController alloc] initWithItem:item ];
    [self.navigationController pushViewController:detailView animated:YES];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end