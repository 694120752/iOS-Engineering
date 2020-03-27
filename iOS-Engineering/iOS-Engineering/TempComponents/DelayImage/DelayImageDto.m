//
//  DelayImageDto.m
//  iOS-Engineering
//
//  Created by zjs on 2019/6/19.
//  Copyright © 2019 zjs. All rights reserved.
//

#import "DelayImageDto.h"

@implementation DelayImageDto
- (void)dealloc {
    //    NSLog(@"dealloc", nil);
}

//获取image
- (UIImage *)imageNamed:(NSString *)name {
    return [self.imgDict valueForKey:name];
}

#pragma mark property
- (NSMutableDictionary *)imgDict {
    if (!_imgDict) {
        _imgDict = [NSMutableDictionary dictionaryWithCapacity:self.imgNameArray.count];
    }
    return _imgDict;
}

@end
