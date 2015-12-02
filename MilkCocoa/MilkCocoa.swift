/*
//
//  MilkCocoa.swift
//  MilkCocoa
//
//  Created by HIYA SHUHEI on 2015/11/03.
//
The MIT License (MIT)

Copyright (c) 2014 Technical Rockstars, Inc

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import Foundation

public class MilkCocoa : CocoaMQTTDelegate {
    
    public let host: String
    private let app_id : String
    private let mqtt:CocoaMQTT
    private var dataStores: Dictionary<String, DataStore>
    private var onConnect:MilkCocoa->Void
    
    public init(app_id: String, host: String, onConnect:MilkCocoa->Void) {
        self.app_id = app_id;
        self.host = host;
        self.dataStores = Dictionary<String, DataStore>()
        self.onConnect = onConnect
        let clientIdPid = "sw" + String(NSProcessInfo().processIdentifier)
        self.mqtt = CocoaMQTT(clientId: clientIdPid, host: host, port: 8883)
        self.mqtt.username = "sdammy"
        self.mqtt.password = app_id
        self.mqtt.secureMQTT = true
        self.mqtt.cleanSess = false
        //mqtt.willMessage = CocoaMQTTWill(topic: "/will", message: "dieout")
        self.mqtt.keepAlive = 36
        self.mqtt.delegate = self
        self.mqtt.connect()
    }
    
    public func dataStore(path: String)->DataStore {
        self.dataStores[path] = DataStore(milkcocoa: self, path: path);
        return self.dataStores[path]!
    }
    
    public func publish(path : String, event : String, params : [String: AnyObject]) {
        let topic:String = self.app_id + "/" + path + "/" + event;
        do {
            let data:NSData? = try NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions())
            let payload:NSString = NSString(data:data!, encoding:NSUTF8StringEncoding)!
            self.mqtt.publish(topic, withString: payload as String, qos: CocoaMQTTQOS.QOS0);
        } catch let error as NSError {
            // Handle any errors
            print(error)
        }
    }
    
    public func subscribe(path : String, event : String) {
        let topic:String = self.app_id + "/" + path + "/" + event;
        mqtt.subscribe(topic, qos: CocoaMQTTQOS.QOS0)
    }
    
    public func mqtt(mqtt: CocoaMQTT, didConnect host: String, port: Int) {
        print("didConnect \(host):\(port)")
    }
    
    public func mqtt(mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        print("didConnectAck \(ack.rawValue)")
        self.onConnect(self)
        //mqtt.ping()
    }
    
    public func mqtt(mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("didPublishMessage to \(message.topic)")
    }
    
    public func mqtt(mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        print("didReceivedMessage with id \(id)")
        print("message.topic: \(message.topic)")
        print("message.payload: \(message.string)")
        
        let decided_string = message.string!.dataUsingEncoding(NSUTF8StringEncoding)
        let nstopic : NSString = message.topic;
        do {
            let content: [String: AnyObject] = try NSJSONSerialization.JSONObjectWithData(decided_string!, options: NSJSONReadingOptions.AllowFragments) as! [String: AnyObject]
            let index1:Int = message.topic.indexOf("/");
            let index2:Int = message.topic.lastIndexOf("/");
            let length:Int = message.topic.length;
            let path:String = message.topic.subString(index1+1, length: index2-index1-1)
            let event:String = message.topic.subString( index2+1, length: length - index2 - 1 )
            if let ds = self.dataStores[path] {
                if(event == "send"){
                    ds._fire_send(DataElement(_data:content))
                }else if(event == "push"){
                    ds._fire_push(DataElement(_data:content))
                }
            }
        } catch let error as NSError {
            // Handle any errors
            print(error)
        }
    }
    
    public func mqtt(mqtt: CocoaMQTT, didSubscribeTopic topic: String) {
        print("didSubscribeTopic to \(topic)")
        //mqtt.unsubscribe(topic)
    }
    
    public func mqtt(mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
        print("didUnsubscribeTopic to \(topic)")
    }
    
    public func mqttDidPing(mqtt: CocoaMQTT) {
        print("didPing")
    }
    
    public func mqttDidReceivePong(mqtt: CocoaMQTT) {
        _console("didReceivePong")
    }
    
    public func mqttDidDisconnect(mqtt: CocoaMQTT, withError err: NSError?) {
        _console("mqttDidDisconnect")
    }
    
    func _console(info: String) {
        print("Delegate: \(info)")
    }

    
    public func call(api:String, params: NSMutableDictionary, callback: (Dictionary<String, AnyObject>)->Void, error_handler: (NSError)->Void) {
        params["api"] = api;
        params["appid"] = self.app_id;
        //params["mlkccasid"] = self.session_id;
        getAsync("/api", params: params, callback: callback, error_handler: error_handler);
    }
    
    private func getAsync(path : String, params: NSDictionary, callback: (Dictionary<String, AnyObject>)->Void, error_handler: (NSError)->Void) {
        // create the url-request
        
        let urlString = "https://"+self.host+path + params.paramsString()
        var request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        
        // set the method(HTTP-GET)
        request.HTTPMethod = "GET"
        
        // use NSURLSessionDataTask
        var task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { data, response, error in
            if (error == nil) {
                var result = NSString(data: data!, encoding: NSUTF8StringEncoding)!
                let data = result.dataUsingEncoding(NSUTF8StringEncoding)
                do {
                    let content: [String: AnyObject] = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! [String: AnyObject]
                    callback(content)
                } catch let error as NSError {
                    // Handle any errors
                    print(error)
                }
            } else {
                error_handler(error!)
            }
        })
        task.resume()
        
    }
}

extension String
{
    var length: Int {
        get {
            return self.characters.count
        }
    }
    
    func contains(s: String) -> Bool
    {
        return (self.rangeOfString(s) != nil) ? true : false
    }
    
    func replace(target: String, withString: String) -> String
    {
        return self.stringByReplacingOccurrencesOfString(target, withString: withString, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    subscript (i: Int) -> Character
        {
        get {
            let index = startIndex.advancedBy(i)
            return self[index]
        }
    }
    
    subscript (r: Range<Int>) -> String
        {
        get {
            let startIndex = self.startIndex.advancedBy(r.startIndex)
            let endIndex = self.startIndex.advancedBy(r.endIndex - 1)
            
            return self[Range(start: startIndex, end: endIndex)]
        }
    }
    
    func subString(startIndex: Int, length: Int) -> String
    {
        var start = self.startIndex.advancedBy(startIndex)
        var end = self.startIndex.advancedBy(startIndex + length)
        return self.substringWithRange(Range<String.Index>(start: start, end: end))
    }
    
    func indexOf(target: String) -> Int
    {
        var range = self.rangeOfString(target)
        if let range = range {
            return self.startIndex.distanceTo(range.startIndex)
        } else {
            return -1
        }
    }
    
    func indexOf(target: String, startIndex: Int) -> Int
    {
        var startRange = self.startIndex.advancedBy(startIndex)
        
        var range = self.rangeOfString(target, options: NSStringCompareOptions.LiteralSearch, range: Range<String.Index>(start: startRange, end: self.endIndex))
        
        if let range = range {
            return self.startIndex.distanceTo(range.startIndex)
        } else {
            return -1
        }
    }
    
    func lastIndexOf(target: String) -> Int
    {
        var index = -1
        var stepIndex = self.indexOf(target)
        while stepIndex > -1
        {
            index = stepIndex
            if stepIndex + target.length < self.length {
                stepIndex = indexOf(target, startIndex: stepIndex + target.length)
            } else {
                stepIndex = -1
            }
        }
        return index
    }
    
    func isMatch(regex: String, options: NSRegularExpressionOptions) -> Bool
    {
        do {
            var exp = try NSRegularExpression(pattern: regex, options: options)
            var matchCount = exp.numberOfMatchesInString(self, options: NSMatchingOptions.Anchored, range: NSMakeRange(0, self.length))
            return matchCount > 0

        } catch let error as NSError {
            print(error.description)
        }
        return false;
    }
    
    func getMatches(regex: String, options: NSRegularExpressionOptions) -> [NSTextCheckingResult]
    {
        do {
            var exp = try NSRegularExpression(pattern: regex, options: options)
            var matches = exp.matchesInString(self, options: NSMatchingOptions.Anchored, range: NSMakeRange(0, self.length))
            return matches as [NSTextCheckingResult]
        } catch let error as NSError {
            print(error.description)
        }
        
        return [];
    }
    
    private var vowels: [String]
        {
        get
        {
            return ["a", "e", "i", "o", "u"]
        }
    }
    
    private var consonants: [String]
        {
        get
        {
            return ["b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p", "q", "r", "s", "t", "v", "w", "x", "z"]
        }
    }
    
    func pluralize(count: Int) -> String
    {
        if count == 1 {
            return self
        } else {
            var lastChar = self.subString(self.length - 1, length: 1)
            var secondToLastChar = self.subString(self.length - 2, length: 1)
            var prefix = "", suffix = ""
            
            if lastChar.lowercaseString == "y" && vowels.filter({x in x == secondToLastChar}).count == 0 {
                prefix = self[0...self.length - 1]
                suffix = "ies"
            } else if lastChar.lowercaseString == "s" || (lastChar.lowercaseString == "o" && consonants.filter({x in x == secondToLastChar}).count > 0) {
                prefix = self[0...self.length]
                suffix = "es"
            } else {
                prefix = self[0...self.length]
                suffix = "s"
            }
            
            return prefix + (lastChar != lastChar.uppercaseString ? suffix : suffix.uppercaseString)
        }
    }
}

extension NSDictionary{
    func paramsString() -> String {
        var pairs = NSMutableArray()
        for (key,value) in self as! [String:AnyObject]  {
            if value is NSDictionary {
                for (dictKey,dictValue) in value as! [String:String]{
                    pairs.addObject("\(key)[\(dictKey)]=\(escapString(dictValue))")
                }
            }else if value is NSArray {
                for arrayValue in value as! [String] {
                    pairs.addObject("\(key)[]=\(escapString(arrayValue))")
                }
            }else{
                pairs.addObject("\(key)=\(escapString(value as! String))")
            }
        }
        let queryString = pairs.componentsJoinedByString("&")
        return "?\(queryString)"
    }
    
    func escapString(value:String!) -> String {
        // エンコードしたくない文字セットを作成
        let customAllowedSet =  NSCharacterSet(charactersInString:"!*'()@&=+$,/?%#[];:").invertedSet
        // 指定された文字セット以外の文字を全てパーセントエンコーディング
        return value.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
    }
}