# machoDemo
/**
 获取index个image的item

 @param index 从0开始
 @return ImageItem对象
 */
- (ImageItem *)imageItemAtIndex:(UInt64)index;

/**
 获取某个地址对应的ImageItem

 @param address 地址
 @return ImageItem, 可能为nil
 */
- (ImageItem *)imageAtAddress:(long long)address;


/**
 获取某类的某方法名对于的imageItem数组
 之所以是数组是因为有些方法可能有多个实现-比如分类覆盖原有方法实现的情况
 @param class 类;如UIImageView;
 @param targetmethodName 方法名;如@"initWithImage:"
 @return ImageItem数组 可能为空数组；
 */
- (NSArray <ImageItem *> *)imageWithClass:(Class)class methodName:(NSString *)targetmethodName;
