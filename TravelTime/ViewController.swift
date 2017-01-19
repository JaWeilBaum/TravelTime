//
//  ViewController.swift
//  TravelTime
//
//  Created by Léon Friedmann on 05.01.17.
//  Copyright © 2017 Léon Friedmann. All rights reserved.
//

import UIKit
import SwiftHTTP

class ViewController: UIViewController {

    
    @IBOutlet weak var outputLabel: UILabel!
    @IBOutlet weak var withTrafficLabel: UILabel!
    @IBOutlet weak var differenceLabel: UILabel!
    
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBAction func refresh(_ sender: UIButton) {
        displayData()
    }
    var timeWithTraffic = -1
    var timeWithoutTraffic = -1
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func loadTravelTime() {
        
        var data : String = ""
        print("Loading")
        do {
            //the url sent will be https://google.com?hello=world&param2=value2
            let opt = try HTTP.GET("https://maps.googleapis.com/maps/api/directions/json?", parameters: ["key" : "AIzaSyCTU25VYbmcvu4geQ7jN5FONhlqfV8Lprc", "origin" : "80801 München Wilhelmsstrasse 43", "destination" : "Reinhold-Würth-Straße 12, 74653 Künzelsau" , "units" : "metric" , "departure_time" : "now"])
            opt.start { response in
                if let err = response.error {
                    print("error: \(err.localizedDescription)")
                    return //also notify app of failure as needed
                }
                data = response.text!
                if response.statusCode == 200 {
                
                let duartionIndex = data.index(of: "duration")
                data = data.substring(from: duartionIndex!)
                
                let endIndex = data.index(of: "end_address")
                data = data.substring(to: endIndex!)
                
                let valueIndex = data.index(of: "\"value\" : ");
                var duration = data.substring(from: valueIndex!)
                
                let endValueIndex = duration.index(of: "}")
                duration = duration.substring(to: endValueIndex!)
                
                var time = ""
                var counter = 0
                for c in duration.characters {
                    if counter >= 10 {
                        time.append(c)
                    }
                    counter += 1
                }
                self.timeWithoutTraffic = Int(time.trimmingCharacters(in: .whitespacesAndNewlines))!
                //print("Ohne Verkehr: \(timeWithoutTraffic!)")
                
                let durationWithTrafficIndex = data.index(of: "duration_in_traffic")
                data = data.substring(from: durationWithTrafficIndex!)
                
                let valueTIndex = data.index(of: "\"value\" : ");
                var durationT = data.substring(from: valueTIndex!)
                
                let endValueTIndex = durationT.index(of: "}")
                durationT = durationT.substring(to: endValueTIndex!)
                
                var timeT = ""
                var counterT = 0
                for c in durationT.characters {
                    if counterT >= 10 {
                        timeT.append(c)
                    }
                    counterT += 1
                }
                self.timeWithTraffic = Int(timeT.trimmingCharacters(in: .whitespacesAndNewlines))!
                }
                //data = (timeWithoutTraffic, timeWithTraffic)
            }
        } catch let error {
            print("got an error creating the request: \(error)")
        }
        print("Loading done \nResult = \(data)")
        
        
        
    }
    
    func displayData() {
        
        loading.startAnimating()
        
        timeWithoutTraffic = -1
        timeWithTraffic = -1
        loadTravelTime()
        while timeWithTraffic == -1 || -1 == timeWithoutTraffic {
            
        }
        
        outputLabel.text = "Ohne Verkehr:\t\t\t\(timeWithoutTraffic / (60 * 60)) Std \((timeWithoutTraffic / 60) % (60 * (timeWithoutTraffic / (60 * 60)))) Min"
        withTrafficLabel.text = "Mit Verkehr:\t\t\t\(timeWithTraffic / (60 * 60)) Std \((timeWithTraffic / 60) % (60 * (timeWithTraffic / (60 * 60)))) Min"
        differenceLabel.text = "Zeit Unterschied:\t\t\((timeWithTraffic - timeWithoutTraffic) / (60)) Min"
        
        loading.stopAnimating()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        displayData()
    }

    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

