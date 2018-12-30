//
//  ViewController.m
//  machoDemo
//
//  Created by Sinno on 2018/12/30.
//  Copyright © 2018 sinno. All rights reserved.
//

#import "ViewController.h"
#import "MachOManager.h"


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *descLabel;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.descLabel.numberOfLines = 0;
    ImageItem *targetItem = [[MachOManager shareManager] imageWithClass:ViewController.class methodName:@"viewDidLoad"];
    NSLog(@"%@",targetItem);
    NSString *desc = [NSString stringWithFormat:@"%@",targetItem];
    self.descLabel.text = desc;
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)crashButtonClick:(id)sender {
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:nil];
}


@end
