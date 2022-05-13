//
//  ViewController.m
//  JavascriptBridgeOC
//
//  Created by 1 on 2022/3/22.
//

#import "ViewController.h"
#import "WebViewController.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *touchBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [self setupNav];
    // Do any additional setup after loading the view.
}

- (void)setupView {
    self.view.backgroundColor = [UIColor whiteColor];
    NSLog(@"ViewController enter");
}

- (void)setupNav {
    self.title = @"MainViewController";
}
- (IBAction)touchMe:(UIButton *)sender {
    WebViewController * webViewController = [[WebViewController alloc]init];
    [self.navigationController pushViewController:webViewController animated:YES];
}

@end
