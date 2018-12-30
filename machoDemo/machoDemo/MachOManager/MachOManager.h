//
//  MachOManager.h
//  machoDemo
//
//  Created by Sinno on 2018/12/30.
//  Copyright © 2018 sinno. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageItem.h"
NS_ASSUME_NONNULL_BEGIN

@interface MachOManager : NSObject
// 单例
+(instancetype)shareManager;
- (ImageItem *)imageItemAtIndex:(int)index;
- (ImageItem *)imageAtAddress:(long long)address;
- (ImageItem *)imageWithClass:(Class)class methodName:(NSString *)targetmethodName;
@end


NS_ASSUME_NONNULL_END

