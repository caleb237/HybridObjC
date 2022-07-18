//
//  NSMutableDictionary+JSON.m
//  ods
//
//  Created by Mac on 2018. 6. 18..
//  Copyright © 2018년 Mac. All rights reserved.
//

#import "NSMutableDictionary+JSON.h"

@implementation NSMutableDictionary (JSON)

-(NSString*)convertJsonPrettyPrint:(BOOL)isPrettyPrint {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:(NSJSONWritingOptions)(isPrettyPrint?NSJSONWritingPrettyPrinted:0)
                                                         error:&error];
    if (!jsonData) {
        NSLog(@">>>>>>>>>>>>>>> %s: error: %@", __func__, error.localizedDescription);
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

@end
