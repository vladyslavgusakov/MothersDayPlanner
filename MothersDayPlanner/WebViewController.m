//
//  WebViewController.m
//  MothersDayPlanner
//
//  Created by Robert Baghai on 5/19/16.
//  Copyright © 2016 V-RGB. All rights reserved.
//

#import "WebViewController.h"
@import WebKit;

@interface WebViewController ()

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self handleNullURL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)loadWebView {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.myURL]];
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.frame];
    [webView  loadRequest:request];
    self.view = webView;
}

/*
 *Just in case the URL is null, the user is notified and the webView never tries to load that website
 */

- (void)handleNullURL {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sorry!" message:@"This service did not provide a website" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okayAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [alertController addAction:okayAction];
    
    if (self.myURL == NULL) {
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        [self loadWebView];
    }
}

@end
