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
    private var send_callback : (([String: AnyObject])->Void)?
    
    public init(milkcocoa: MilkCocoa, path: String) {
        self.milkcocoa = milkcocoa;
        self.path = path;
        self.send_callback = nil;
    }
    
    public func on(event: String, callback: ([String: AnyObject])->Void) {
        self.milkcocoa.subscribe(self.path, event: event)
        self.send_callback = callback
    }
    
    public func send(params : [String: AnyObject]) {
        self.milkcocoa.publish(self.path, event: "send", params: [
            "params":params])
    }
    
    public func _fire_send(params : [String: AnyObject]) {
        if let _send_cb = self.send_callback {
            _send_cb(params)
        }
    }
    
}