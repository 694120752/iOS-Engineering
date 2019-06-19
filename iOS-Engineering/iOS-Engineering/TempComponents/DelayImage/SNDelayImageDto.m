//
//  SNDelayImageDto.m
//  iOS-Engineering
//
//  Created by sn_zjs on 2019/6/19.
//  Copyright © 2019 sn_zjs. All rights reserved.
//

#import "SNDelayImageDto.h"

@implementation SNDelayImageDto
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
