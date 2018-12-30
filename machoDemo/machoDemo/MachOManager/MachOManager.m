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
- (ImageItem *)imageItemAtIndex:(int)index {
    return self.itemArray[index];
}

- (ImageItem *)imageAtAddress:(long long)address {
    ImageItem *targetItem = nil;
    for (ImageItem *item in self.itemArray) {
        if (item.startAddress <= address && item.endAddress > address ) {
            NSAssert(!targetItem, @"蝴蝶？");
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
//                    uint32_t memAddr = (sc->vmaddr + _dyld_get_image_vmaddr_slide(0) + sect->offset - sc->fileoff);
                    endAddress = startAddress + sc->vmsize - 1;// 左闭右开
                    //                    NSLog(@PRINT_STR,_dyld_get_image_name(0), sect->addr, sect->size, sect->offset, memAddr);
                    //                    txtSegRange->start = memAddr;
                    //                    txtSegRange->end = memAddr + sect->size;
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

@end
