//
//  ViewController.m
//  machoDemo
//
//  Created by Sinno on 2018/12/30.
//  Copyright © 2018 sinno. All rights reserved.
//

#import "ViewController.h"
#import "MachOManager.h"
#import <objc/runtime.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *descLabel;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.descLabel.numberOfLines = 0;
    long long address = [self testClass:ViewController.class methodName:@"viewDidLoad"];
    ImageItem *targetItem = [[MachOManager shareManager] imageAtAddress:address];
    NSLog(@"%@",targetItem);
    NSString *desc = [NSString stringWithFormat:@"%@",targetItem];
    self.descLabel.text = desc;
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)crashButtonClick:(id)sender {
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:nil];
}

- (long long)testClass:(Class)class methodName:(NSString *)targetmethodName {
    Class currentClass = class;
//    UIImageView *my = [[UIImageView alloc] init];
    
    if (currentClass) {
        unsigned int methodCount;
        Method *methodList = class_copyMethodList(currentClass, &methodCount);
        IMP lastImp = NULL;
        long long address = 0;
        for (NSInteger i = 0; i < methodCount; i++) {
            Method method = methodList[i];
            NSString *methodName = [NSString stringWithCString:sel_getName(method_getName(method))
                                                      encoding:NSUTF8StringEncoding];
            if ([targetmethodName isEqualToString:methodName]) {
                lastImp = method_getImplementation(method);
                NSString *str = [NSString stringWithFormat:@"%p",lastImp];
                long long  test = [self numberWithHexString:str];
                address = test;
                break;
            }
        }
//        typedef void (*fn)(id,SEL,NSURL *url);
//
//        if (lastImp != NULL) {
//            fn f = (fn)lastImp;
//            f(my,lastSel,nil);
//        }
        free(methodList);
        return address;
    }
    return 0;
}

- (long long)numberWithHexString:(NSString *)hexString{
    
    const char *hexChar = [hexString cStringUsingEncoding:NSUTF8StringEncoding];
    
    long long hexNumber;
    
    sscanf(hexChar, "%llx", &hexNumber);
    
    return (long long)hexNumber;
}

@end
