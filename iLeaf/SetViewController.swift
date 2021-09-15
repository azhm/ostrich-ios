//
//  SetViewController.swift
//  iLeaf
//
//  Created by admin on 2021/9/8.
//

import UIKit
import Toast_Swift
class SetViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Data model: These strings will be the data for the table view cells
    let items: [String] = ["IP设置", "使用说明", "检查更新"]
    
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "cell"
    
    // don't forget to hook this up from the storyboard
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register the table view cell class and its reuse id
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        // (optional) include this line if you want to remove the extra empty cell divider lines
        // self.tableView.tableFooterView = UIView()

        // This view controller itself will provide the delegate methods and row data for the table view.
        tableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)! as UITableViewCell
        
        // set the text from the data model
        cell.textLabel?.text = self.items[indexPath.row]
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            ipSet()
        case 1:
            self.view.makeToast("使用说明",duration: 1.0, position: .center)
        case 2:
            self.view.makeToast("已经是最新版本",duration: 1.0, position: .center)
        default:
            break
        }
    }
    
    
    func ipSet(){
        let userDefault = UserDefaults.standard
        var serverIp = userDefault.string(forKey: "serverIP")
        if(serverIp == "" || serverIp == nil){
            serverIp = "null"
        }
        var inputText:UITextField = UITextField();
        
        let alertController = UIAlertController(title: "服务器地址设置", message: "当前服务器地址:"+serverIp!, preferredStyle: UIAlertController.Style.alert)
               alertController.addTextField {
                   (textField) -> Void in
                inputText = textField
                inputText.placeholder = "https://"
               }
               let okAction = UIAlertAction(title: "确定", style: UIAlertAction.Style.default) {
                   (action: UIAlertAction!) -> Void in
                   print("确认按钮点击事件")
                print(inputText.text!)
                if(inputText.text == "" || inputText.text == nil){
                    self.view.makeToast("输入的值为空",duration: 1.0, position: .center)
                    return
                }else if(!Validate.URL(inputText.text!).isRight){
                    self.view.makeToast("输入的地址格式不正确！",duration: 1.0, position: .center)
                    return
                }
                
                userDefault.set(inputText.text, forKey: "serverIP")
                self.view.makeToast("设置成功！",duration: 1.0, position: .center)
               }
               let cancelAction = UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel, handler: nil)
               alertController.addAction(okAction)
               alertController.addAction(cancelAction)
               self.present(alertController, animated: true, completion: nil)
    }
    
    
    //对输入的信息进行正则判断
    enum Validate {
        case email(_: String)
        case phoneNum(_: String)
        case carNum(_: String)
        case username(_: String)
        case password(_: String)
        case nickname(_: String)

        case URL(_: String)
        case IP(_: String)


        var isRight: Bool {
            var predicateStr:String!
            var currObject:String!
            switch self {
            case let .email(str):
                predicateStr = "^([a-z0-9_\\.-]+)@([\\da-z\\.-]+)\\.([a-z\\.]{2,6})$"
                currObject = str
            case let .phoneNum(str):
                predicateStr = "^((13[0-9])|(15[^4,\\D]) |(17[0,0-9])|(18[0,0-9]))\\d{8}$"
                currObject = str
            case let .carNum(str):
                predicateStr = "^[A-Za-z]{1}[A-Za-z_0-9]{5}$"
                currObject = str
            case let .username(str):
                predicateStr = "^[A-Za-z0-9]{6,20}+$"
                currObject = str
            case let .password(str):
                predicateStr = "^[a-zA-Z0-9]{6,20}+$"
                currObject = str
            case let .nickname(str):
                predicateStr = "^[\\u4e00-\\u9fa5]{4,8}$"
                currObject = str
            case let .URL(str):
                predicateStr = "((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)"
                currObject = str
            case let .IP(str):
                predicateStr = "^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
                currObject = str
            }

            let predicate =  NSPredicate(format: "SELF MATCHES %@" ,predicateStr)
            return predicate.evaluate(with: currObject)
        }
    }

}
