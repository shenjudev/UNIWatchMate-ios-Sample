//
//  ViewController.m
//  UNIWatchMateDemo
//
//  Created by t_t on 2023/9/22.
//

#import "ViewController.h"
#import "DemoViewController.h"

@interface ViewController ()

@property (nonatomic, strong) WMPeripheral *watch;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    
    //    [[SJLogInfo sharedInstance] registerLevel: @"INFO"];
    //    [[SJLogInfo sharedInstance] registerLevel: @"DEBUG"];
    //
    //    [[WMLog sharedInstance] registerLogInfo:[SJLogInfo sharedInstance]];
    //    [[WMManager sharedInstance] registerWatchMate:[SJWatchFind sharedInstance]];
    //
    //    [[WMLog sharedInstance].log subscribeNext:^(NSString * _Nullable x) {
    //        CHLog(@"%@", x);
    //    }];

}
-(void)viewDidAppear:(BOOL)animated
{
    [self testForUseSdk];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.watch != nil) {
        [self.watch.connect restoreFactory];
        self.watch = nil;
        return;
    }
    //    @weakify(self);
    //    [[[WMManager sharedInstance] findWatchFromSearch:@"OSW-802N"] subscribeNext:^(WMPeripheral * _Nullable x) {
    //        @strongify(self);
    //
    //        if ([x.target.mac isEqualToString:@"35:53:78:0f:87:44"]) {
    //            self.watch = x;
    //            [self.watch.connect connect];
    //            [[WMManager sharedInstance] stopSearch:@"OSW-802N"];
    //        }
    //    } error:^(NSError * _Nullable error) {
    //
    //    }];
    
    WMPeripheralTargetModel *model = [[WMPeripheralTargetModel alloc]init];
    model.type = UNIWPeripheralFormTypeMac;
    model.name = @"";
    model.mac = @"35:53:78:0f:87:44";

    @weakify(self);
    [[[WMManager sharedInstance] findWatchFromTarget:model product:@"OSW-802N"] subscribeNext:^(WMPeripheral * _Nullable x) {
        @strongify(self);
        self.watch = x;
        [self.watch.connect connect];
    } error:^(NSError * _Nullable error) {

    }];
    
    //    NSString *code = @"https://static-ie.oraimo.com/oh.htm?mac=35:53:78:0f:87:44&projectname=OSW-802N&random=0123456";
    //    @weakify(self);
    //    [[[WMManager sharedInstance] findWatchFromQRCode:code]subscribeNext:^(WMPeripheral * _Nullable x) {
    //        @strongify(self);
    //        self.watch = x;
    //        [self.watch.connect connect];
    //    } error:^(NSError * _Nullable error) {
    //
    //    }];
    
    //    NSString *code = @"https://static-ie.oraimo.com/oh.htm?mac=15:7e:78:a2:4b:73&projectname=OSW-802N&random=0123456";
    //    @weakify(self);
    //    [[[WMManager sharedInstance] findWatchFromQRCode:code]subscribeNext:^(WMPeripheral * _Nullable x) {
    //        @strongify(self);
    //        self.watch = x;
    //        [self.watch.connect connect];
    //    } error:^(NSError * _Nullable error) {
    //
    //    }];
}

- (void)testForUseSdk{
    [[[UIApplication sharedApplication] keyWindow] setRootViewController:[DemoViewController new]];
}
@end
