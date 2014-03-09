//
//  NormSearchDisplayController.m
//  On Tap
//
//  Created by Ryan Norman on 2/22/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import "NormSearchDisplayController.h"
#import "NormViewSnapshot.h"
#import "constants.h"

@interface NormSearchDisplayController () <NormSearchBarDelegate>
@property UIImageView *navImageView;
@property UIImageView *bgImageView;
@property UIView *searchBackgroundView;
@property UITableView *searchResultsTableView;
@property UIView *searchBarOriginalView;
@property UIView *searchResultsOverlayView;
@property UITextField *searchBarTextField;
@property float statusBarHeight;
@property BOOL alreadyEditing;
@property UIView *searchBarParentView;
@property BOOL hasReplacedOriginalSearchBarWithImage;

@end

@implementation NormSearchDisplayController

-(id)initWithContentsController: (UIViewController *)contentsController searchBar: (NormSearchBar *)searchBar
{
    self = [super init];
    
    if (self) {
        _statusBarHeight = 20;
        _alreadyEditing = NO;
        _hasReplacedOriginalSearchBarWithImage = NO;
        
        
        _contentsController = contentsController;
        _searchBar = searchBar;
        _searchBar.delegate = self;
        [_searchBar setTintColor:[UIColor whiteColor]];
        for (UIView *subView in _searchBar.subviews)
        {
            for (UIView *secondLevelSubview in subView.subviews){
                if ([secondLevelSubview isKindOfClass:[UITextField class]])
                {
                    _searchBarTextField = (UITextField *)secondLevelSubview;
                    
                    //set font color here
                    _searchBarTextField.textColor = [UIColor whiteColor];
                    
                    break;
                }
            }
        }
        
        
        _searchBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(_searchBar.frame.origin.x, 64.0, self.view.frame.size.width, _searchBar.frame.size.height)];
        [_searchBackgroundView setBackgroundColor:[UIColor colorWithRed:198.0/255.0 green:198.0/255.0 blue:203.0/255.0 alpha:1.0]];
        [self.view addSubview:_searchBackgroundView];
        

        _bgImageView = [[UIImageView alloc] init];
        [self.view addSubview:_bgImageView];
        
        _searchResultsOverlayView = [[UIView alloc] initWithFrame:self.view.frame];
        [_searchResultsOverlayView setBackgroundColor:[UIColor blackColor]];
        [_searchResultsOverlayView.layer setOpacity:0.0];
        [self.view addSubview:_searchResultsOverlayView];
        
        UIView *statusBarBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, _statusBarHeight + 40)];
        [statusBarBackground setBackgroundColor:_MAIN_COLOR];
        [self.view addSubview:statusBarBackground];
        
        UIImage *navImage = [NormViewSnapshot snapshotOfView:_contentsController.navigationController.navigationBar];
        _navImageView = [[UIImageView alloc] initWithImage:navImage];
        _navImageView.frame = CGRectOffset(_navImageView.frame, 0, _statusBarHeight);
        [self.view addSubview:_navImageView];
        
        
        self.searchResultsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.navImageView.frame.size.height + self.searchBackgroundView.frame.size.height - 24, self.view.frame.size.width, self.view.frame.size.height - (self.navImageView.frame.size.height + self.searchBackgroundView.frame.size.height)) style:UITableViewStylePlain];
        [self.searchResultsTableView setHidden:YES];
        
        [self.searchResultsTableView setContentInset:UIEdgeInsetsMake(0,0,200,0)];
        
        [self.view addSubview:self.searchResultsTableView];
        
        [self.view bringSubviewToFront:self.searchBackgroundView];
        
        self.view.backgroundColor = [UIColor whiteColor];
    }
    
    return self;
}

-(void)startSearchFromSearchBarImage
{
    [self searchBarTextDidBeginEditing:_searchBar];
}

-(void)searchBarTextDidBeginEditing:(NormSearchBar *)searchBar
{
    if (!self.alreadyEditing) {
        [self searchBarTextDidBeginEditing];
        [self.searchBar becomeFirstResponder];
        self.alreadyEditing = YES;
    }
}


- (void)searchBarCancelButtonClicked:(NormSearchBar *)searchBar
{
    if (self.alreadyEditing) {
        [searchBar resignFirstResponder];
        [self stopSearching];
        self.alreadyEditing = NO;
    }
}


-(void)searchBarTextDidBeginEditing //:(UISearchBar *)searchBar
{
    UIImage *navImage = [NormViewSnapshot snapshotOfView:self.contentsController.navigationController.navigationBar];
    [self.navImageView setImage:navImage];
    self.navImageView.frame = CGRectMake(0, _statusBarHeight, navImage.size.width, navImage.size.height);
    
    UIImage *bgImage = [NormViewSnapshot snapshotOfView:self.contentsController.view];
    [self.bgImageView setImage:bgImage];
    self.bgImageView.frame = CGRectMake(0, self.navImageView.frame.size.height + _statusBarHeight, bgImage.size.width, bgImage.size.height);
    
    _searchBarParentView = _searchBar.superview;
    [_searchBackgroundView addSubview:_searchBar];
    
    [_searchBackgroundView setBackgroundColor:[UIColor colorWithRed:198.0/255.0 green:198.0/255.0 blue:203.0/255.0 alpha:1.0]];
    
    [_searchBar setShowsCancelButton:YES animated:YES];

    [self.searchResultsTableView setHidden: YES];
    [self.bgImageView setHidden:NO];
    self.searchResultsTableView.dataSource = self.searchResultsDataSource;
    self.searchResultsTableView.delegate = self.searchResultsDelegate;
    
    [self.contentsController.navigationController pushViewController:self animated:NO];

    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.searchBackgroundView.frame = CGRectOffset(self.searchBackgroundView.frame, 0, self.navImageView.frame.size.height * -1);
        
        self.bgImageView.frame = CGRectOffset(self.bgImageView.frame, 0, -44.0);
        self.navImageView.frame = CGRectMake(0, self.navImageView.frame.size.height * -1, self.navImageView.frame.size.width, self.navImageView.frame.size.height);
        
        [_searchBackgroundView setBackgroundColor:_MAIN_COLOR];
        [_searchBar setBackgroundColor:_MAIN_COLOR];
        
        [_searchResultsOverlayView.layer setOpacity:0.6];
        
        

    } completion:nil];
    
    [self.delegate searchDisplayControllerDidBeginSearch:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self.searchResultsTableView deselectRowAtIndexPath:[self.searchResultsTableView indexPathForSelectedRow] animated:YES];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

-(void)stopSearching
{
    [_searchBar setText:@""]; // Clear test before animate close
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.searchBackgroundView.frame = CGRectOffset(self.searchBackgroundView.frame, 0, self.navImageView.frame.size.height);
        
        self.bgImageView.frame = CGRectOffset(self.bgImageView.frame, 0, 44.0);
        self.searchResultsTableView.frame = CGRectOffset(self.searchResultsTableView.frame, 0, 44.0);
        
        self.navImageView.frame = CGRectMake(0, 20, self.navImageView.frame.size.width, self.navImageView.frame.size.height);
        [_searchBar setShowsCancelButton:NO animated:YES];
        
        [_searchBar setBackgroundColor:[UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0]];
        
        [_searchResultsOverlayView.layer setOpacity:0.0];
        
    } completion:^(BOOL finished) {
        [self.delegate searchDisplayControllerWillEndSearch:self];
        [_searchBarParentView addSubview:_searchBar];
        [self.navigationController popViewControllerAnimated:NO];
    }];
}

-(void)searchBar:(NormSearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self.bgImageView setHidden:YES];
    self.searchResultsTableView.frame = CGRectMake(0, self.navImageView.frame.size.height + self.searchBackgroundView.frame.size.height - 24, self.view.frame.size.width, self.view.frame.size.height - (self.navImageView.frame.size.height + self.searchBackgroundView.frame.size.height));
    [self.searchResultsTableView setHidden:NO];
    
    [self.delegate searchDisplayController:self shouldReloadTableForSearchString:searchText];
    [self.searchResultsTableView reloadData];
}

@end
