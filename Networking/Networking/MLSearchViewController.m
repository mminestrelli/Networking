//
//  MLSearchViewController.m
//  Networking
//
//  Created by Mauricio Minestrelli on 8/25/14.
//  Copyright (c) 2014 mercadolibre. All rights reserved.
//

#import "MLSearchViewController.h"
#import "MLItemListViewController.h"
#import "MLHistoryTableViewCell.h"
#import "MLDaoManager.h"

#define kHistoryCellHeight 36;

@interface MLSearchViewController ()
//Search history
@property (nonatomic,strong)NSMutableArray* history;
@end

@implementation MLSearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.history=[[NSMutableArray alloc]init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableViewHistory.delegate = self;
    self.tableViewHistory.dataSource = self;
    self.searchBar.delegate=self;
    
    // Particular de la search
    UIImage* logoImage = [UIImage imageNamed:@"mercadolibre.png"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:logoImage];
    [self.searchBar setPlaceholder:@"Buscar en Mercadolibre"];
    
    if ([[MLDaoManager sharedManager] getHistory]!=nil) {
        self.history=[[MLDaoManager sharedManager] getHistory];
    }
    //self.history=[[MLDaoManager sharedManager] getHistory];
    
    //Mock add
//    [self.history addObject:[[MLHistoryItem alloc]initWithItem:@"ipod" andDate:[NSDate dateWithHoursBeforeNow:48]]];
//    [self.history addObject:[[MLHistoryItem alloc]initWithItem:@"ipad"andDate:[NSDate dateWithHoursBeforeNow:5]]];
    
    [self setTitle:@"Buscar"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.history.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * tableIdentifier = @"MLHistoryTableViewCell";
    MLHistoryTableViewCell * historyCell = (MLHistoryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    
    if (historyCell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MLHistoryTableViewCell" owner:self options:nil];
        historyCell = [nib objectAtIndex:0];
    }
    
    MLHistoryItem * item=[self.history objectAtIndex:indexPath.row];
    historyCell.labelHistoryItem.text=item.searchedItem;
    
    //FEO
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if([item.searchDate isToday]){
        [formatter setDateFormat:@"hh:mm"];
    }
    else{
        [formatter setDateFormat:@"dd/MM/yyyy"];
    }
    
    NSString *stringFromDate = [formatter stringFromDate:item.searchDate];
    historyCell.labelDate.text=stringFromDate;
    historyCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return historyCell;
    
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MLHistoryItem* item=[self.history objectAtIndex:indexPath.row];
    [self searchFromHistoryWithInput:item.searchedItem];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kHistoryCellHeight;
}

#pragma mark keyboard
/*Dismisses searchbar keyboard*/
-(void)dismissKeyboard{
    [self.searchBar resignFirstResponder];
}
#pragma mark searchbar
/*Search bar button clicked pushes item list view controller, adds input from search to history*/
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self dismissKeyboard];
    
    [self.history addObject:[[MLHistoryItem alloc]initWithItem:self.searchBar.text andDate:[NSDate date]]];
    MLDaoManager * daoManager=[MLDaoManager sharedManager];
    [daoManager saveHistory:self.history];
    [self.tableViewHistory reloadData];
    
    MLItemListViewController * controller=[[MLItemListViewController alloc]initWithInput:self.searchBar.text];
    self.searchBar.text=@"";
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)searchFromHistoryWithInput:(NSString*)input{
    [self dismissKeyboard];
    MLItemListViewController * controller=[[MLItemListViewController alloc]initWithInput:input];
    [self.navigationController pushViewController:controller animated:YES];
}

@end