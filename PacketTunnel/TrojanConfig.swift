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
            "level": "trace"
        ],
        "dns": [
            "servers": [
                "1.1.1.1",
                "8.8.8.8"
            ]
        ],
        "inbounds": [
            [
                "protocol": "tun",
                "settings": [
                    "fd": 0
                ]
            ]
        ],
        "outbounds": [
            [
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
                "settings": [
                    "serverName": "walkonbit.site"
                ],
                "tag": "trojan_tls"
            ],
            [
                "protocol": "trojan",
                "settings": [
                    "address": "walkonbit.site",
                    "password": "251f6edc",
                    "port": 9443
                ],
                "tag": "trojan"
            ],
            [
                "protocol": "direct",
                "tag": "direct_out"
            ]
        ],
        "router": [
            "domainResolve": true,
            "rules": [
                [
                    "ip": [
                        "8.8.4.4",
                        "1.1.1.1",
                        "8.8.8.8"
                    ],
                    "target": "direct_out"
                ],
                [
                    "external": [
                        "site:./site.dat:cn"
                    ],
                    "target": "direct_out"
                ],
                [
                    "external": [
                        "mmdb:./geo.mmdb:cn"
                    ],
                    "target": "direct_out"
                ]
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
