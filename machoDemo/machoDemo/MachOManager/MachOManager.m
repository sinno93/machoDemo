//
//  MachOManager.m
//  machoDemo
//
//  Created by Sinno on 2018/12/30.
//  Copyright © 2018 sinno. All rights reserved.
//

#import "MachOManager.h"
#import <mach-o/dyld.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dlfcn.h>
#import <objc/runtime.h>
@interface MachOManager ()
@property (nonatomic, strong) NSArray *itemArray;
@end

@implementation MachOManager
// 单例
+(instancetype)shareManager{
    static MachOManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[MachOManager alloc]init];
        int count = _dyld_image_count();
        NSMutableArray *itemArrayM = [NSMutableArray array];
        for (int i = 0; i < count; i++) {
            [itemArrayM addObject:[self getImageItemWithIndex:i]];
        }
        manager.itemArray = itemArrayM.copy;
    });
    return manager;
}
- (ImageItem *)imageItemAtIndex:(UInt64)index {
    if (index < self.itemArray.count) {
        return self.itemArray[index];
    } else {
        return nil;
    }
}

- (ImageItem *)imageAtAddress:(long long)address {
    ImageItem *targetItem = nil;
    for (ImageItem *item in self.itemArray) {
        if (item.startAddress <= address && item.endAddress > address ) {
            NSAssert(!targetItem, @"这个地址在多个image中存在(实际上这是不可能的)");
            targetItem = item;
        }
    }
    return targetItem;
}

+ (ImageItem* )getImageItemWithIndex:(int )index {
    ImageItem *imageItem = [[ImageItem alloc] init];
    imageItem.fullName = [NSString stringWithFormat:@"%s",_dyld_get_image_name(index)];
    imageItem.shortName = [imageItem.fullName lastPathComponent];
    
    const struct mach_header * mach_header = _dyld_get_image_header(index);
    long long startAddress = (long long)mach_header;
    
    const struct load_command *firstComd = (const struct load_command *)((long)mach_header + 32);
    uint32_t comdCount = mach_header->ncmds;
    const struct load_command *lc;
    lc = firstComd;
    long long endAddress = 0;
    for (int i = 0; i < comdCount; i++) {
        if (lc->cmd == LC_SEGMENT_64) {
            const struct segment_command_64 *sc = (void *) lc;
            const struct section_64 *sect = (void *) (sc + 1);
            for(uint32_t sect_idx = 0; sect_idx < sc->nsects; sect_idx++) {
                if(!strcmp("__TEXT", sect->segname) && !strcmp("__text", sect->sectname)) {
                    endAddress = startAddress + sc->vmsize - 1;// 左闭右开
                    break;
                }
                sect++;
            }
        }
        lc = (void *) ((char *) lc + lc->cmdsize);
    }
    imageItem.startAddress = startAddress;
    imageItem.endAddress = endAddress;
    imageItem.slide = _dyld_get_image_vmaddr_slide(index);
    return imageItem;
}
- (NSArray <ImageItem *> *)imageWithClass:(Class)class methodName:(NSString *)targetmethodName {
    NSArray <NSNumber *> *addressArray = [self addressWithClass:class methodName:targetmethodName];
    NSMutableArray *itemArrayM = [NSMutableArray array];
    for (NSNumber *addressObj in addressArray) {
        long long address = [addressObj longLongValue];
        ImageItem *item = [self imageAtAddress:address];
        if (item) {
            [itemArrayM addObject:item];
        }
    }
    return itemArrayM;
}
- (NSArray<NSNumber *>*)addressWithClass:(Class)class methodName:(NSString *)targetmethodName {
    Class currentClass = class;
    NSMutableArray <NSNumber *> *addressArrayM = [NSMutableArray array];
    if (currentClass) {
        unsigned int methodCount;
        Method *methodList = class_copyMethodList(currentClass, &methodCount);
        IMP lastImp = NULL;
        for (NSInteger i = 0; i < methodCount; i++) {
            Method method = methodList[i];
            NSString *methodName = [NSString stringWithCString:sel_getName(method_getName(method))
                                                      encoding:NSUTF8StringEncoding];
            if ([targetmethodName isEqualToString:methodName]) {
                lastImp = method_getImplementation(method);
                NSString *str = [NSString stringWithFormat:@"%p",lastImp];
                long long  address = [self numberWithHexString:str];
                [addressArrayM addObject:[NSNumber numberWithLongLong:address]];
            }
        }
        free(methodList);
        return addressArrayM.copy;
    } else {
        return addressArrayM.copy;
    }
    
}

- (long long)numberWithHexString:(NSString *)hexString{
    
    const char *hexChar = [hexString cStringUsingEncoding:NSUTF8StringEncoding];
    
    long long hexNumber;
    
    sscanf(hexChar, "%llx", &hexNumber);
    
    return (long long)hexNumber;
}
@end
