
//
//  CurlWrapper.c
//  CURL
//
//  Created by Hori,Masaki on 2018/04/24.
//  Copyright © 2018年 Hori,Masaki. All rights reserved.
//

#include "CurlWrapper.h"


CURLcode CWSetUseragent(CURL *curl, char *useragent) {
    
    return curl_easy_setopt(curl, CURLOPT_USERAGENT, useragent);
}


CURLcode CWSetUrl(CURL *curl, char *url) {
    
    return curl_easy_setopt(curl, CURLOPT_URL, url);
}

CURLcode CWSetTimeout(CURL* curl, long timeout) {
    
    return curl_easy_setopt(curl, CURLOPT_TIMEOUT, timeout);
}

CURLcode CWSetMethod(CURL *curl, CURL_HTTP_METHOD method) {
    
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

CURLcode CWSetHeaders(CURL *curl, struct curl_slist *headers) {
    
    return curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
}

CURLcode CWSetCookieFile(CURL *curl, char *filename) {
    
    CURLcode code = curl_easy_setopt(curl, CURLOPT_COOKIEJAR, filename);
    if(code != CURLE_OK) {
        fprintf(stderr, "Can not set cookie file.\n");
        fprintf(stderr, "CURL Error no: %u", code);
        
        return code;
    }
    
    return curl_easy_setopt(curl, CURLOPT_COOKIEJAR, filename);
}


CURLcode CWSetBody(CURL *curl, char *body) {
    
    return curl_easy_setopt(curl, CURLOPT_WRITEDATA, body);
}

CURLcode CWSetData(CURL *curl, void *data) {
    
    return curl_easy_setopt(curl, CURLOPT_WRITEDATA, data);
}

CURLcode CWSetWriteFunc(CURL *curl, curl_write_callback function) {
    
    return curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, function);
}

CURLcode CWSetHeaderData(CURL *curl, void *data) {
    
    return curl_easy_setopt(curl, CURLOPT_HEADERDATA, data);
}

CURLcode CWSetWriteHeaderFunc(CURL *curl, curl_write_callback function) {
    
    return curl_easy_setopt(curl, CURLOPT_HEADERFUNCTION, function);
}
