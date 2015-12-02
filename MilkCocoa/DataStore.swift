/*
//
//  DataStore.swift
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

public class DataStore {

    private var milkcocoa : MilkCocoa
    private var path : String
    private var send_callback : ((DataElement)->Void)?
    private var push_callback : ((DataElement)->Void)?
    
    public init(milkcocoa: MilkCocoa, path: String) {
        self.milkcocoa = milkcocoa;
        self.path = path;
        self.send_callback = nil;
    }
    
    public func on(event: String, callback: (DataElement)->Void) {
        self.milkcocoa.subscribe(self.path, event: event)
        if(event == "send") {
            self.send_callback = callback
        }else if(event == "push"){
            self.push_callback = callback
        }
    }
    
    public func send(params : [String: AnyObject]) {
        self.milkcocoa.publish(self.path, event: "send", params: [
            "params":params])
    }
    
    public func push(params : [String: AnyObject]) {
        self.milkcocoa.publish(self.path, event: "push", params: [
            "params":params])
    }
    
    public func _fire_send(params : DataElement) {
        if let _send_cb = self.send_callback {
            _send_cb(params)
        }
    }
    public func _fire_push(params : DataElement) {
        if let _send_cb = self.push_callback {
            _send_cb(params)
        }
    }
    public func history()->History {
        return History(datastore: self)
    }
}


public class DataElement {
    
    private var _data : [String: AnyObject];
    
    public init(_data : [String: AnyObject]) {
        self._data = Dictionary();
        self.fromRaw(_data);
    }
    
    public func fromRaw(rawdata : [String: AnyObject]) {
        self._data["id"] = rawdata["id"]
        do {
            if(rawdata["params"] != nil) {
                //in case of on
                let params = rawdata["params"]
                self._data["value"] = params
            }else if(rawdata["value"] != nil) {
                //in case of query
                let valueJSON = rawdata["value"] as! String
                let valueJSON_data = valueJSON.dataUsingEncoding(NSUTF8StringEncoding)
                self._data["value"] = try NSJSONSerialization.JSONObjectWithData(valueJSON_data!, options: NSJSONReadingOptions.AllowFragments) as! [String: AnyObject]
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    public func getId()->String {
        return self._data["id"] as! String;
    }
    
    public func getValue()->[String: AnyObject] {
        return self._data;
    }
    
    public func getValue(key:String)->AnyObject? {
        return self._data[key];
    }
    
}

public protocol HistoryDelegate : class {
    func onData(dataelement: DataElement);
    func onError(error: NSError);
    func onEnd();
}

public class History {
    public weak var delegate: HistoryDelegate?
    private var datastore : DataStore;
    private var onDataHandler :([DataElement]->Void)?
    private var onErrorHandler :(NSError->Void)?
    
    public init(datastore: DataStore) {
        self.datastore = datastore
        self.onDataHandler = nil
    }
    public func onData(h:[DataElement]->Void) {
        self.onDataHandler = h
    }
    public func onError(h:NSError->Void) {
        self.onErrorHandler = h
    }
    public func run() {
        self.datastore.milkcocoa.call("query", params: ["path":self.datastore.path, "limit":"50", "sort":"DESC"], callback: { data -> Void in
                print(data)
                /*
                let content = data["content"]
                let dataelementlist:[DataElement]? = content!["d"].map({
                    DataElement(_data: $0 as! [String : AnyObject])
                })
                self.onDataHandler?(dataelementlist!)
                */
            }, error_handler: { (error) -> Void in
                self.onErrorHandler?(error)
        })
    }
}
