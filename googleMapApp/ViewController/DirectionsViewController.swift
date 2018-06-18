//
//  DirectionsViewController.swift
//  googleMapApp
//
//  Created by Sumit Ghosh on 18/06/18.
//  Copyright © 2018 Sumit Ghosh. All rights reserved.
//

import UIKit

class DirectionsViewController: UIViewController {

    @IBOutlet weak var directionsTableView: UITableView!
    var tableData = [stepsData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.directionsTableView.delegate = self
        self.directionsTableView.dataSource = self
        // Do any additional setup after loading the view.
    }

    @IBAction func backButtonaction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
extension DirectionsViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableData.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var Cell = tableView.dequeueReusableCell(withIdentifier: "DirectionCell")
        
        Cell?.textLabel?.font = UIFont.systemFont(ofSize: 12)
        Cell?.textLabel?.numberOfLines = 0
        Cell?.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        let DetailsString = self.tableData[indexPath.row].html_instructions?.htmlToString
        let time = self.tableData[indexPath.row].duration?.text ?? ""
        let distance = self.tableData[indexPath.row].distance?.text ?? ""
        Cell?.textLabel?.text = "\(DetailsString!) Distance: \(distance) Time: \(time)"
        return Cell!
    }
}

