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

CURLcode curl_easy_setuseragent(CURL *curl, char *useragent);


CURLcode curl_easy_seturl(CURL *curl, char *url);

CURLcode curl_easy_settimeout(CURL* curl, long timeout);

CURLcode curl_easy_setmethod(CURL *curl, CURL_HTTP_METHOD method);

CURLcode curl_easy_setHeaders(CURL *curl, struct curl_slist *headers);

CURLcode curl_easy_setcookiefile(CURL *curl, char *filename);


CURLcode curl_easy_setbody(CURL *curl, char *body);

CURLcode curl_easy_setdata(CURL *curl, void *data);

CURLcode curl_easy_setwritefunc(CURL *curl, curl_write_callback function);
CURLcode curl_easy_setheaderdata(CURL *curl, void *data);

CURLcode curl_easy_setwriteheaderfunc(CURL *curl, curl_write_callback function);
