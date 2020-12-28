//
//  NetworkManager.swift
//  NetworkingTest
//
//  Created by Ghanshyam Maliwal on 26/09/20.
//  Copyright © 2020 Ghanshyam Maliwal. All rights reserved.
//

import Foundation

//
//  DownloadManager.swift
//  NetworkingTest
//
//  Created by Ghanshyam Maliwal on 25/09/20.
//  Copyright © 2020 Ghanshyam Maliwal. All rights reserved.
//

import Foundation

class SSLPinningAuthenticator : NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        //Step1: Check that the challenge is to trust the server
        //Step2: We check that it is the same host that we want to connect
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust, challenge.protectionSpace.host == "api.covid19api.com" else {
            
            // Otherwise allow defalt system to handle the challenge
            completionHandler(URLSession.AuthChallengeDisposition.performDefaultHandling,nil)
            return
        }
        
        //Step3: We start verifying the server credentials
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(URLSession.AuthChallengeDisposition.performDefaultHandling,nil)
            return
        }
        
        // Step4: Evaluate server certifiacte
        var result:SecTrustResultType =  SecTrustResultType.invalid
        SecTrustEvaluate(serverTrust, &result)
        guard result == SecTrustResultType.unspecified || result == SecTrustResultType.proceed else {
            completionHandler(URLSession.AuthChallengeDisposition.performDefaultHandling,nil)
            return
        }
        
        // We check number of certificates in the chain
        guard SecTrustGetCertificateCount(serverTrust) > 0 else {
            completionHandler(URLSession.AuthChallengeDisposition.performDefaultHandling,nil)
            return
        }
        
        // We are retriving the leaf certificate public key
        guard let publicKey = SecTrustCopyPublicKey(serverTrust) else {
            completionHandler(URLSession.AuthChallengeDisposition.performDefaultHandling,nil)
            return
        }
        
        let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, nil)
        
        // We will proceed with hashing concept here
        print("public key data --- \(publicKeyData)")
        
        
        let credential = URLCredential(trust: serverTrust)
        completionHandler(URLSession.AuthChallengeDisposition.useCredential, credential)
    }
}

class NetworkManager : NSObject {
    
    lazy var configuration : URLSessionConfiguration = { [weak self] in
        let config = URLSessionConfiguration.default
        config.allowsCellularAccess = true
        config.isDiscretionary = false
        config.timeoutIntervalForRequest = 20
        config.requestCachePolicy = .reloadIgnoringCacheData
        return config
    }()
    
    lazy var session : URLSession? = { [weak self] in
        if let configuration = self?.configuration {
            return URLSession(configuration: configuration, delegate: SSLPinningAuthenticator(), delegateQueue: nil)
        }
        return nil
    }()
    
    func fetchCovidData(forCountry countryIndex : Int, endPointURL apiURL : URL , successHandler: @escaping (Int,CovidDataModel?) -> Void, failureHandler: @escaping () -> Void) {
        
        let headers = [
            "Content-Type": "application/json"
        ]

        let request = NSMutableURLRequest(url: apiURL)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        
        let task = session?.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            
            if error == nil {
                if let data = data {
                    var dataModel = CovidDataParser().parse(responseData: data)
                    successHandler(countryIndex,dataModel)
                    return
                }
            }
            failureHandler()
        })
        
        task?.resume()
    }
}

