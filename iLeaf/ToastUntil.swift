//
//  ToastUntil.swift
//  iLeaf
//
//  Created by admin on 2021/9/7.
//

import Foundation
import UIKit


class Toast
{
    class private func showAlert(backgroundColor:UIColor, textColor:UIColor, message:String)
    {
        
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let label = UILabel(frame: CGRect.zero)
        label.textAlignment = NSTextAlignment.center
        label.text = message
        label.font = UIFont(name: "", size: 15)
        label.adjustsFontSizeToFitWidth = true
        
        label.backgroundColor =  backgroundColor //UIColor.whiteColor()
        label.textColor = textColor //TEXT COLOR
        
        label.sizeToFit()
        label.numberOfLines = 4
        label.layer.shadowColor = UIColor.gray.cgColor
        label.layer.shadowOffset = CGSize(width: 4, height: 3)
        label.layer.shadowOpacity = 0.3
        label.frame = CGRect(x: appDelegate.window!.frame.size.width, y: 64, width: appDelegate.window!.frame.size.width, height: 44)
        
        label.alpha = 1
        
        appDelegate.window!.addSubview(label)
        
        var basketTopFrame: CGRect = label.frame;
        basketTopFrame.origin.x = 0;
        
        UIView.animate(withDuration
                        :2.0, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: UIView.AnimationOptions.curveEaseOut, animations: { () -> Void in
                label.frame = basketTopFrame
        },  completion: {
            (value: Bool) in
            UIView.animate(withDuration:2.0, delay: 2.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: UIView.AnimationOptions.curveEaseIn, animations: { () -> Void in
                label.alpha = 0
            },  completion: {
                (value: Bool) in
                label.removeFromSuperview()
            })
        })
    }
    
    static func showPositiveMessage(message:String)
    {
        showAlert(backgroundColor: UIColor.green, textColor: UIColor.white, message: message)
    }
    static func showNegativeMessage(message:String)
    {
        showAlert(backgroundColor: UIColor.red, textColor: UIColor.white, message: message)
    }
    
}
