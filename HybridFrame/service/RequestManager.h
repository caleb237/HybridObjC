//
//  RequestManager.h
//  SCiP
//
//  Created by ym on 2016. 1. 13..
//  Copyright © 2016년 samsungcard. All rights reserved.
//

@interface RequestManager : NSObject

// 암호화 할 경우
//@property (nonatomic, strong) DataEncryptor *encryptor;   //데이터를 암호화할 객체

+ (RequestManager*)manager;

// post 데이타 통신
- (void)post:(NSString *)url headers:(NSDictionary *)headers params:(NSDictionary *)params completion:(void (^)(NSDictionary *resultDic, NSError *error))completion;

// multipart 데이타 통신
- (void)multipart:(NSString *)url params:(NSDictionary *)params pics:(NSArray *)pics pNm:(NSString *)pNm fNm:(NSString *)fNm mimeTy:(NSString *)mimeTy completion:(void (^)(NSDictionary *resultDic, NSError *error))completion;
@end
