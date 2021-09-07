import UIKit
import NetworkExtension
import Toast_Swift
import SwiftyJSON

class ViewController: UIViewController {
    
    var manager = VPNManager.shared()
    
    @IBOutlet weak var userId: UITextField!
    

    @IBOutlet weak var connectButton: UIButton!
    
  
    
    @objc func updateStatus() {
        if(manager.manager.connection.status != .disconnected &&
                            manager.manager.connection.status != .disconnecting &&
            manager.manager.connection.status != .invalid){
            self.connectButton.setTitle("断开", for: UIControl.State.normal)
            self.connectButton.backgroundColor = .systemRed
        }else{
            self.connectButton.setTitle("连接", for: UIControl.State.normal)
            self.connectButton.backgroundColor = .systemBlue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tap) // Add gesture recognizer to background view
        
        manager.loadVPNPreference() { error in
            guard error == nil else {
                fatalError("load VPN preference failed: \(error.debugDescription)")
            }
            self.updateStatus()
            self.connectButton.addTarget(self, action: #selector(self.connectOrDisconnect), for: .touchUpInside)
            NotificationCenter.default.addObserver(self, selector: #selector(self.updateStatus), name: NSNotification.Name.NEVPNStatusDidChange, object: self.manager.manager.connection)
        }
    }
    
    //点击空白处关闭软键盘
    @objc func handleTap() {
           userId.resignFirstResponder() // dismiss keyoard
       }
    //代理连接，关闭
    @objc func connectOrDisconnect(sender: UIButton) {
        if(manager.manager.connection.status == .connected){
            self.proxyEvent()
            self.connectButton.setTitle("连接", for: UIControl.State.normal)
            self.connectButton.backgroundColor = .systemBlue
            return
        }else{
        userId.resignFirstResponder() //点击代理连接，关闭的同时关闭软键盘
        if(userId.text == ""){
            self.view.makeToast("用户id不能为空！",duration: 1.0, position: .top)
            return
        }else{//去服务器请求配置
            connectButton.setTitle("正在连接...", for: UIControl.State.normal)
            let Url = String(format: "https://www.walkonbits.site/ostrich/api/mobile/server/list")
               guard let serviceUrl = URL(string: Url) else { return }
               var request = URLRequest(url: serviceUrl)
            request.httpBody = try! JSONSerialization.data(withJSONObject: ["user_id":userId.text ?? "lessismore", "platform":1], options: [])
               request.httpMethod = "POST"
               request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
               let session = URLSession.shared
               session.dataTask(with: request) { (data, response, error) in
                   if let response = response {
                       print("response---")
                       print(response)
                   }
                   if let data = data {
                       do {
                        print("data---")
                        let json = try JSON(data:data)
                        print(json)
                        if(json["code"] == 200){
                            DispatchQueue.main.async{self.view.makeToast("获取服务器配置成功",duration: 1.0, position: .top)
                                self.connectButton.setTitle("断开", for: UIControl.State.normal)
                                self.connectButton.backgroundColor = .systemRed
                                
                            }
                            self.proxyEvent()
                        }else if(json["code"] == 401){
                            self.connectButton.setTitle("连接", for: UIControl.State.normal)
                            self.connectButton.backgroundColor = .systemBlue
                            DispatchQueue.main.async{self.view.makeToast("用户id有误！",duration: 1.0, position: .top)}
                        }else{
                            self.connectButton.setTitle("连接", for: UIControl.State.normal)
                            self.connectButton.backgroundColor = .systemBlue
                            DispatchQueue.main.async{self.view.makeToast("服务器内部错误！！",duration: 1.0, position: .top)}
                        }
                        
                       } catch {
                        print("error---")
                           print(error)
                        self.connectButton.setTitle("连接", for: UIControl.State.normal)
                        self.connectButton.backgroundColor = .systemBlue
                        DispatchQueue.main.async { self.view.makeToast("获取服务器配置失败！",duration: 1.0, position: .top)}
                       
                       }
                   }
               }.resume()
        }
        
        }
        
    }
    
    func proxyEvent(){
        manager.enableVPNManager() { error in
            guard error == nil else {
                fatalError("enable VPN failed: \(error.debugDescription)")
            }
            self.manager.toggleVPNConnection() { error in
                guard error == nil else {
                    fatalError("toggle VPN connection failed: \(error.debugDescription)")
                }
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NEVPNStatusDidChange, object: self.manager.manager.connection)
    }
}

