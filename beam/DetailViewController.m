//
//  DetailViewController.m
//  beam
//
//  Created by Raj Vir on 5/20/13.
//  Copyright (c) 2013 Raj Vir. All rights reserved.
//

#import "DetailViewController.h"
#import <Firebase/Firebase.h>
#import "UIBubbleTableView.h"
#import "UIBubbleTableViewDataSource.h"

@interface DetailViewController ()
- (void)configureView;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.
    
    _f = [[Firebase alloc] initWithUrl:[NSString stringWithFormat: @"https://rjvir.firebaseio.com/%@", self.detailItem]];
    
    // Write data to Firebase
    
    if (self.detailItem) {
        self.navigationItem.title = self.detailItem;
    }
    
//    [self.chatText becomeFirstResponder];
    // Read data and react to changes
//    [_f observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
//        self.chatText.text = snapshot.value;
//        
//        [self.chatTable reloadData];
//    }];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}
- (IBAction)cancelPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.chatMessages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Chat";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    
    NSDictionary *message = [self.chatMessages objectAtIndex:indexPath.row];
    cell.textLabel.text = message[@"from"];
    cell.detailTextLabel.text = message[@"text"];
    return cell;
}

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView {
    return [self.chatMessages count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row {
    NSDictionary *message = [self.chatMessages objectAtIndex:[self.chatMessages count] - row - 1];
    
    NSBubbleData *heyBubble = [NSBubbleData dataWithText:message[@"text"] date:[NSDate dateWithTimeIntervalSinceNow:-300] type:([message[@"from"] isEqualToString:self.name])?BubbleTypeMine:BubbleTypeSomeoneElse];
    return heyBubble;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.name = @"Raj Vir";
    self.chatMessages = [[NSMutableArray alloc] init];
    [_f observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        [self.chatText becomeFirstResponder];
        [self scrollToBottom];
    }];
    
    _f = [[Firebase alloc] initWithUrl:[NSString stringWithFormat: @"https://rjvir.firebaseio.com/%@", self.detailItem]];
    [_f observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        [self.chatMessages insertObject:snapshot.value atIndex:0];
        [self.chatTable reloadData];
        [self scrollToBottom];
    }];
    
    [_f observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
        int index = 0;
        for(NSDictionary *val in self.chatMessages){
            if([val[@"from"] isEqualToString:snapshot.value[@"from"]]){
                [self.chatMessages removeObject:val];
                [self.chatMessages insertObject:snapshot.value atIndex:index];
                break;
            }
            index++;
        }
        [self.chatTable reloadData];
        [self scrollToBottom];
    }];
    
    [_f observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *snapshot) {
        [self.chatMessages removeObject:snapshot.value];
        [self.chatTable reloadData];
        [self scrollToBottom];
    }];
    
    self.currentNode = nil;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];

}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"appeared!");
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.0f animations:^{
        
        CGRect frame = self.chatTable.frame;
        frame.size.height -= kbSize.height;
        self.chatTable.frame = frame;
    }];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.0f animations:^{
        
        CGRect frame = self.chatTable.frame;
        frame.size.height += kbSize.height;
        self.chatTable.frame = frame;
    }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textViewDidChange:(UITextView *)textView {
    if(self.currentNode == nil){
        self.currentNode = [_f childByAutoId];
    }
    
    [self.currentNode setValue:@{@"from":self.name, @"text":textView.text}];

//    [self.currentNode setValue:self.name forKey:@"name"];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{

    if([text isEqualToString:@"\n"]) {
        self.currentNode = nil;
        self.chatText.text = @"";
        _date = [NSDate date];
        return NO;
    }
    NSTimeInterval timeInterval = [_date timeIntervalSinceNow];
    if((timeInterval*-1) > 2) {
        self.chatText.text = @"";
        self.currentNode = [_f childByAutoId];
    }
    
    _date = [NSDate date];
    return YES;
}

- (IBAction)frButton:(id)sender {
    [self.chatText becomeFirstResponder];
    
}

- (void)scrollToBottom {
    NSIndexPath* ipath = [NSIndexPath indexPathForRow: [self.chatMessages count]-1 inSection: 0];
    [self.chatTable scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: NO];
}


@end
