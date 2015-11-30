//
//  DataStore.swift
//  MilkCocoa
//
//  Created by HIYA SHUHEI on 2015/11/03.
//  Copyright © 2015年 Shuhei Hiya. All rights reserved.
//

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