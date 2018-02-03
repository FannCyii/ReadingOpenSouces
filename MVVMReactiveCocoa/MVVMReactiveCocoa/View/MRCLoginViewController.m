//
//  MRCLoginViewController.m
//  MVVMReactiveCocoa
//
//  Created by leichunfeng on 14/12/27.
//  Copyright (c) 2014年 leichunfeng. All rights reserved.
//

#import "MRCLoginViewController.h"
#import "MRCLoginViewModel.h"
#import "MRCHomepageViewController.h"
#import "MRCHomepageViewModel.h"
#import "IQKeyboardReturnKeyHandler.h"
#import "TGRImageViewController.h"
#import "TGRImageZoomAnimationController.h"

@interface MRCLoginViewController () <UITextFieldDelegate, UIViewControllerTransitioningDelegate>

@property (nonatomic, weak) IBOutlet UIButton *avatarButton;

@property (nonatomic, weak) IBOutlet UIImageView *usernameImageView;
@property (nonatomic, weak) IBOutlet UIImageView *passwordImageView;

@property (nonatomic, weak) IBOutlet UITextField *usernameTextField;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;

@property (nonatomic, weak) IBOutlet UIButton *loginButton;
@property (nonatomic, weak) IBOutlet UIButton *browserLoginButton;

@property (nonatomic, strong, readonly) MRCLoginViewModel *viewModel;
@property (nonatomic, strong) IQKeyboardReturnKeyHandler *returnKeyHandler;

@end

@implementation MRCLoginViewController

@dynamic viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.avatarButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.avatarButton.layer.borderWidth = 2.0f;

    self.avatarButton.imageView.contentMode = UIViewContentModeScaleAspectFill;

    self.usernameImageView.image = [UIImage octicon_imageWithIdentifier:@"Person" size:CGSizeMake(22, 22)];
    self.passwordImageView.image = [UIImage octicon_imageWithIdentifier:@"Lock" size:CGSizeMake(22, 22)];

    self.returnKeyHandler = [[IQKeyboardReturnKeyHandler alloc] initWithViewController:self];
    self.returnKeyHandler.lastTextFieldReturnKeyType = UIReturnKeyGo;

    //获取钥匙串中的用户名和密码
    if ([SSKeychain rawLogin] != nil) {
        self.usernameTextField.text = [SSKeychain rawLogin];
        self.passwordTextField.text = [SSKeychain password];
    }

    //用于回收键盘，点击键盘的return按钮，键盘回收，执行登录操作  rac_signalForSelector::就是用来代替实现delegate的，执行完textFieldShouldReturn:方法后就会执行block中内容：
    @weakify(self)
    [[self
    	rac_signalForSelector:@selector(textFieldShouldReturn:)
        fromProtocol:@protocol(UITextFieldDelegate)]
    	subscribeNext:^(RACTuple *tuple) {
            @strongify(self)
            if (tuple.first == self.passwordTextField) [self.viewModel.loginCommand execute:nil];
        }];

    self.passwordTextField.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)bindViewModel {
    [super bindViewModel];

	@weakify(self)
    //监听 用户头像的url 如果改变则更新用户头像
    [RACObserve(self.viewModel, avatarURL) subscribeNext:^(NSURL *avatarURL) {
    	@strongify(self)
        [self.avatarButton sd_setImageWithURL:avatarURL forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"default-avatar"]];
    }];

    //监听 用户头像是否被点击
    [[self.avatarButton
        rac_signalForControlEvents:UIControlEventTouchUpInside]
        subscribeNext:^(UIButton *avatarButton) {
            @strongify(self)
            MRCSharedAppDelegate.window.backgroundColor = [UIColor blackColor];

            TGRImageViewController *viewController = [[TGRImageViewController alloc] initWithImage:[avatarButton imageForState:UIControlStateNormal]];

            viewController.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
            viewController.transitioningDelegate = self;

            [self presentViewController:viewController animated:YES completion:NULL];
        }];

    //用户名和密码model与 对应两个编辑文本框进行内容绑定，文本框类容改变是赋值给username和password
    RAC(self.viewModel, username) = self.usernameTextField.rac_textSignal;
    RAC(self.viewModel, password) = self.passwordTextField.rac_textSignal;

    //登录和改变令牌 操作的 组合
    [[[RACSignal
      	merge:@[ self.viewModel.loginCommand.executing, self.viewModel.exchangeTokenCommand.executing ]]
        doNext:^(id x) {
            @strongify(self)
            [self.view endEditing:YES];
        }]
    	subscribeNext:^(NSNumber *executing) {
            @strongify(self)
            if (executing.boolValue) {
                [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES].labelText = @"Logging in...";
            } else {
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            }
        }];

    //登录和改变令牌 操作失败后的操作组合
    [[RACSignal
        merge:@[ self.viewModel.loginCommand.errors, self.viewModel.exchangeTokenCommand.errors ]]
        subscribeNext:^(NSError *error) {
            @strongify(self)
            if ([error.domain isEqual:OCTClientErrorDomain] && error.code == OCTClientErrorAuthenticationFailed) {
                MRCError(@"Incorrect username or password");
            } else if ([error.domain isEqual:OCTClientErrorDomain] && error.code == OCTClientErrorTwoFactorAuthenticationOneTimePasswordRequired) {
                NSString *message = @"Please enter the 2FA code you received via SMS or read from an authenticator app";
                
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:MRC_ALERT_TITLE
                                                                                         message:message
                                                                                  preferredStyle:UIAlertControllerStyleAlert];

                [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                    textField.returnKeyType = UIReturnKeyGo;
                    textField.placeholder = @"2FA code";
                    textField.secureTextEntry = YES;
                }];

                [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:NULL]];

                [alertController addAction:[UIAlertAction actionWithTitle:@"Login" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    @strongify(self)
                    [self.viewModel.loginCommand execute:[alertController.textFields.firstObject text]];
                }]];

                [self presentViewController:alertController animated:YES completion:NULL];
            } else {
                MRCError(error.localizedDescription);
            }
        }];

    //如果输入账号密码都合法则登录按钮可点击
    RAC(self.loginButton, enabled) = self.viewModel.validLoginSignal;
    
    //登录按钮 与动作绑定，当点击登录按钮时 执行登录操作
    [[self.loginButton
        rac_signalForControlEvents:UIControlEventTouchUpInside]
        subscribeNext:^(id x) {
            @strongify(self)
            //执行 登录操作
            [self.viewModel.loginCommand execute:nil];
        }];

    self.browserLoginButton.rac_command = self.viewModel.browserLoginCommand;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    if ([presented isKindOfClass:TGRImageViewController.class]) {
        return [[TGRImageZoomAnimationController alloc] initWithReferenceImageView:self.avatarButton.imageView];
    }
    return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    if ([dismissed isKindOfClass:TGRImageViewController.class]) {
        return [[TGRImageZoomAnimationController alloc] initWithReferenceImageView:self.avatarButton.imageView];
    }
    return nil;
}

@end
