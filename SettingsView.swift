//
//  SettingsView.swift
//  WAQU
//
//  Created by Ting-Kai Huang on 9/18/21.
//

import SwiftUICharts
import SwiftUI
import CoreBluetooth

struct SettingsView: View{
    @Environment(\.presentationMode) var presentation
    @ObservedObject var bleManager = BLEManager()
    
    var body: some View{
        //let firstPoint = self.bleManager.pm25Points[0]
        NavigationView {
            ScrollView {
                VStack {
                    Button(action: {
                        print(self.bleManager.pm25Points[0])
                    }) {
                        Text("Test")
                    }
                    // Legend
                    let pm25 = Legend(color: .blue, label: "PM2.5")
                    // DataPoint
                    
                    let points: [DataPoint] = [
                        .init(value: 1, label: "1", legend: pm25),
                        /*
                        .init(value: self.bleManager.pm25Points[1], label: "\(self.bleManager.pm25Points[1])", legend: pm25),
                        .init(value: self.bleManager.pm25Points[2], label: "\(self.bleManager.pm25Points[2])", legend: pm25),
                        .init(value: self.bleManager.pm25Points[3], label: "\(self.bleManager.pm25Points[3])", legend: pm25),
                        .init(value: self.bleManager.pm25Points[4], label: "\(self.bleManager.pm25Points[4])", legend: pm25),
                         */
                    ]
                    /*
                    // Bar
                    Section(header: Text("Bar Chart")) {
                        BarChartView(dataPoints: points)
                            .frame(height: UIScreen.main.bounds.size.height/3)
                            .background(Color(.secondarySystemBackground))
                            .padding()
                    }
                    
                    Section(header: Text("Horizontal Bar Chart")) {
                        HorizontalBarChartView(dataPoints: points)
                            .frame(height: UIScreen.main.bounds.size.height/3)
                            .background(Color(.secondarySystemBackground))
                            .padding()
                    }
                     */
                    // Line
                    Section(header: Text("PM2.5")) {
                        LineChartView(dataPoints: points)
                            .frame(height: UIScreen.main.bounds.size.height/3)
                            .background(Color(.secondarySystemBackground))
                            .padding()
                    }
                }
            }
            .navigationTitle("Charts & Graphs")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .previewDevice("iPhone 11")
            .previewDisplayName("iPhone 11")
    }
}
