//
//  GraphViewController.swift
//  ScanForDevice
//
//  Created by daire mc daid on 13/04/2018.
//  Copyright © 2018 daire mc daid. All rights reserved.
//

import UIKit
import Charts

class GraphViewController: UIViewController {
    
    //properties
    
    @IBOutlet weak var lineChartView: LineChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //VERTICAL
        let heartRate = BPMArray
        
        //HORIZONTAL
        let lengthOfChart = [BPMArray.count]
        
        setChart(dataPoints: lengthOfChart, values: heartRate)
        
        //print(BPMArray)
        
        // if no data available
        lineChartView.noDataText = "No data available."
        
    }

    func setChart(dataPoints: [Int], values: [Int]){
        
        var dataEntries: [ChartDataEntry] = []
        
        //add values to chart data array
        for i in 0..<values.count {
            let dataEntry  = ChartDataEntry(x: Double(i), y: Double(values[i]))
            dataEntries.append(dataEntry)
        }
        
        let lineChartDataSet = LineChartDataSet(values: dataEntries, label: "Heart Rate")
        let lineChart  = LineChartData(dataSet: lineChartDataSet)
        
        lineChartView.data = lineChart
        
        // circles from data points
        lineChartDataSet.drawCirclesEnabled = true
        lineChartDataSet.circleRadius = 5
        
        // set max and min values of y axis
        lineChartView.leftAxis.axisMinimum = 0
        lineChartView.leftAxis.axisMaximum = 100
        
        lineChartView.rightAxis.axisMinimum = 0
        lineChartView.rightAxis.axisMaximum = 100
        
        // remove description text
        lineChartView.chartDescription?.text = " "
        
        lineChartView.xAxis.labelPosition = .bottom
        
        // change line colour
        lineChartDataSet.colors = ChartColorTemplates.pastel()
        
        //change background colour
        lineChartView.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
        
        //add animation
        lineChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
        
        
        // limit lines
        let avg = ChartLimitLine(limit: 85, label: "Average Adult")
        lineChartView.rightAxis.addLimitLine(avg)
        
        let good = ChartLimitLine(limit: 60, label: "Healthy Adult")
        lineChartView.rightAxis.addLimitLine(good)
        
        let slow = ChartLimitLine(limit: 50, label: "Trained Athlete")
        lineChartView.rightAxis.addLimitLine(slow)
        
        //let fast = ChartLimitLine(limit: 75, label: "Children < 10")
        //lineChartView.rightAxis.addLimitLine(fast)
    }
    
    // save graph to your camera roll
    
    @IBAction func saveGraph(_ sender: UIBarButtonItem) {
        
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
        
        let saved = UIAlertController(title: "Saved!", message: "Your graph has been saved in your camera roll!", preferredStyle: UIAlertControllerStyle.alert)
        
        let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
        
        saved.addAction(ok)
        
        self.present(saved, animated: true, completion: nil)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
