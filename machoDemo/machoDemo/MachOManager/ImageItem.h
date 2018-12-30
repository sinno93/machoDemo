//
//  ImageItem.h
//  machoDemo
//
//  Created by Sinno on 2018/12/30.
//  Copyright © 2018 sinno. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageItem : NSObject
@property (nonatomic, copy) NSString *fullName;
@property (nonatomic, copy) NSString *shortName;
@property (nonatomic, assign) UInt64 slide; // 偏移量
@property (nonatomic, assign) UInt64 startAddress; // 起始地址
@property (nonatomic, assign) UInt64 endAddress; // 结束地址
@end

NS_ASSUME_NONNULL_END
