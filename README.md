# Ninoude
http accessor.


## 使い方
```swift
let request = URLRequest(url: URL(string: "https://httpbin.org/")!)

// asyncronus access
Ninoude(request: request)
    .didRedirect { newRequest, response in print("Response ->", response, "\nredirect to ->", newRequest) }
    .futureResponse(queue: .main)
    .onSuccess { response in
        
        print(response.data.flatMap { String(data: $0, encoding: .utf8) } ?? "")
    }
    .onFailure { error in
        
        print(error)
}

// syncronus access
Ninoude(request: request)
    .didRedirect { newRequest, response in print("Response ->", response, "\nredirect to ->", newRequest) }
    .response()
    .ifValue { response in
        
        print(response.data.flatMap { String(data: $0, encoding: .utf8) } ?? "")
    }
    .ifError { error in
        
        print(error)
}
```

## Response
```swift
public struct Response {
    
    public let request: URLRequest?
    
    public let response: HTTPURLResponse?
    
    public let data: Data?
    
}
```

## Asyncronus access

Ninoude method `futureResponse(queue:)` access HTTP server and return `Future<Response>`.
this method dose not block thread.


## Syncronus access

Ninoude method `response()` access HTTP server and return `Result<Response>`.
this method block thread.

