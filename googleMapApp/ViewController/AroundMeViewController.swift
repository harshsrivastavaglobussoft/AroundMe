//
//  AroundMeViewController.swift
//  googleMapApp
//
//  Created by Sumit Ghosh on 11/06/18.
//  Copyright © 2018 Sumit Ghosh. All rights reserved.
//

import UIKit
protocol AroundMeViewControllerDelegate: class {
    func typesController(_ controller: AroundMeViewController, didSelectTypes types: [String])
}
class AroundMeViewController: UIViewController {

    @IBOutlet weak var aroundMeTableView: UITableView!

    weak var delegate: AroundMeViewControllerDelegate?
    private let possibleTypesDictionary = ["bakery": "Bakery", "bar": "Bar", "cafe": "Cafe", "grocery_or_supermarket": "Supermarket", "restaurant": "Restaurant"]
    private var sortedKeys: [String] = ["bakery","bar","cafe","grocery_or_supermarket","restaurant"]
    
    var selectedTypes:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.aroundMeTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.aroundMeTableView.delegate = self
        self.aroundMeTableView.dataSource = self
        // Do any additional setup after loading the view.
    }

    @IBAction func backButonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func DoneButtonAction(_ sender: Any) {
        delegate?.typesController(self, didSelectTypes: selectedTypes)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
//MARK: TableViewDelegates
extension AroundMeViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.possibleTypesDictionary.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var Cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        if Cell == nil {
            Cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "")
        }
        Cell?.selectionStyle = UITableViewCellSelectionStyle.none
        
        let key = sortedKeys[indexPath.row]
        let type = possibleTypesDictionary[key]
        
        Cell?.imageView?.image = UIImage.init(named: key)
        Cell?.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        Cell?.textLabel?.text = type
        
        if selectedTypes.contains(key){
            Cell?.accessoryType = .checkmark
        }else{
            Cell?.accessoryType = .none
        }
        
        return Cell!
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let key = sortedKeys[indexPath.row]
        if selectedTypes.contains(key) {
            selectedTypes = selectedTypes.filter({$0 != key})
        }else{
            selectedTypes.append(key)
        }
        tableView.reloadData()
    }
}
