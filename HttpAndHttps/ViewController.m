//
//  ViewController.m
//  HttpAndHttps
//
//  Created by LIAN on 16/5/5.
//  Copyright © 2016年 com.Alice. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UIWebViewDelegate,NSURLConnectionDelegate,NSURLConnectionDataDelegate>

{
    NSMutableData *_contentData;
    NSURLConnection *_urlConnection;
    BOOL _authenticated;
    NSURLRequest *_request;
}
@property (strong,nonatomic) NSString *urlStr; //url请求
@property (strong,nonatomic) NSString *lastUrl;//最后一次的url请求
@property (strong,nonatomic) UIWebView *showView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _contentData = [[NSMutableData alloc]init];
    //http://test.blh.paipian.leying.com:88   预发布
    // 某个页面 https://test.hd.paipian.leying.com:445/
    
    self.urlStr = [NSString stringWithFormat:@"http://test.blh.paipian.leying.com:88"];
    
    NSURL *url = [[NSURL alloc] initWithString:self.urlStr];
    _request = [NSURLRequest requestWithURL:url];
//    NSURLSession

    
    
    self.showView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height-20.0f)];
    self.showView.delegate = self;
    
    self.showView.scrollView.bounces = NO;//webview滑动的弹簧效果
    //    self.showView.scrollView.scrollEnabled = YES;
    [self.showView loadRequest:_request];
    self.showView.backgroundColor = [UIColor colorWithRed:90/255.0 green:196/255.0 blue:211/255.0 alpha:1.0];
    
    
    [self.view addSubview:self.showView];
}
#pragma mark == webViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"加载数据中。。。。");
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"加载完成！！！！");
    
    self.lastUrl = [NSString stringWithFormat:@"%@",webView.request.URL.absoluteString];
    NSLog(@"测试当前页面的 url ------- %@",webView.request.URL.absoluteString);
    
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"加载失败");

}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;

{
    NSLog(@"Did start loading: %@ auth:%d", [[request URL]absoluteString],_authenticated);
    
    if (!_authenticated) {
        
        _authenticated = NO;
        _urlConnection = [[NSURLConnection alloc] initWithRequest:_request delegate:self];
        [_urlConnection start];
          return NO;
    }
    
    return YES;
    
}
#pragma mark === connectDelegate

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
{
    NSLog(@"WebController Got auth challange via NSURLConnection");
    
    if ([challenge previousFailureCount] == 0)
    {
        _authenticated = YES;
        
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        
        [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
        
    } else
    {
        [[challenge sender] cancelAuthenticationChallenge:challenge];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
{
    NSLog(@"WebController received response via NSURLConnection");
    
    // remake a webview call now that authentication has passed ok.
    _authenticated = YES;
    [self.showView loadRequest:_request];
    
    // Cancel the URL connection otherwise we double up (webview + url connection, same url = no good!)
    [_urlConnection cancel];
}

// We use this method is to accept an untrusted site which unfortunately we need to do, as our PVM servers are self signed.
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
