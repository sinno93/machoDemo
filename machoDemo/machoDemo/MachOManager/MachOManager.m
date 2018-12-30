//
//  MachOManager.m
//  machoDemo
//
//  Created by Sinno on 2018/12/30.
//  Copyright © 2018 sinno. All rights reserved.
//

#import "MachOManager.h"

@implementation MachOManager
// 单例
+(instancetype)shareManager{
    static MachOManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[MachOManager alloc]init];
    });
    return manager;
}

@end
