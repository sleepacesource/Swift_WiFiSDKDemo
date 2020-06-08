//
//  MainViewController.swift
//  Swift_WiFiSDKDemo
//
//  Created by jie yang on 2020/6/3.
//  Copyright © 2020 jie yang. All rights reserved.
//

import UIKit
import SystemConfiguration.CaptiveNetwork
import APWifiConfig

class MainViewController: UIViewController, UITextFieldDelegate {
    var currentDevciceId: String?
    
    var wifiConfig:SLPApWifiConfig?
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var label5: UILabel!
    @IBOutlet weak var label6: UILabel!
    @IBOutlet weak var textfield1: UITextField!
    @IBOutlet weak var textfield2: UITextField!
    @IBOutlet weak var configureBT: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var navigationShell: UIView!
    @IBOutlet weak var containView: UIView!
    @IBOutlet weak var selectBT: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUI()
        
        self.initData()
    }
    
    func initData() {
        self.currentDevciceId = "0"
        self.wifiConfig = SLPApWifiConfig.init()
    }
    
    func setUI() -> Void {
        
        self.label1.text = NSLocalizedString("step1", comment: "");
        self.label2.text = NSLocalizedString("ap_mode", comment: "");
        self.label3.text = NSLocalizedString("step2", comment: "");
        self.label4.text = NSLocalizedString("reminder_connect_hotspot1", comment: "");
        self.label5.text = NSLocalizedString("step3", comment: "");
        self.label6.text = NSLocalizedString("select_wifi", comment: "")
        
        self.configureBT.setTitle(NSLocalizedString("pair_wifi", comment: ""), for: .normal)
        
        self.configureBT.layer.cornerRadius = 25.0;
        self.titleLabel.text = "RestOn Z400TWB";
        
        self.textfield1.placeholder = NSLocalizedString("input_wifi_name", comment: "");
        self.textfield1.delegate = self
        self.textfield2.placeholder = NSLocalizedString("input_wifi_psw", comment: "");
        self.textfield2.delegate = self
        
        var airports = ["YYZ": "Toronto Pearson", "DUB": "Dublin"]
        airports.updateValue("123", forKey: "456")
        
    }
    
    func isConnectedDeviceWiFi() -> Bool {
        
        let wifiName: String? = self.getCurrentWifiName()
        
        let wifiNameSet: Set = ["Sleepace", "RestOn", "Reston"]
        
        var isHotWifi = false
        
        for item in wifiNameSet {
            if ((wifiName?.range(of: item)) != nil) {
                isHotWifi = true
                break
            }
        }
        
        return isHotWifi
    }
    
    func getCurrentWifiName() -> String? {
        var wifiName : String = ""
        let wifiInterfaces = CNCopySupportedInterfaces()
        if wifiInterfaces == nil {
            return nil
        }
        
        let interfaceArr = CFBridgingRetain(wifiInterfaces!) as! Array<String>
        if interfaceArr.count > 0 {
            let interfaceName = interfaceArr[0] as CFString
            let ussafeInterfaceData = CNCopyCurrentNetworkInfo(interfaceName)
            
            if (ussafeInterfaceData != nil) {
                let interfaceData = ussafeInterfaceData as! Dictionary<String, Any>
                wifiName = interfaceData["SSID"]! as! String
            }
        }
        
        return wifiName
    }
    
    
    @IBAction func selectDevice(_ sender: UIButton) {
        let arr = self.getItems()
        let popVc = SLPPopMenuViewController.init(dataSource: arr, from: self.navigationShell)
        self.view.addSubview(popVc.view)
        self.addChild(popVc)
        
        weak var weakSelf = self
        
        weak var weakPopVc = popVc
        
        popVc.didSelectedItemBlock = {(item: SLPPopMenuItem?) in
            weakSelf?.currentDevciceId = item!.itemid;
            weakSelf?.titleLabel.text = item!.itemtitle;
            weakPopVc?.view.removeFromSuperview()
            weakPopVc?.removeFromParent()
        }
        
        popVc.dissBlock = {(item: SLPPopMenuItem?) in
            weakPopVc?.view.removeFromSuperview()
            weakPopVc?.removeFromParent()
        }
    }
    
    func getItems() -> Array<SLPPopMenuItem> {
        var arrayM = [SLPPopMenuItem]()
        let item = SLPPopMenuItem.init()
        item.itemtitle="RestOn Z400TWB";
        item.itemid="0";
        arrayM.append(item)
        let item2 = SLPPopMenuItem.init()
        item2.itemtitle="RestOn Z400TWP";
        item2.itemid="1";
        arrayM.append(item2)
        
        return arrayM
    }
    
    @IBAction func configureAction(_ sender: UIButton) {
        let isCollectWifi = self.isConnectedDeviceWiFi()
        if (!isCollectWifi) {
            let alert = UIAlertController.init(title: nil, message: NSLocalizedString("reminder_connect_hotspot2", comment: ""), preferredStyle: .alert)
            let action = UIAlertAction.init(title: NSLocalizedString("btn_ok", comment: ""), style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let wifiNameText = self.textfield1.text?.trimmingCharacters(in: CharacterSet.whitespaces)
        let count = wifiNameText?.count
        if count == 0 {
            let alert = UIAlertController.init(title: nil, message: NSLocalizedString("input_wifi_name", comment: ""), preferredStyle: .alert)
            let action = UIAlertAction.init(title: NSLocalizedString("btn_ok", comment: ""), style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let deviceType = self.getDeviceType(deviceId: self.currentDevciceId!)
        let address = self.getServerAddress(deviceId: self.currentDevciceId!)
        let port = self.getPort(deviceId: self.currentDevciceId!)
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        self.wifiConfig?.configDevice(deviceType, serverAddress: address, port: port, wifiName: self.textfield1.text, password: self.textfield2.text, completion: { (succeed, data) in
            var result = ""
            MBProgressHUD.hide(for: self.view, animated: true)
            if (succeed) {
                result = NSLocalizedString("reminder_configuration_success", comment: "")
            } else {
                result = NSLocalizedString("reminder_configuration_fail", comment: "")
            }
            
            let alert = UIAlertController.init(title: nil, message: result, preferredStyle: .alert)
            let action = UIAlertAction.init(title: NSLocalizedString("btn_ok", comment: ""), style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        })
    }
    
    func getServerAddress(deviceId: String) -> String {
        var address = ""
        
        switch Int(deviceId) {
        case 0:
            address = "https://webapi.test.sleepace.net"
            break
        case 1:
            address = "120.24.169.204"
            break
        default:
            break
        }
        
        return address
    }
    
    func getPort(deviceId: String) -> Int {
        var port = 0
        
        switch Int(deviceId) {
        case 0:
            port = 0
            break
        case 1:
            port = 9010
            break
        default:
            break
        }
        
        return port
    }
    
    func getDeviceType(deviceId: String) -> SLPDeviceTypes {
        var deviceType = SLPDeviceTypes.none
        
        switch Int(deviceId) {
        case 0:
            deviceType = SLPDeviceTypes.Z5
            break
        case 1:
            deviceType = SLPDeviceTypes.Z6
            break
        default:
            break
        }
        
        return deviceType
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.textfield1.resignFirstResponder()
        self.textfield2.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.5) {
            var rect = self.view.frame
            let y_value=rect.origin.y-150
            rect.origin.y=y_value;
            self.view.frame=rect;
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3) {
            var rect=self.view.frame
            rect.origin.y=0
            self.view.frame=rect
        }
    }
}
