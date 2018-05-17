//
//  CurlWrapper.h
//  CurlWrapper
//
//  Created by Hori,Masaki on 2018/05/05.
//  Copyright © 2018年 Hori,Masaki. All rights reserved.
//

@import Curl;

typedef enum {
    
    GET,
    POST,
    PUT,
} CURL_HTTP_METHOD;

CURLcode CWSetUseragent(CURL *curl, char *useragent);


CURLcode CWSetUrl(CURL *curl, char *url);

CURLcode CWSetTimeout(CURL* curl, long timeout);

CURLcode CWSetMethod(CURL *curl, CURL_HTTP_METHOD method);

CURLcode CWSetHeaders(CURL *curl, struct curl_slist *headers);

CURLcode CWSetCookieFile(CURL *curl, char *filename);


CURLcode CWSetBody(CURL *curl, char *body);

CURLcode CWSetData(CURL *curl, void *data);
CURLcode CWSetWriteFunc(CURL *curl, curl_write_callback function);

CURLcode CWSetHeaderData(CURL *curl, void *data);
CURLcode CWSetWriteHeaderFunc(CURL *curl, curl_write_callback function);
