//
//  ViewController.m
//  CardReader
//
//  Created by Ferose Babu on 11/19/15.
//  Copyright © 2015 Ferose Babu. All rights reserved.
//

#import "ViewController.h"
#import "CardIO.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource, CardIOViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *cardView;

@property (weak, nonatomic) CardIOView *cardIOView;
@property (nonatomic) NSMutableArray *cards;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (![CardIOUtilities canReadCardWithCamera]) {
        return;
    }
    
    self.cards = [NSMutableArray array];
    
    [self resetCardIOView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [CardIOUtilities preload];
}

- (void)resetCardIOView
{
    [self.cardIOView removeFromSuperview];
    
    CardIOView *cardIOView = [[CardIOView alloc] initWithFrame:self.cardView.bounds];
    cardIOView.allowFreelyRotatingCardGuide = NO;
    cardIOView.delegate = self;
    [self.cardView addSubview:cardIOView];
    self.cardIOView = cardIOView;
    
    NSDictionary *views = @{@"cardView": self.cardIOView};
    [self.cardView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[cardView]|" options:0 metrics:nil views:views]];
    [self.cardView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[cardView]|" options:0 metrics:nil views:views]];
    self.cardIOView.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)cardIOView:(CardIOView *)cardIOView didScanCard:(CardIOCreditCardInfo *)cardInfo
{
    [self resetCardIOView];
    [self.cards addObject:cardInfo];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cards.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CardCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    CardIOCreditCardInfo *cardInfo = self.cards[indexPath.row];
    cell.textLabel.text = cardInfo.cardNumber;
    
    return cell;
}

- (IBAction)shareTapped:(id)sender {
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[[[self.cards valueForKeyPath:@"cardNumber"] componentsJoinedByString:@"\n"]] applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
}

@end
