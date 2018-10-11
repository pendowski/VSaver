//
//  VSSHelpViewController.m
//  VSaver
//
//  Created by Jarek Pendowski on 11/10/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import "VSSHelpViewController.h"

@interface VSSHelpViewController ()
@property (nonatomic, nonnull, strong) IBOutlet NSTextField *messageLabel;
@end

@implementation VSSHelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.messageLabel.stringValue = self.message;
}

#pragma mark - Properties

- (void)setMessage:(NSString *)message {
    _message = message;
    
    self.messageLabel.stringValue = message;
}

@end
