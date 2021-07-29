//
//  DictionaryViewModel.swift
//  LazyDictionary
//
//  Created by Yida Zhang on 2021-07-27.
//

import Foundation
import SwiftUI

class DictionaryViewModel: ObservableObject {
    @Binding var word: String
    
    init(word: Binding<String>) {
        self._word = word
    }
    
    // POST data to url
    func postDataAsynchronous(url: String, bodyData: String, completionHandler: (responseString: String!, error: NSError!) -> ()) {
        var URL: NSURL = NSURL(string: url)!
        var request:NSMutableURLRequest = NSMutableURLRequest(URL:URL)
        request.HTTPMethod = "POST";
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding);

        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()){

            response, data, error in

            var output: String!

            if data != nil {
                output = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
            }

            completionHandler(responseString: output, error: error)
        }
    }

    // Obtain the data
    func postDataSynchronous(url: String, bodyData: String, completionHandler: (responseString: String!, error: NSError!) -> ())
    {
        let URL: NSURL = NSURL(string: url)!
        var request:NSMutableURLRequest = NSMutableURLRequest(URL:URL)
        request.HTTPMethod = "POST"
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding);
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        var response: NSURLResponse?
        var error: NSError?

        // Send data
        let data = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: &error)

        var output: String! // Default to nil

        if data != nil{
            output =  NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
        }

        completionHandler(responseString: output, error: error)

    }
    
}
