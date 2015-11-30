//
//  CocoaMQTTMessage.swift
//  CocoaMQTT
//
//  Created by Feng Lee<feng@eqmtt.io> on 14/8/3.
//  Copyright (c) 2015 emqtt.io. All rights reserved.
//
/*
The MIT License (MIT)

Copyright (c) 2014 emqtt

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

/**
 * MQTT Message
 */
public class CocoaMQTTMessage {

    public var topic: String

    public var payload: [UInt8]

    //utf8 bytes array to string
    public var string: String? {
        get {
            return NSString(bytes: payload, length: payload.count, encoding: NSUTF8StringEncoding) as? String
        }
    }

    var qos: CocoaMQTTQOS = .QOS1

    var retain: Bool = false

    var dup: Bool = false

    init(topic: String, string: String, qos: CocoaMQTTQOS = .QOS1) {
        self.topic = topic
        self.payload = [UInt8](string.utf8)
        self.qos = qos
    }

    init(topic: String, payload: [UInt8], qos: CocoaMQTTQOS = .QOS1, retain: Bool = false, dup: Bool = false) {
        self.topic = topic
        self.payload = payload
        self.qos = qos
        self.retain = retain
        self.dup = dup
    }

}

/**
 * MQTT Will Message
 */
public class CocoaMQTTWill: CocoaMQTTMessage {

    public init(topic: String, message: String) {
        super.init(topic: topic, payload: message.bytesWithLength)
    }

}
