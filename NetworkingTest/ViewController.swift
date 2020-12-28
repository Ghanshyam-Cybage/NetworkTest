//
//  ViewController.swift
//  NetworkingTest
//
//  Created by Ghanshyam Maliwal on 25/09/20.
//  Copyright © 2020 Ghanshyam Maliwal. All rights reserved.
//

import UIKit

class ViewController: UIViewController , UITableViewDataSource, UITableViewDelegate {
    
    // MARK: IBOutlet's
    @IBOutlet var tableView : UITableView!
    
    // MARK: - Instance Properties
    
    let countryNames = ["India","China","USA"]
    var dataModels = [CovidDataModel?]()
    
    let networkManager = NetworkManager()
    var urls = [URL(string: "https://api.covid19api.com/live/country/china/status/confirmed/date/2020-03-21T13:13:30Z"),URL(string: "https://api.covid19api.com/live/country/india/status/confirmed/date/2020-03-21T13:13:30Z"), URL(string: "https://api.covid19api.com/live/country/usa/status/confirmed/date/2020-03-21T13:13:30Z")]
    
    // MARK: - UIViewController Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 20
    }
    
    // MARK: - IBAction Methods
    
    @IBAction func loadStatistics() {
        
        for countryIndex in 0..<urls.count {
            if let _url = urls[countryIndex] {
                
                networkManager.fetchCovidData(forCountry: countryIndex, endPointURL: _url, successHandler: { [weak self] (countryIndex, dataModel) in
                    
                    var dataModel = dataModel
                    dataModel?.countryIndex = countryIndex
                    self?.dataModels.append(dataModel)
                    DispatchQueue.main.async {
                        self?.tableView.reloadRows(at: [IndexPath(row: countryIndex, section: 0)], with: .automatic)
                    }
                    
                }) {}
            }
        }
    }
}

// MARK: - UITableViewDatasource and UITableViewDelegate
extension ViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return urls.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "com.company.company")
        cell.textLabel?.text = countryNames[indexPath.row]
        
        let dataModel = dataModels.filter { (dataModel) -> Bool in
            return dataModel?.countryIndex == indexPath.row
        }.first
        
        if let covidData = dataModel {
            if let confirmedCount = covidData?.confirmedCount, let deatchCount = covidData?.deathCount, let recoveredCount = covidData?.recoveredCount {
                let description = "Confirmed : \(confirmedCount), Deaths: \(deatchCount), Recovered: \(recoveredCount)"
                print("descriptin is --- \(description)")
                cell.detailTextLabel?.text = description
            }
        }
        return cell
    }
}

