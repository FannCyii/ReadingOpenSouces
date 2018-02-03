//
//  MRCLoginViewModel.m
//  MVVMReactiveCocoa
//
//  Created by leichunfeng on 14/12/27.
//  Copyright (c) 2014年 leichunfeng. All rights reserved.
//

#import "MRCLoginViewModel.h"
#import "MRCHomepageViewModel.h"
#import "MRCOAuthViewModel.h"

@interface MRCLoginViewModel ()

@property (nonatomic, copy, readwrite) NSURL *avatarURL;

@property (nonatomic, strong, readwrite) RACSignal *validLoginSignal;
@property (nonatomic, strong, readwrite) RACCommand *loginCommand;
@property (nonatomic, strong, readwrite) RACCommand *browserLoginCommand;
@property (nonatomic, strong, readwrite) RACCommand *exchangeTokenCommand;

@end

@implementation MRCLoginViewModel

- (void)initialize {
    [super initialize];
    
    //绑定用户头像， 如果用户名改变，则图像改变
    RAC(self, avatarURL) = [[RACObserve(self, username)
        map:^(NSString *username) {
            return [[OCTUser mrc_fetchUserWithRawLogin:username] avatarURL];
        }]
        distinctUntilChanged];
    
    //有效登录信号，用户名和密码长度都大于0
    self.validLoginSignal = [[RACSignal
    	combineLatest:@[ RACObserve(self, username), RACObserve(self, password) ]
        reduce:^(NSString *username, NSString *password) {
        	return @(username.length > 0 && password.length > 0);
        }]
        distinctUntilChanged];
    
    //定义名为doNext的闭包，参数是已认证客户信息
    @weakify(self)
    void (^doNext)(OCTClient *) = ^(OCTClient *authenticatedClient) {
        @strongify(self)
        //将当前用户存储到缓存中，是找一个字典
        [[MRCMemoryCache sharedInstance] setObject:authenticatedClient.user forKey:@"currentUser"];

        self.services.client = authenticatedClient;

        [authenticatedClient.user mrc_saveOrUpdate];
        [authenticatedClient.user mrc_updateRawLogin]; // The only place to update rawLogin, I hate the logic of rawLogin.
        
        SSKeychain.rawLogin = authenticatedClient.user.rawLogin;
        SSKeychain.password = self.password;
        SSKeychain.accessToken = authenticatedClient.token;
        
        MRCHomepageViewModel *viewModel = [[MRCHomepageViewModel alloc] initWithServices:self.services params:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.services resetRootViewModel:viewModel];
        });
    };
    
    [OCTClient setClientID:MRC_CLIENT_ID clientSecret:MRC_CLIENT_SECRET];
    
    /*下面是几个操作的定义*/
    
    //登录操作   RACCommand指的就是一些动作的执行，点击登录按钮是，调用loginCommand 的execute方法就会执行它的block
    self.loginCommand = [[RACCommand alloc] initWithSignalBlock:^(NSString *oneTimePassword) {
    	@strongify(self)
        OCTUser *user = [OCTUser userWithRawLogin:self.username server:OCTServer.dotComServer];
        return [[OCTClient
        	signInAsUser:user password:self.password oneTimePassword:oneTimePassword scopes:OCTClientAuthorizationScopesUser | OCTClientAuthorizationScopesRepository note:nil noteURL:nil fingerprint:nil]
            doNext:doNext];
    }];
    
    //浏览器登录操作
    self.browserLoginCommand = [[RACCommand alloc] initWithSignalBlock:^(id input) {
        @strongify(self)
        
        MRCOAuthViewModel *viewModel = [[MRCOAuthViewModel alloc] initWithServices:self.services params:nil];
        
        viewModel.callback = ^(NSString *code) {
            @strongify(self)
            [self.services popViewModelAnimated:YES];
            [self.exchangeTokenCommand execute:code];
        };
        
        [self.services pushViewModel:viewModel animated:YES];
        
        return [RACSignal empty];
    }];
    
    self.exchangeTokenCommand = [[RACCommand alloc] initWithSignalBlock:^(NSString *code) {
        OCTClient *client = [[OCTClient alloc] initWithServer:[OCTServer dotComServer]];
        
        return [[[[[client
            exchangeAccessTokenWithCode:code]
            doNext:^(OCTAccessToken *accessToken) {
                [client setValue:accessToken.token forKey:@"token"];
            }]
            flattenMap:^(id value) {
                return [[client
                    fetchUserInfo]
                    doNext:^(OCTUser *user) {
                        NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] init];
                        
                        [mutableDictionary addEntriesFromDictionary:user.dictionaryValue];
                        
                        if (user.rawLogin.length == 0) {
                            mutableDictionary[@keypath(user.rawLogin)] = user.login;
                        }
                        
                        user = [OCTUser modelWithDictionary:mutableDictionary error:NULL];
                        
                        [client setValue:user forKey:@"user"];
                    }];
            }]
            mapReplace:client]
            doNext:doNext];
    }];
}

- (void)setUsername:(NSString *)username {
    _username = [username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

@end
