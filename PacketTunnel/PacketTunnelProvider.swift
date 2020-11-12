import NetworkExtension
import SwiftyJSON

let appGroup = "group.org.ostrich.f"
let share = TrojanCinfig.share
class PacketTunnelProvider: NEPacketTunnelProvider {
    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        let tunnelNetworkSettings = createTunnelSettings()
        NSLog("-------PacketTunnelProvider--------")
           setTunnelNetworkSettings(tunnelNetworkSettings) { [weak self] error in
            let tunFd = self?.packetFlow.value(forKeyPath: "socket.fileDescriptor") as! Int32
            NSLog("\(tunFd)")//打印tun设备的文件描述符
            //将ios tun设备的文件描述符写入配置文件
            share.trojanJson["inbounds"][0]["settings"]["fd"] = JSON(tunFd)
            //将json对象转换成json字符串
            let confWithFd = JSON(share.trojanJson).description
            NSLog("-----json-----\(confWithFd)")
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
            DispatchQueue.global(qos: .userInteractive).async {
                signal(SIGPIPE, SIG_IGN)
                run_leaf(String(subpath))
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
   
}
