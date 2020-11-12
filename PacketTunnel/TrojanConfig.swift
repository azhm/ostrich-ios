//
//  TrojanConfig.swift
//  PacketTunnel
//
//  Created by admin on 2020/11/11.
//
//trojan配置类
import Foundation
import SwiftyJSON

class TrojanCinfig{
    static let share = TrojanCinfig()
    var trojanJson: JSON = [
        "log": [
            "level": "info",
            "output": "console"
        ],
        "dns": [
            "servers": [
                "1.1.1.1",
                "8.8.8.8"
            ]
        ],
        "inbounds": [[
            "protocol": "tun",
            "settings": [
                "fd": 0
            ]
            ]
        ],
        "outbounds": [[
                "protocol": "chain",
                "settings": [
                    "actors": [
                        "trojan_tls",
                        "trojan"
                    ]
                ],
                "tag": "trojan_out"
            ],
            [
                "protocol": "tls",
                "tag": "trojan_tls"
            ],
            [
                "protocol": "trojan",
                "settings": [
                    "address": "fbenpao.top",
                    "password": "251f6edc",
                    "port": 9443
                ],
                "tag": "trojan"
            ]

        ]
    ]
    
    //字典转JSON
    func convertDictionaryToJSONString(dict:NSDictionary?)->String {
        let data = try? JSONSerialization.data(withJSONObject: dict!, options: JSONSerialization.WritingOptions.init(rawValue: 0))
        let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
        return jsonStr! as String
    }
    //JSON转字典
    func convertJSONStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: [JSONSerialization.ReadingOptions.init(rawValue: 0)]) as? [String:AnyObject]
            } catch let error as NSError {
                 print(error)
            }
        }
        return nil
    }
    

}
