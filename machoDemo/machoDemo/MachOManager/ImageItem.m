//
//  ImageItem.m
//  machoDemo
//
//  Created by Sinno on 2018/12/30.
//  Copyright © 2018 sinno. All rights reserved.
//

#import "ImageItem.h"

@implementation ImageItem
- (NSString *)description {
    NSString *desc = [NSString stringWithFormat:@"name:%@,\n slide:%llu\n start:0x%llx\n end:0x%llx",self.shortName, self.slide,self.startAddress,self.endAddress];
    return desc;
}
@end
