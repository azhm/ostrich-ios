import NetworkExtension
import SwiftyJSON

let appGroup = "group.myway.ostrich"
let share = TrojanCinfig.share
class PacketTunnelProvider: NEPacketTunnelProvider {
    let config = """
               {
                "log": {
                    "level": "trace"
                },
                "dns": {
                    "servers": [
                        "1.1.1.1",
                        "8.8.8.8"
                    ]
                },
                "inbounds": [{
                    "protocol": "tun",
                    "settings": {
                        "fd": REPLACE-ME-WITH-THE-FD
                    }
                }],
                "outbounds": [{
                        "protocol": "chain",
                        "settings": {
                            "actors": [
                                "trojan_tls",
                                "trojan"
                            ]
                        },
                        "tag": "trojan_out"
                    },
                    {
                        "protocol": "tls",
                        "settings": {
                            "serverName":"walkonbit.site"
                        },
                        "tag": "trojan_tls"
                    },
                    {
                        "protocol": "trojan",
                        "settings": {
                            "address":"walkonbit.site",
                            "password": "251f6edc",
                            "port":9443
                        },
                        "tag": "trojan"
                    },
                    {
                      "protocol": "direct",
                      "tag": "direct_out"
                    }
                ],
                "router": {
                    "domainResolve": true,
                    "rules": [{
                    "ip": ["8.8.4.4", "1.1.1.1", "8.8.8.8"],
                    "target": "direct_out"
                     },
                    {
                       "external": [
                         "site:./site.dat:cn"
                       ],
                       "target": "direct_out"
                     },
                     {
                       "external": [
                         "mmdb:./geo.mmdb:cn"
                       ],
                       "target": "direct_out"
                     }
                    ]
                }
                }

    """
    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        let tunnelNetworkSettings = createTunnelSettings()
        NSLog("-------PacketTunnelProvider--------")
           setTunnelNetworkSettings(tunnelNetworkSettings) { [weak self] error in
            let tunFd = self?.tunnelFileDescriptor
//            let confWithFd = self?.config.replacingOccurrences(of: "REPLACE-ME-WITH-THE-FD", with:String(tunFd!))
//            将ios tun设备的文件描述符写入配置文件
            share.trojanJson["inbounds"][0]["settings"]["fd"] = JSON(tunFd!)
            let shareDefault = UserDefaults(suiteName: "group.myway.ostrich")
            let ip = shareDefault?.string(forKey: "ip")
            let port = shareDefault?.integer(forKey: "port")
            share.trojanJson["outbounds"][1]["settings"]["serverName"] = JSON(ip!)
            share.trojanJson["outbounds"][2]["settings"]["address"] = JSON(ip!)
            share.trojanJson["outbounds"][2]["settings"]["port"] = JSON(port!)
            //将json对象转换成json字符串
//            NSLog("-----string-----\(share.trojanJson)")
            NSLog("-----json-----\(JSON(share.trojanJson).description)")
            let confWithFd = JSON(share.trojanJson).description
            let url = FileManager().containerURL(forSecurityApplicationGroupIdentifier: appGroup)!.appendingPathComponent("running_config.json")
                         do {
                             NSLog("succed to write config file")
                             try confWithFd.write(to: url, atomically: false, encoding: .utf8)
                         } catch {
                             NSLog("fialed to write config file \(error)")
                         }
            let path = url.absoluteString
            let start = path.index(path.startIndex, offsetBy: 7)
            let subpath = path[start..<path.endIndex]
            NSLog("-----path-----\(path)")
            NSLog("-----subpath-----\(subpath)")
            DispatchQueue.global(qos: .userInteractive).async {
                signal(SIGPIPE, SIG_IGN)
                leaf_run(0,String(subpath))
            }
            completionHandler(nil)
        }
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        // Add code here to handle the message.
        if let handler = completionHandler {
            handler(messageData)
        }
    }
    
    override func sleep(completionHandler: @escaping () -> Void) {
        // Add code here to get ready to sleep.
        completionHandler()
    }
    
    override func wake() {
        // Add code here to wake up.
    }
    
    func createTunnelSettings() -> NEPacketTunnelNetworkSettings  {
        let newSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "240.0.0.10")
        newSettings.ipv4Settings = NEIPv4Settings(addresses: ["240.0.0.1"], subnetMasks: ["255.255.255.0"])
        newSettings.ipv4Settings?.includedRoutes = [NEIPv4Route.`default`()]
        newSettings.proxySettings = nil
        newSettings.dnsSettings = NEDNSSettings(servers: ["223.5.5.5", "8.8.8.8"])
        newSettings.mtu = 1500
        return newSettings
    }
    
    private var tunnelFileDescriptor: Int32? {
           if #available(iOS 15, macOS 12, *) {
               var buf = [CChar](repeating: 0, count: Int(IFNAMSIZ))
               let utunPrefix = "utun".utf8CString.dropLast()
    
                return (0...1024).first { (_ fd: Int32) -> Bool in
                    var len = socklen_t(buf.count)
                return getsockopt(fd, 2 /* SYSPROTO_CONTROL */, 2, &buf, &len) == 0 && buf.starts(with: utunPrefix)
               }
           } else {
               return self.packetFlow.value(forKeyPath: "socket.fileDescriptor") as? Int32
            }
         }
     
   
}
