//
//  ViewController.swift
//  Test_app
//
//  Created by Dhaval Bhadania on 31/01/18.
//  Copyright © 2018 Dhaval Bhadania. All rights reserved.
//

import UIKit
import CoreData
import SystemConfiguration

enum JSONError: String, Error {
    case NoData = "ERROR: no data"
    case ConversionFailed = "ERROR: conversion from JSON failed"
}


class ViewController: UIViewController {
    var expandedIndexPath = IndexPath()

    var resultArray = [[String: Any]]()
    var coreDataStack = CoreDataStack()
    @IBOutlet weak var tblview: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
//        expandedIndexPath = IndexPath(row: 1, section: 1)

        self.tblview.tableFooterView = UIView()
        // Do any additional setup after loading the view, typically from a nib.
        if self.coreDataStack.getList().count > 0 || !self.isInternetAvailable()
        {
            self.showProgressHud(msg: "Please Wait...")

            resultArray = coreDataStack.getList();
            print(self.resultArray)
            self.tblview.reloadData()
            self.hideProgressHud()
        }
        else{
            self.jsonParser()
        }
        
    }
 
    
    func jsonParser() {
        self.showProgressHud(msg: "Please Wait...")
        let urlPath = "http://rhostore.herokuapp.com/products.json"
        guard let endpoint = URL(string: urlPath) else {
            print("Error creating endpoint")
            return
        }
        URLSession.shared.dataTask(with: endpoint) { (data, response, error) in
            do {
                guard let data = data else {
                    throw JSONError.NoData
                }
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSArray else {
                    throw JSONError.ConversionFailed
                }
                for i in 1...json.count{
                    
                    let obj = ((json[i-1] as! [String : Any])["product"] as! [String : Any] )
                    
                    //self.resultArray.append(obj)
                    if #available(iOS 10.0, *)
                    {
                        let chatdata = Product(context: self.coreDataStack.persistentContainer.viewContext)
                        chatdata.brand = obj["brand"] as? String
                        chatdata.created_at = obj["created_at"] as? String
                        chatdata.productid =  String(describing: obj["id"]!)
                        chatdata.quantity = obj["quantity"] as? String
                        chatdata.price =  obj["price"] as? String
                        chatdata.name = obj["name"] as? String
                        chatdata.sku = obj["sku"] as? String
                        chatdata.updated_at = obj["updated_at"] as? String
                        
                        self.coreDataStack.saveContext()
                    }
                    else
                    {
                        let entity = NSEntityDescription.entity(forEntityName: "Product", in: self.coreDataStack.managedObjectContext)
                        let chatdata  = NSManagedObject(entity: entity!, insertInto: self.coreDataStack.managedObjectContext) as! Product
                        
                        chatdata.brand = obj["brand"] as? String
                        chatdata.created_at = obj["created_at"] as? String
                        chatdata.productid =  "\(obj["id"]!)"
                        chatdata.quantity = obj["quantity"] as? String
                        chatdata.price =  obj["price"] as? String
                        chatdata.name = obj["name"] as? String
                        chatdata.sku = obj["sku"] as? String
                        chatdata.updated_at = obj["updated_at"] as? String
                        self.coreDataStack.saveContext()
                    }
                    
                }
               
                OperationQueue.main.addOperation ({
                    self.resultArray = self.coreDataStack.getList();

                    self.tblview.reloadData()
                    self.hideProgressHud()
                })
            } catch let error as JSONError {
                print(error.rawValue)
            } catch let error as NSError {
                print(error.debugDescription)
            }
            }.resume()
    }
    
    func SaveTODB()
    {
        
    
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCell
        
        let currentRec = resultArray[indexPath.row]
        cell.lblname.text = currentRec["name"] as? String
        cell.lblbrand.text = currentRec["brand"] as? String
        cell.lblid.text = "\(String(describing: String(describing: currentRec["productid"]!)))"
        cell.lblsku.text = currentRec["sku"] as? String
        cell.lblprice.text = currentRec["price"] as? String
        cell.lblquantity.text = currentRec["quantity"] as? String
//        cell.selectionStyle = .none
//        cell.backgroundColor = UIColor.clear
        return cell
    }
   
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.compare(expandedIndexPath) == .orderedSame {
            return 230
        }
        return 80
    }
}
extension ViewController : UITableViewDelegate
{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.beginUpdates()
        
        if indexPath.compare(expandedIndexPath) == .orderedSame {
            expandedIndexPath = IndexPath()
        } else {
            expandedIndexPath = indexPath
        }
        
        tableView.endUpdates()
    }
}



class CustomCell: UITableViewCell {
    
    @IBOutlet weak var lblname : UILabel!
    @IBOutlet weak var lblbrand : UILabel!
    @IBOutlet weak var lblid : UILabel!
    @IBOutlet weak var lblprice : UILabel!
    @IBOutlet weak var lblquantity : UILabel!
    @IBOutlet weak var lblsku : UILabel!
}
extension UIViewController: NVActivityIndicatorViewable {
    //Hud Indicator Method
    func showProgressHud(msg: String)
    {
        let size = CGSize(width: 50, height:50)
        startAnimating(size, message: msg, type: NVActivityIndicatorType(rawValue: 0)!, color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
    }
    
    func hideProgressHud()
    {
        stopAnimating()
    }
    
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
}
