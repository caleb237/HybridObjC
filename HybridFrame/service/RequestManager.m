//
//  RequestManager.m
//  SCiP
//
//  Created by ym on 2016. 1. 13..
//  Copyright © 2016년 samsungcard. All rights reserved.
//

#import "RequestManager.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <MobileCoreServices/UTType.h>

@implementation RequestManager

+ (RequestManager*)manager
{
    return [[RequestManager alloc] init];
}

// post 데이타 통신
- (void)post:(NSString *)url headers:(NSDictionary *)headers params:(NSDictionary *)params completion:(void (^)(NSDictionary *resultDic, NSError *error))completion
{
    // TODO 암호화 시 처리
    //    if (self.encryptor) {
    //        data = [self.encryptor encode:data];
    //    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:TIME_OUT];
    [request setHTTPMethod:@"POST"];
    
    // =============== 파라미터 셋팅 ===================
    // 파라미터 =& 처리
    NSData *paramData = nil;
    NSMutableArray *paramArr = [NSMutableArray array];
    for (NSString *key in params)    {
        NSString *encKey = [key stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLHostAllowedCharacterSet];
        NSString *encValue = [AvoidNil([params objectForKey:key]) stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLHostAllowedCharacterSet];
        NSString *string = [NSString stringWithFormat:@"%@=%@", encKey, encValue];
        [paramArr addObject:string];
    }
    NSString *serializedParamStr = [paramArr componentsJoinedByString:@"&"];
    paramData = [serializedParamStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:paramData];
    // =============== 파라미터 셋팅 ===================
    
    // 파라미터를 json으로 serialize 하는 방법
    //    @try {
    //        paramData = [NSJSONSerialization dataWithJSONObject:dataObj options:NSJSONWritingPrettyPrinted error:NULL];
    //    } @catch (NSException *exception) {
    //        paramData = [NSData new];
    //    }
    //    [request setHTTPBody:paramData];
    //    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    // =============== header 셋팅 ===================
    // 추가헤더 셋팅
    if(headers) {
        for (NSString *key in headers) {
            [request addValue:AvoidNil([headers objectForKey:key]) forHTTPHeaderField:AvoidNil(key)];
        }
    }
    // 기본헤더 셋팅
    [request addValue:@"application/json" forHTTPHeaderField:@"accept"]; // 앱에서 Json 결과를 보장 받기위해 반드시 추가
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[paramData length]] forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"ko-kr,ko;q=0.8,en-us;q=0.5,en;q=0.3" forHTTPHeaderField:@"Accept-Language"];
    [request setValue:@"Keep-Alive" forHTTPHeaderField:@"Connection"];
    [request setValue:@"iOS" forHTTPHeaderField:@"mobileApp"];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    [request setValue:bundleIdentifier forHTTPHeaderField:@"X-Requested-With"];
    [request setValue:AvoidNil([ServiceManager sharedInstance].customUsrAgent) forHTTPHeaderField:@"User-Agent"];
    
    // =============== header 셋팅 ===================
    
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                             completionHandler:^(NSData *responseData, NSURLResponse *response, NSError *error)
                              {
                                  // 최종 결과 return dictionary
                                  id resultValue = [self commonHandleResponse:responseData response:response error:error];
                                  dispatch_sync(dispatch_get_main_queue(), ^{
                                      if(completion) {
                                          completion(resultValue, error);
                                      }
                                  });
                              }];
    [task resume];
}

// multipart 데이타 통신
- (void)multipart:(NSString *)url params:(NSDictionary *)params pics:(NSArray *)pics pNm:(NSString *)pNm fNm:(NSString *)fNm mimeTy:(NSString *)mimeTy completion:(void (^)(NSDictionary *resultDic, NSError *error))completion
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:TIME_OUT];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = [NSString stringWithFormat:@"Boundary-%@", [[NSUUID UUID] UUIDString]];
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
    
    // Body 만들기
    NSMutableData *httpBody = [NSMutableData data];
    // 파라미터 붙이기
    [params enumerateKeysAndObjectsUsingBlock:^(NSString *paramKey, id paramValue, BOOL *stop) {
        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", paramKey] dataUsingEncoding:NSUTF8StringEncoding]];
        // 값이 String일 경우 처리
        if([paramValue isKindOfClass:[NSString class]]) {
            [httpBody appendData:[[NSString stringWithFormat:@"%@\r\n", paramValue] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        // 값이 NSData일 경우 처리
        else if([paramValue isKindOfClass:[NSData class]]) {
            [httpBody appendData:paramValue];
            [httpBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }];
    
    // 이미지 붙이기
    for (int i=0; i<pics.count; i++) {
        NSString *fileNm;
        NSData *fileData;
        NSString *mimetype;
        id pic = [pics objectAtIndex:i];
        // NSData array가 들어온 경우 처리
        if([pic isKindOfClass:[NSData class]]) {
            // 사진 데이타
            fileData = pic;
            // 사징 이름
            if(pics.count==1) {
                fileNm = [NSString stringWithFormat:@"%@.%@", fNm, mimeTy];
            } else {
                fileNm = [NSString stringWithFormat:@"%@_%ld.%@", fNm, (long)i, mimeTy];
            }
            // 사진 타입
            mimetype = mimeTy;
        }
        // Path String array가 들어온 경우 처리
        else {
            NSString *path = pic;
            // 사진 데이타
            fileData = [NSData dataWithContentsOfFile:path];
            // 사진 이름
            fileNm = [path lastPathComponent];
            // 사진 타입
            mimetype  = [self mimeTypeForPath:path];
        }
        
        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", AvoidNil(pNm), AvoidNil(fileNm)] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimetype] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:fileData];
        [httpBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [httpBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:httpBody];
    
    NSURLSessionTask *task = [[NSURLSession sharedSession] uploadTaskWithRequest:request fromData:httpBody
                                                               completionHandler:^(NSData *responseData, NSURLResponse *response, NSError *error)
                              {
                                  // 최종 결과 return dictionary
                                  id resultValue = [self commonHandleResponse:responseData response:response error:error];
                                  dispatch_sync(dispatch_get_main_queue(), ^{
                                      completion(resultValue, error);
                                  });
                              }];
    [task resume];
}

// 공통 결과 처리
-(id)commonHandleResponse:(NSData *)responseData response:(NSURLResponse *)response error:(NSError *)error
{
    id resultValue;
    // response가 nil인 경우 처리
    if(responseData)
    {
        // TODO 암호화 시 처리
//                    if (self.encryptor) {
//                        responseData = [self.encryptor decode:responseData];
//                    }
        
#if TEST_MODE
        NSString *receivedDataString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSLog(@">>>>>>>>> 결과 디버깅 : %@",receivedDataString);
#endif
        
        NSError *parseErr;
        resultValue = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&parseErr];
        // json 파싱 에러 시 처리
        if (parseErr) {
            // 파싱 에러를 주지 않는다.
//            resultValue = @{
//                            kParseErrCode:[NSString stringWithFormat:@"%ld", parseErr.code],
//                            kParseErrDesc:parseErr.description
//                            };
            resultValue = [NSDictionary new];
        }
    }
    else
    {
        resultValue = [NSDictionary new];
    }
    
    // TODO 통신 에러 시 처리
    //        if (error && error.code == NSURLErrorNotConnectedToInternet) {
    //            NSLog(@"통신 에러 : %@", error.localizedDescription);
    //        }
    
    return resultValue;
}

// path에서 mime type 가져오기
- (NSString *)mimeTypeForPath:(NSString *)path {
    CFStringRef extension = (__bridge CFStringRef)[path pathExtension];
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, extension, NULL);
    assert(UTI != NULL);
    NSString *mimetype = CFBridgingRelease(UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType));
    assert(mimetype != NULL);
    CFRelease(UTI);
    return mimetype;
}

@end
