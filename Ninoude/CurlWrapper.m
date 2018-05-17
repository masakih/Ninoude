
//
//  CurlWrapper.c
//  CURL
//
//  Created by Hori,Masaki on 2018/04/24.
//  Copyright © 2018年 Hori,Masaki. All rights reserved.
//

#include "CurlWrapper.h"


CURLcode curl_easy_setuseragent(CURL *curl, char *useragent) {
    
    return curl_easy_setopt(curl, CURLOPT_USERAGENT, useragent);
}


CURLcode curl_easy_seturl(CURL *curl, char *url) {
    
    return curl_easy_setopt(curl, CURLOPT_URL, url);
}

CURLcode curl_easy_settimeout(CURL* curl, long timeout) {
    
    return curl_easy_setopt(curl, CURLOPT_TIMEOUT, timeout);
}

CURLcode curl_easy_setmethod(CURL *curl, CURL_HTTP_METHOD method) {
    
    CURLcode result = 0;
    
    switch(method) {
            
        case GET:
            result = curl_easy_setopt(curl, CURLOPT_HTTPGET, 1L);
            break;
        case POST:
            result = curl_easy_setopt(curl, CURLOPT_POST, 1L);
            break;
        case PUT:
            result = curl_easy_setopt(curl, CURLOPT_PUT, 1L);
            break;
    }
    
    return result;
}

CURLcode curl_easy_setHeaders(CURL *curl, struct curl_slist *headers) {
    
    return curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
}

CURLcode curl_easy_setcookiefile(CURL *curl, char *filename) {
    
    CURLcode code = curl_easy_setopt(curl, CURLOPT_COOKIEJAR, filename);
    if(code != CURLE_OK) {
        fprintf(stderr, "Can not set cookie file.\n");
        fprintf(stderr, "CURL Error no: %u", code);
        
        return code;
    }
    
    return curl_easy_setopt(curl, CURLOPT_COOKIEJAR, filename);
}


CURLcode curl_easy_setbody(CURL *curl, char *body) {
    
    return curl_easy_setopt(curl, CURLOPT_WRITEDATA, body);
}

CURLcode curl_easy_setdata(CURL *curl, void *data) {
    
    return curl_easy_setopt(curl, CURLOPT_WRITEDATA, data);
}

CURLcode curl_easy_setwritefunc(CURL *curl, curl_write_callback function) {
    
    return curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, function);
}

CURLcode curl_easy_setheaderdata(CURL *curl, void *data) {
    
    return curl_easy_setopt(curl, CURLOPT_HEADERDATA, data);
}

CURLcode curl_easy_setwriteheaderfunc(CURL *curl, curl_write_callback function) {
    
    return curl_easy_setopt(curl, CURLOPT_HEADERFUNCTION, function);
}
