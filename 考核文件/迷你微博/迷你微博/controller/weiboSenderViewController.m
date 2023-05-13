//
//  weiboSenderViewController.m
//  迷你微博
//
//  Created by jimmy on 5/13/23.
//

#import "weiboSenderViewController.h"
#import "WeiboSender.h"

@interface weiboSenderViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UIButton *navigationBarSendButton;
@property (nonatomic, strong) UILabel *countLabel;

@end

@implementation weiboSenderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"发送微博";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 40, screenWidth - 20, 200)];
    self.textField.backgroundColor = [UIColor whiteColor];
    self.textField.font = [UIFont systemFontOfSize:16];
    self.textField.placeholder = @"分享新鲜事...";
    self.textField.delegate = self;
    [self.view addSubview:self.textField];
    
    self.countLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.textField.frame) - 50, CGRectGetMaxY(self.textField.frame) - 20, 40, 20)];
    self.countLabel.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
    self.countLabel.text = @"0/140";
    self.countLabel.textAlignment = NSTextAlignmentRight;
    self.countLabel.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:self.countLabel];
    
    self.sendButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth/2 - 50, CGRectGetMaxY(self.textField.frame) + 20, 100, 44)];
    self.sendButton.backgroundColor = [UIColor orangeColor];
    self.sendButton.layer.cornerRadius = self.sendButton.bounds.size.height / 2.0;
    self.sendButton.layer.masksToBounds = YES;
    [self.sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.sendButton addTarget:self action:@selector(sendButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.sendButton];
    



}

- (void)cancelButtonClicked:(UIBarButtonItem *)button {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendButtonClicked:(UIBarButtonItem *)button {
    //TODO: 点击发送按钮后的逻辑
    NSLog(@"sended");
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([textField.text isEqualToString:@"分享新鲜事..."]) {
        textField.text = @"";
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField.text isEqualToString:@""]) {
        textField.text = @"分享新鲜事...";
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSInteger count = newText.length;
    self.countLabel.text = [NSString stringWithFormat:@"%ld/140", (long)count];
    return YES;
}


- (void)textFieldDidChange:(UITextField *)textField {
    BOOL enableSend = textField.text.length > 0;
    CGFloat alphaValue = enableSend ? 1.0 : 0.6;
    self.sendButton.alpha = alphaValue;
    self.sendButton.enabled = enableSend;
    self.navigationBarSendButton.alpha = alphaValue;
    self.navigationItem.rightBarButtonItem.enabled = enableSend;

    
}
@end
