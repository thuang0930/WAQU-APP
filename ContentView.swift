//
//  ContentView.swift
//  WAQU
//
//  Created by Ting-Kai Huang on 3/21/21.
//

import SwiftUICharts
import SwiftUI
import UserNotifications
import CoreBluetooth

struct ContentView: View {
    //properties
    @ObservedObject var bleManager = BLEManager()
    @State private var openTimeSetting: Bool = false
    @State private var showSheet: Bool = false
    @State private var currentState: Bool = false
    //@State private var setTime: String = ""
    @State private var notificationMessage = "Status: Daily Notification Off"
    @State private var hour: String = "00"
    @State private var minute: String = "00"
    @State private var isButtonEnabled: Bool = false
    @State private var pm25Alert = false
    @State private var co2Alert = false
    @State private var tempAlert = false
    @State private var humidityAlert = false
    @State private var qualityAlert = false
    @State private var summaryAlert = false
    let skyBlue = Color(red: 0.25, green: 0.6, blue: 1.0)
    
    var pm25Message = """
        PM stands for particulate matter, which is the term for a mixture of solid particles and liquid droplets found in the air. In particular, PM2.5 particles, also known as fine inhalable particles with diameters that are around 2.5 micrometers and smaller, are generally emitted from construction sites, unpaved roads, smokestacks or fires. These particles pose serious risk to health, thus, it is vital to monitor the level of PM2.5 regularly.
        PM2.5 Air Quality Index:
        0-50    Good
        51-100  Moderate
        101-150 Unhealthy for Sensitive Groups
        151-200 Extremely Unhealthy
    """
    var resultMessage = """
    The air quality is typically directly defined by the CO2 and PM2.5 levels (for more details, please refer to their definitions by clicking them above), whereas the temperature and the relative humidity can give you an idea of the surrounding environment in terms of how you feel physically.
    """
    var tempMessage = """
    The measure of hotness or coldness expressed in terms of any of several arbitrary scales and indicating the direction in which heat energy will spontaneously flow—i.e., from a hotter body (one at a higher temperature) to a colder body (one at a lower temperature).
    """
    var co2Message = """
    The measure of the amount of carbon dioxide (CO2) in the atmosphere. This is measured in units of parts per million (ppm), which tells the average number of CO2 molecules out of one million air molecules.
    250-400 ppm: Normal outdoor air level.
    400-1,000 ppm: Typical level found in occupied spaces with good air exchange.
    1,000-2,000 ppm: Level associated with complaints of drowsiness and poor air.
    2,000-5,000 ppm: Level associated with headaches, sleepiness, and stagnant, stale, stuffy air. Poor concentration, loss of attention, increased heart rate and slight nausea may also be present.
    > 5,000 ppm: Toxicity or oxygen deprivation could occur. This is the permissible exposure limit for daily workplace exposures.
    > 40,000 ppm: This level is immediately harmful due to oxygen deprivation.
    """
    var humidityMessage = """
    Relative humidity is the amount of water vapor (vapor pressure) that is in the air. It is a percentage of how much moisture the air could possibly hold. The amount of vapor that can be contained in the air increases with temperature. The higher the percentage of relative humidity, the more humid (moist) the air feels, while a lower percentage usually feels drier.
    Typically people find a relative humidity of 30% - 60% most comfortable. Anything higher than 60% is considered high humidity level, and it provides an environment for two common asthma and allergy triggers: dust mites and mould. Anything lower than 30% is considered low humidity level, and it increases the chance of catching airborne viruses like a cold or the flu. Also, very dry air can make eczema worse and dry skin can be uncomfortable.
    """
    var body: some View {
        //view code
        NavigationView {
            ZStack{
                skyBlue.opacity(0.95)
                    .ignoresSafeArea()
                ScrollView {
                //Demo Button
                /*VStack{
                    Spacer()
                    Button(action: {
                        //generate random reading numbers
                        let tempRan = Int.random(in: 0...120)
                        let co2Ran = Int.random(in: 250...5000)
                        let humidityRan = Int.random(in: 0...100)
                        let pm25Ran = Int.random(in: 0...200)
                        //assign random values to properties
                        self.bleManager.tempInt = tempRan
                        co2= co2Ran
                        self.bleManager.humidityInt = humidityRan
                        self.bleManager.pm25Int = pm25Ran
                        tempC = (temp-32)*5/9
                        
                        self.tempPostNotification()
                    }, label: {
                        Text("Demo")
                    }).disabled(!isButtonEnabled)
                }*/
                
                //Bluetooth Button
                /*
                VStack{
                    Spacer()
                    Button("Bluetooth Connection"){
                        self.showSheet = true
                    }.font(.title)
                }.padding()
                .sheet(isPresented: $showSheet){
                    SettingsView()
                }
                 */
            
                    VStack{
                        Text("WAQU")
                            .font(.custom("Baskerville-BoldItalic", size:80))
                            //.offset(y:-30)
                        HStack{
                            Button(action: {
                                self.openTimeSetting = true
                                currentState = false
                                //notificationMessage = "Status: Daily Notification Off"
                            }, label: {
                                Label("",systemImage: "alarm.fill")
                                    .foregroundColor(Color.black)
                                    .font(.custom("Devanagari Sangam MN", size:25))
                                    .padding(.horizontal,20)
                                    .padding(.vertical,10)
                            })
                                .sheet(isPresented:$openTimeSetting){
                                    TimeSettingView(hour:self.$hour, minute:self.$minute)
                                }
                            
                            Button(action: {
                                summaryAlert = true
                            }, label: {
                                Label("",systemImage: "doc.text.fill")
                                    .foregroundColor(Color.black)
                                    .font(.custom("Devanagari Sangam MN", size:25))
                                    .padding(.horizontal,20)
                                    .padding(.vertical,10)
                            })
                            .alert(isPresented: $summaryAlert, content: {
                                Alert(title: Text("Weather Report"), message: Text(summaryMessage()), dismissButton: .default(Text("Close")))
                                })
                        }
                        Spacer()
                        
                        if Int(hour)! < 12 {
                            Text("Daily Notification time: \(hour) : \(minute) AM")
                                .foregroundColor(Color.black)
                        }
                        else if Int(hour)! >= 12 {
                            Text("Daily Notification time: \(Int(hour)!-12) : \(minute) PM")
                                .foregroundColor(Color.black)
                        }
                        
                        HStack{
                            Toggle("Turn on daily notification",isOn:$currentState)
                                .foregroundColor(Color.white)
                                .padding(.horizontal,90)
                                .onChange(of: currentState){ value in
                                    bleManager.hour = hour
                                    bleManager.minute = minute
                                }
                        }
                        
                        /*
                        Button(action:{
                            print(bleManager.hour + " " + bleManager.minute)
                        }) {
                            Text("Print hour and minute")
                                .foregroundColor(Color.white)
                        }
                        */ //test hour and min button
                        /*
                        Button(action: {
                            notificationMessage = "Status: Daily Notification On"
                            bleManager.hour = hour
                            bleManager.minute = minute
                        }) {
                            Text("Turn on daily notification")
                                .foregroundColor(Color.white)
                                .font(.custom("Devanagari Sangam MN", size:20))
                                .padding(.horizontal,20)
                                .padding(.vertical,10)
                        }
                        .background(Capsule().fill(Color.green))
                        Spacer()
                        
                        if notificationMessage == "Status: Daily Notification On" {
                            Text(notificationMessage)
                                .foregroundColor(Color.green)
                                .font(.custom("Devanagari Sangam MN", size:15))
                        }
                        else {
                            Text(notificationMessage)
                                .foregroundColor(Color.red)
                                .font(.custom("Devanagari Sangam MN", size:15))
                        }
                        */ //turn on daily notification button
                        
                        HStack{
                                Button(action: {
                                    self.bleManager.startScanning()
                                }) {
                                    Text("Start Scanning")
                                        .foregroundColor(Color.black)
                                        .padding(.horizontal,20)
                                        .padding(.vertical,10)
                                }
                                .background(Capsule().fill(Color.green.opacity(0.8)))
                            
                            VStack{
                                Button(action: {
                                    self.bleManager.stopScanning()
                                }) {
                                    Text("Stop Scanning")
                                        .foregroundColor(Color.black)
                                        .padding(.horizontal,20)
                                        .padding(.vertical,10)
                                }
                                .background(Capsule().fill(Color.red.opacity(0.8)))
                            }
                        }.padding()
                        /*
                        Button(action: {
                            summaryAlert = true
                        }, label: {
                            Text("See Weather Report")
                                .foregroundColor(Color.black)
                                .padding(.horizontal,20)
                                .padding(.vertical,10)
                        })
                            .background(Capsule().fill(Color(white:0.7).opacity(0.8)).saturation(10))
                        .alert(isPresented: $summaryAlert, content: {
                            Alert(title: Text("Weather Report"), message: Text(summaryMessage()), dismissButton: .default(Text("Close")))
                            })
                        */ //see weather report button
                        
                        HStack{
                            GroupBox(
                                label:
                                    HStack{
                                    Label("Temperature", systemImage: "thermometer")
                                    .foregroundColor(Color.black)
                                    Spacer()
                                    Button(action: {
                                        tempAlert = true
                                    }, label: {
                                        Label("",systemImage: "questionmark.circle.fill").foregroundColor(Color.black)
                                    })
                                            .alert(isPresented: $tempAlert, content: {
                                                Alert(title: Text("What does this tell you?"), message: Text("\(tempMessage)"), dismissButton: .default(Text("Close")))
                                                })
                                    }
                                ,content: {
                                    Text("\(self.bleManager.tempRound)°F/\(self.bleManager.tempCRound)°C")
                                        .font(.custom("Devanagari Sangam MN", size:25))
                                        .offset(y:15)
                                }
                            ).groupBoxStyle(TransparentGroupBox())
                                .padding()
                                .offset(x:15)
                            GroupBox(
                                label:
                                    HStack{
                                    Label("CO2", systemImage: "smoke")
                                    .foregroundColor(Color.black)
                                    Spacer()
                                    Button(action: {
                                        co2Alert = true
                                    }, label: {
                                        Label("",systemImage: "questionmark.circle.fill").foregroundColor(Color.black)
                                    })
                                            .alert(isPresented: $co2Alert, content: {
                                                Alert(title: Text("What does this tell you?"), message: Text("\(co2Message)"), dismissButton: .default(Text("Close")))
                                                })
                                    }
                                ,content: {
                                    Text("\(self.bleManager.co2Round) ppm")
                                        .font(.custom("Devanagari Sangam MN", size:25))
                                        .offset(y:15)
                                }
                            ).groupBoxStyle(TransparentGroupBox())
                                .padding()
                                .offset(x:-15)
                        }
                        HStack{
                            GroupBox(
                                label:
                                    HStack{
                                    Label("Humidity", systemImage: "humidity")
                                    .foregroundColor(Color.black)
                                    Spacer()
                                    Button(action: {
                                        humidityAlert = true
                                    }, label: {
                                        Label("",systemImage: "questionmark.circle.fill").foregroundColor(Color.black)
                                    })
                                            .alert(isPresented: $humidityAlert, content: {
                                                Alert(title: Text("What does this tell you?"), message: Text("\(humidityMessage)"), dismissButton: .default(Text("Close")))
                                                })
                                    }
                                ,content: {
                                    Text("\(self.bleManager.humidityRound)%")
                                        .font(.custom("Devanagari Sangam MN", size:25))
                                        .offset(y:15)
                                }
                            ).groupBoxStyle(TransparentGroupBox())
                                .padding()
                                .offset(x:15)
                            
                            GroupBox(
                                label:
                                    HStack{
                                    Label("PM2.5", systemImage: "aqi.low")
                                    .foregroundColor(Color.black)
                                    Spacer()
                                    Button(action: {
                                        pm25Alert = true
                                    }, label: {
                                        Label("",systemImage: "questionmark.circle.fill").foregroundColor(Color.black)
                                    })
                                            .alert(isPresented: $pm25Alert, content: {
                                                Alert(title: Text("What does this tell you?"), message: Text("\(pm25Message)"), dismissButton: .default(Text("Close")))
                                                })
                                    }
                                ,content: {
                                    Text("\(self.bleManager.pm25Round)")
                                        .font(.custom("Devanagari Sangam MN", size:25))
                                        .offset(y:15)
                                }
                            ).groupBoxStyle(TransparentGroupBox())
                                .padding()
                                .offset(x:-15)
                        }.offset(y:-20)
                        
                        VStack{
                            Button(action: {
                                qualityAlert = true
                            }, label: {
                                Text("Air Quality:")
                                    .font(.custom("Devanagari Sangam MN", size:28))
                                .foregroundColor(Color.black)
                                Image(systemName: "questionmark.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width:30,height:30)
                                    .foregroundColor(Color.black)
                            })
                                .alert(isPresented: $qualityAlert, content: {
                                    Alert(title: Text("What does this tell you?"), message: Text("\(resultMessage)"), dismissButton: .default(Text("Close")))
                                })
                            Spacer()
                            
                            if airQuality() == "Good" || airQuality() == "Moderate" {
                                Text(airQuality())
                                    .foregroundColor(Color.green)
                                    .font(.custom("Devanagari Sangam MN", size:50))
                                        //.foregroundColor(Color.black)
                            }
                            else if airQuality() == "Bad" || airQuality() == "Poor" {
                                Text(airQuality())
                                    .foregroundColor(Color.orange)
                                    .font(.custom("Devanagari Sangam MN", size:50))
                            }
                            else if airQuality() == "Caution" {
                                Text(airQuality())
                                    .foregroundColor(Color.red)
                                    .font(.custom("Devanagari Sangam MN", size:50))
                            }
                        }.offset(y:-15)
                    }.offset(y:-40)
                    //App View
                    //Original Sensor Display
                    /*
                    HStack(spacing:40){
                        VStack(alignment: .leading, spacing: 30){
                            Button(action: {     //Temperature  button
                                tempAlert = true
                            }, label: {
                                Text("Temperature")
                                    .font(.custom("Devanagari Sangam MN", size:25))
                                    .foregroundColor(Color.black)
                                Image(systemName: "questionmark.circle")
                                    .foregroundColor(Color.black)
                            })
                            .alert(isPresented: $tempAlert, content: {
                                Alert(title: Text("What does the temperature tell you?"), message: Text("\(tempMessage)"), dismissButton: .default(Text("Close")))
                            })
                            Text("\(self.bleManager.tempRound)°F/\(self.bleManager.tempCRound)°C")
                                .font(.custom("Devanagari Sangam MN", size:30))
                                //.foregroundColor(Color.black)
                            
                            Button(action: {    //Humidity button
                                humidityAlert = true
                            }, label: {
                                Text("Humidity")
                                    .font(.custom("Devanagari Sangam MN", size:25))
                                    .foregroundColor(Color.black)
                                Image(systemName: "questionmark.circle")
                                    .foregroundColor(Color.black)
                            })
                            .alert(isPresented: $humidityAlert, content: {
                                Alert(title: Text("What is relative humidity?"), message: Text("\(humidityMessage)"), dismissButton: .default(Text("Close")))
                            })
                            Text("\(self.bleManager.humidityRound)%")
                                .font(.custom("Devanagari Sangam MN", size:30))
                                //.foregroundColor(Color.black)
                        }
                        VStack(alignment: .leading, spacing: 30){
                            Button(action: {    //CO2 button
                                co2Alert = true
                            }, label: {
                                Text("CO2")
                                    .font(.custom("Devanagari Sangam MN", size:25))
                                    .foregroundColor(Color.black)
                                Image(systemName: "questionmark.circle")
                                    .foregroundColor(Color.black)
                            })
                            .alert(isPresented: $co2Alert, content: {
                                Alert(title: Text("What does the CO2 reading tell you?"), message: Text("\(co2Message)"), dismissButton: .default(Text("Close")))
                            })
                            Text("\(self.bleManager.co2Round)ppm")
                                .font(.custom("Devanagari Sangam MN", size:30))
                                //.foregroundColor(Color.black)
                            Button(action: {    //PM2.5 button
                                //print(pm25Message)
                                pm25Alert = true
                            }, label: {
                                    Text("PM2.5")
                                        .font(.custom("Devanagari Sangam MN", size:25))
                                        .foregroundColor(Color.black)
                                    Image(systemName: "questionmark.circle")
                                        .foregroundColor(Color.black)
                            })
                            .alert(isPresented: $pm25Alert, content: {
                                Alert(title: Text("What is PM2.5?"), message: Text("\(pm25Message)"), dismissButton: .default(Text("Close")))
                            })
                            Text("\(self.bleManager.pm25Round)")
                                .font(.custom("Devanagari Sangam MN", size:30))
                                //.foregroundColor(Color.black)
                        }
                    }
                    */
                    VStack {
                            // Line
                            Section(header: Text("Temperature")) {
                                LineChartView(dataPoints: self.bleManager.tempPoints)
                                    .frame(width:350)
                                    .frame(height: UIScreen.main.bounds.size.height/3)
                                    .background(Color(.secondarySystemBackground))
                            }
                            // Bar
                            Section(header: Text("Humidity")) {
                                LineChartView(dataPoints: self.bleManager.humidityPoints)
                                    .frame(width:350)
                                    .frame(height: UIScreen.main.bounds.size.height/3)
                                    .background(Color(.secondarySystemBackground))
                            }
                            // Horizontal Bar
                            Section(header: Text("CO2")) {
                                LineChartView(dataPoints: self.bleManager.co2Points)
                                    .frame(width:350)
                                    .frame(height: UIScreen.main.bounds.size.height/3)
                                    .background(Color(.secondarySystemBackground))
                            }
                        
                            Section(header: Text("PM2.5")) {
                                LineChartView(dataPoints: self.bleManager.pm25Points)
                                    .frame(width:350)
                                    .frame(height: UIScreen.main.bounds.size.height/3)
                                    .background(Color(.secondarySystemBackground))
                            }
                    }
        }
        .onAppear(perform:{    //get alert authorization from the user
            self.getAuthorization()
        })
    }
}
}
    /*
    //open graph view
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
     */
    
    
    //open time setting view
    struct TimeSettingView:View{
        @Binding var hour: String
        @Binding var minute: String
        @Environment(\.presentationMode) var presentation
        let listHour: [String] = ["0","1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23"]
        let listMinute: [String] = ["00","01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","43","44","45","46","47","48","49","50","51","52","53","54","55","56","57","58","59"]
        var body:some View{
            NavigationView{
                Form{
                        Text("Hour(24HR.):")
                        Picker("",selection:$hour){
                            ForEach(listHour,id:\.self){ hour in
                                Text(hour)
                            }
                        }.labelsHidden()
                            .pickerStyle(.wheel)
                        Text("Minute:")
                        Picker("",selection:$minute){
                            ForEach(listMinute,id:\.self){ minute in
                                Text(minute)
                            }
                        }.labelsHidden()
                            .pickerStyle(.wheel)
                    }.frame(minWidth:0, maxWidth:.infinity)
                
                .navigationBarTitle("Set Notification Time")
                .navigationBarItems(trailing:Button("Save"){
                    self.presentation.wrappedValue.dismiss()
                })
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
    struct TimeSettingView_Previews:PreviewProvider{
        static var previews:some View{
            TimeSettingView(hour:.constant("Undefined"),minute:.constant("Undefined"))
        }
    }
    //permission to post notifications
    func getAuthorization(){
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings(completionHandler: {settings in if settings.authorizationStatus == .authorized{
            self.isButtonEnabled = true
        } else {
            center.requestAuthorization(options:[.alert, .sound], completionHandler: {granted, error  in
                if granted && error == nil {
                    self.isButtonEnabled = true
                } else {
                    self.isButtonEnabled = false
                }
            })
        }
        })
    }

    //methods
    func defaultMessage() -> String{
        let defaultMessage =
        "The temperature is \(self.bleManager.tempRound)°F/\(self.bleManager.tempCRound)°C. The humidity is \(self.bleManager.humidityInt)%. The CO2 level is \(self.bleManager.co2Int)ppm. The PM2.5 level is \(self.bleManager.pm25Int). "
        return defaultMessage
    }
    func summaryMessage() -> String{
        var message: String = ""
        if self.bleManager.pm25Int >= 0 && self.bleManager.pm25Int <= 50{
            if self.bleManager.co2Int > 1000 &&  self.bleManager.co2Int < 2000{
                if self.bleManager.tempInt < 60 && self.bleManager.tempInt >= 40 {
                    message = defaultMessage() + "It is cold outside, don't forget to wear something warm! In terms of the air quality, the PM2.5 level is in great range. However, the CO2 level in this area is a bit high. Thus, the air quality is considered to be poor. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
                else if self.bleManager.tempInt < 40 {
                    message = defaultMessage() + "It is FREEZING COLD outside, please take precautions before going out! In terms of the air quality, the PM2.5 level is in great range. However, the CO2 level in this area is a bit high. Thus, the air quality is considered to be poor. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
                else if self.bleManager.tempInt > 100 {
                    message = defaultMessage() + "It is hot outside, be aware of how your body reacts to this weather! In terms of the air quality, the PM2.5 level is in great range. However, the CO2 level in this area is a bit high. Thus, the air quality is considered to be poor. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
                else{
                message = defaultMessage() + "In terms of the air quality, the PM2.5 level is in great range. However, the CO2 level in this area is a bit high. Thus, the air quality is considered to be poor. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
            }
            else if self.bleManager.co2Int >= 2000 && self.bleManager.co2Int < 5000{
                if self.bleManager.tempInt < 60 && self.bleManager.tempInt >= 40 {
                    message = defaultMessage() + "It is cold outside, don't forget to wear something warm! In terms of the air quality, the PM2.5 level is in great range. However, the CO2 level in this area is considered to be dangerous. You might experience headache, dizziness, and increased heart rate if you continue to be exposed in this environment. Please be aware of this! Thus, the air quality is considered to be bad. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
                else if self.bleManager.tempInt < 40 {
                    message = defaultMessage() + "It is FREEZING COLD outside, please take precautions before going out! In terms of the air quality, the PM2.5 level is in great range. However, the CO2 level in this area is considered to be dangerous. You might experience headache, dizziness, and increased heart rate if you continue to be exposed in this environment. Please be aware of this! Thus, the air quality is considered to be bad. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
                else if self.bleManager.tempInt > 100 {
                    message = defaultMessage() + "It is hot outside, be aware of how your body reacts to this weather! In terms of the air quality, the PM2.5 level is in great range. However, the CO2 level in this area is considered to be dangerous. You might experience headache, dizziness, and increased heart rate if you continue to be exposed in this environment. Please be aware of this! Thus, the air quality is considered to be bad. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
                else{
                message = defaultMessage() + "In terms of the air quality, the PM2.5 level is in great range. However, the CO2 level in this area is considered to be dangerous. You might experience headache, dizziness, and increased heart rate if you continue to be exposed in this environment. Please be aware of this! Thus, the air quality is considered to be bad. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
            }
            else if self.bleManager.co2Int >= 5000{
                if self.bleManager.tempInt < 60 && self.bleManager.tempInt >= 40 {
                    message = defaultMessage() + "It is cold outside, don't forget to wear something warm! In terms of the air quality, the PM2.5 level is in great range. However, the CO2 level in this area is considered to be EXTREMELY DANGEROUS. Toxicity or oxygen deprivation could occur. Please be extremely cautious of this! Please leave this area as soon as possible! Thus, the air quality is considered to be CAUTION. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
                else if self.bleManager.tempInt < 40 {
                    message = defaultMessage() + "It is FREEZING COLD outside, please take precautions before going out! In terms of the air quality, the PM2.5 level is in great range. However, the CO2 level in this area is considered to be EXTREMELY DANGEROUS. Toxicity or oxygen deprivation could occur. Please be extremely cautious of this! Please leave this area as soon as possible! Thus, the air quality is considered to be CAUTION. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
                else if self.bleManager.tempInt > 100 {
                    message = defaultMessage() + "It is hot outside, be aware of how your body reacts to this weather! In terms of the air quality, the PM2.5 level is in great range. However, the CO2 level in this area is considered to be EXTREMELY DANGEROUS. Toxicity or oxygen deprivation could occur. Please be extremely cautious of this! Please leave this area as soon as possible! Thus, the air quality is considered to be CAUTION. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
                else{
                message = defaultMessage() + "In terms of the air quality, the PM2.5 level is in great range. However, the CO2 level in this area is considered to be EXTREMELY DANGEROUS. Toxicity or oxygen deprivation could occur. Please be extremely cautious of this! Please leave this area as soon as possible! Thus, the air quality is considered to be CAUTION. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
            }
            else {
                if self.bleManager.tempInt < 60 && self.bleManager.tempInt >= 40 {
                    message = defaultMessage() + "It is cold outside, don't forget to wear something warm! In terms of the air quality, the PM2.5 level is in great range. The CO2 level in this area is also in good range. Thus, the air quality is considered to be good. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
                else if self.bleManager.tempInt < 40 {
                    message = defaultMessage() + "It is FREEZING COLD outside, please take precautions before going out! In terms of the air quality, the PM2.5 level is in great range. The CO2 level in this area is also in good range. Thus, the air quality is considered to be good. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
                else if self.bleManager.tempInt > 100 {
                    message = defaultMessage() + "It is hot outside, be aware of how your body reacts to this weather! In terms of the air quality, the PM2.5 level is in great range. The CO2 level in this area is also in good range. Thus, the air quality is considered to be good. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
                else{
                message = defaultMessage() + "In terms of the air quality, the PM2.5 level is in great range. The CO2 level in this area is also in good range. Thus, the air quality is considered to be good. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
            }
        }
        else if self.bleManager.pm25Int > 50 && self.bleManager.pm25Int <=  100{
            if self.bleManager.co2Int > 1000 &&  self.bleManager.co2Int < 2000{
                if self.bleManager.tempInt < 60 && self.bleManager.tempInt >= 40 {
                    message = defaultMessage() + "It is cold outside, don't forget to wear something warm! In terms of the air quality, the PM2.5 level is in moderate range, meaning it is not harmful to you, but anything higher than this range could be dangerous. Also, the CO2 level in this area is a bit high. Thus, the air quality is considered to be poor. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
                else if self.bleManager.tempInt < 40 {
                    message = defaultMessage() + "It is FREEZING COLD outside, please take precautions before going out! In terms of the air quality, the PM2.5 level is in moderate range, meaning it is not harmful to you, but anything higher than this range could be dangerous. Also, the CO2 level in this area is a bit high. Thus, the air quality is considered to be poor. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
                else if self.bleManager.tempInt > 100 {
                    message = defaultMessage() + "It is hot outside, be aware of how your body reacts to this weather! In terms of the air quality, the PM2.5 level is in moderate range, meaning it is not harmful to you, but anything higher than this range could be dangerous. Also, the CO2 level in this area is a bit high. Thus, the air quality is considered to be poor. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
                else{
                message = defaultMessage() + "In terms of the air quality, the PM2.5 level is in moderate range, meaning it is not harmful to you, but anything higher than this range could be dangerous. Also, the CO2 level in this area is a bit high. Thus, the air quality is considered to be poor. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
            }
            else if self.bleManager.co2Int >= 2000 && self.bleManager.co2Int < 5000{
                if self.bleManager.tempInt < 60 && self.bleManager.tempInt >= 40 {
                    message = defaultMessage() + "It is cold outside, don't forget to wear something warm! In terms of the air quality, the PM2.5 level is in moderate range, meaning it is not harmful to you, but anything higher than this range could be dangerous. Also, the CO2 level in this area is considered to be dangerous. You might experience headache, dizziness, and increased heart rate if you continue to be exposed in this environment. Please be aware of this! Thus, the air quality is considered to be bad. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
                else if self.bleManager.tempInt < 40 {
                    message = defaultMessage() + "It is FREEZING COLD outside, please take precautions before going out! In terms of the air quality, the PM2.5 level is in moderate range, meaning it is not harmful to you, but anything higher than this range could be dangerous. Also, the CO2 level in this area is considered to be dangerous. You might experience headache, dizziness, and increased heart rate if you continue to be exposed in this environment. Please be aware of this! Thus, the air quality is considered to be bad. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
                else if self.bleManager.tempInt > 100 {
                    message = defaultMessage() + "It is hot outside, be aware of how your body reacts to this weather! In terms of the air quality, the PM2.5 level is in moderate range, meaning it is not harmful to you, but anything higher than this range could be dangerous. Also, the CO2 level in this area is considered to be dangerous. You might experience headache, dizziness, and increased heart rate if you continue to be exposed in this environment. Please be aware of this! Thus, the air quality is considered to be bad. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
                else{
                message = defaultMessage() + "In terms of the air quality, the PM2.5 level is in moderate range, meaning it is not harmful to you, but anything higher than this range could be dangerous. Also, the CO2 level in this area is considered to be dangerous. You might experience headache, dizziness, and increased heart rate if you continue to be exposed in this environment. Please be aware of this! Thus, the air quality is considered to be bad. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
            }
            else if self.bleManager.co2Int >= 5000{
                if self.bleManager.tempInt < 60 && self.bleManager.tempInt >= 40 {
                    message = defaultMessage() + "It is cold outside, don't forget to wear something warm! In terms of the air quality, the PM2.5 level is in moderate range, meaning it is not harmful to you, but anything higher than this range could be dangerous. Also, the CO2 level in this area is considered to be EXTREMELY DANGEROUS. Toxicity or oxygen deprivation could occur. Please be extremely cautious of this! Please leave this area as soon as possible! Thus, the air quality is considered to be CAUTION. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
                else if self.bleManager.tempInt < 40 {
                    message = defaultMessage() + "It is FREEZING COLD outside, please take precautions before going out! In terms of the air quality, the PM2.5 level is in moderate range, meaning it is not harmful to you, but anything higher than this range could be dangerous. Also, the CO2 level in this area is considered to be EXTREMELY DANGEROUS. Toxicity or oxygen deprivation could occur. Please be extremely cautious of this! Please leave this area as soon as possible! Thus, the air quality is considered to be CAUTION. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
                else if self.bleManager.tempInt > 100 {
                    message = defaultMessage() + "It is hot outside, be aware of how your body reacts to this weather! In terms of the air quality, the PM2.5 level is in moderate range, meaning it is not harmful to you, but anything higher than this range could be dangerous. Also, the CO2 level in this area is considered to be EXTREMELY DANGEROUS. Toxicity or oxygen deprivation could occur. Please be extremely cautious of this! Please leave this area as soon as possible! Thus, the air quality is considered to be CAUTION. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
                else{
                message = defaultMessage() + "In terms of the air quality, the PM2.5 level is in moderate range, meaning it is not harmful to you, but anything higher than this range could be dangerous. Also, the CO2 level in this area is considered to be EXTREMELY DANGEROUS. Toxicity or oxygen deprivation could occur. Please be extremely cautious of this! Please leave this area as soon as possible! Thus, the air quality is considered to be CAUTION. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
            }
            else {
                if self.bleManager.tempInt < 60 && self.bleManager.tempInt >= 40 {
                    message = defaultMessage() + "It is cold outside, don't forget to wear something warm! In terms of the air quality, the PM2.5 level is in moderate range, meaning it is not harmful to you, but anything higher than this range could be dangerous. The CO2 level in this area is also in good range. Thus, the air quality is considered to be moderate. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
                else if self.bleManager.tempInt < 40 {
                    message = defaultMessage() + "It is FREEZING COLD outside, please take precautions before going out! In terms of the air quality, the PM2.5 level is in moderate range, meaning it is not harmful to you, but anything higher than this range could be dangerous. The CO2 level in this area is also in good range. Thus, the air quality is considered to be moderate. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
                else if self.bleManager.tempInt > 100 {
                    message = defaultMessage() + "It is hot outside, be aware of how your body reacts to this weather! In terms of the air quality, the PM2.5 level is in moderate range, meaning it is not harmful to you, but anything higher than this range could be dangerous. The CO2 level in this area is also in good range. Thus, the air quality is considered to be moderate. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
                else{
                message = defaultMessage() + "In terms of the air quality, the PM2.5 level is in moderate range, meaning it is not harmful to you, but anything higher than this range could be dangerous. The CO2 level in this area is also in good range. Thus, the air quality is considered to be moderate. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
            }
        }
        else if self.bleManager.pm25Int > 100 &&  self.bleManager.pm25Int <= 150{
            if self.bleManager.co2Int > 1000 &&  self.bleManager.co2Int < 2000{
                if self.bleManager.tempInt < 60 && self.bleManager.tempInt >= 40 {
                    message = defaultMessage() + "It is cold outside, don't forget to wear something warm! In terms of the air quality, the PM2.5 level is a bit high and can be harmful to sensitive groups that have respiratory diseases. Please take precautions! The CO2 level in this area is also a bit high. Thus, the air quality is considered to be bad. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
                else if self.bleManager.tempInt < 40 {
                    message = defaultMessage() + "It is FREEZING COLD outside, please take precautions before going out! In terms of the air quality, the PM2.5 level is a bit high and can be harmful to sensitive groups that have respiratory diseases. Please take precautions! The CO2 level in this area is also a bit high. Thus, the air quality is considered to be bad. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
                else if self.bleManager.tempInt > 100 {
                    message = defaultMessage() + "It is hot outside, be aware of how your body reacts to this weather! In terms of the air quality, the PM2.5 level is a bit high and can be harmful to sensitive groups that have respiratory diseases. Please take precautions! The CO2 level in this area is also a bit high. Thus, the air quality is considered to be bad. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
                else{
                message = defaultMessage() + "In terms of the air quality, the PM2.5 level is a bit high and can be harmful to sensitive groups that have respiratory diseases. Please take precautions! The CO2 level in this area is also a bit high. Thus, the air quality is considered to be bad. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
            }
            else if self.bleManager.co2Int >= 2000 && self.bleManager.co2Int < 5000{
                if self.bleManager.tempInt < 60 && self.bleManager.tempInt >= 40 {
                    message = defaultMessage() + "It is cold outside, don't forget to wear something warm! In terms of the air quality, the PM2.5 level is a bit high and can be harmful to sensitive groups that have respiratory diseases. Please take precautions! Also, the CO2 level in this area is considered to be dangerous. You might experience headache, dizziness, and increased heart rate if you continue to be exposed in this environment. Please be aware of this! Thus, the air quality is considered to be bad. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
                else if self.bleManager.tempInt < 40 {
                    message = defaultMessage() + "It is FREEZING COLD outside, please take precautions before going out! In terms of the air quality, the PM2.5 level is a bit high and can be harmful to sensitive groups that have respiratory diseases. Please take precautions! Also, the CO2 level in this area is considered to be dangerous. You might experience headache, dizziness, and increased heart rate if you continue to be exposed in this environment. Please be aware of this! Thus, the air quality is considered to be bad. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
                else if self.bleManager.tempInt > 100 {
                    message = defaultMessage() + "It is hot outside, be aware of how your body reacts to this weather! In terms of the air quality, the PM2.5 level is a bit high and can be harmful to sensitive groups that have respiratory diseases. Please take precautions! Also, the CO2 level in this area is considered to be dangerous. You might experience headache, dizziness, and increased heart rate if you continue to be exposed in this environment. Please be aware of this! Thus, the air quality is considered to be bad. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
                else{
                message = defaultMessage() + "In terms of the air quality, the PM2.5 level is a bit high and can be harmful to sensitive groups that have respiratory diseases. Please take precautions! Also, the CO2 level in this area is considered to be dangerous. You might experience headache, dizziness, and increased heart rate if you continue to be exposed in this environment. Please be aware of this! Thus, the air quality is considered to be bad. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
            }
            else if self.bleManager.co2Int >= 5000{
                if self.bleManager.tempInt < 60 && self.bleManager.tempInt >= 40 {
                    message = defaultMessage() + "It is cold outside, don't forget to wear something warm! In terms of the air quality, the PM2.5 level is a bit high and can be harmful to sensitive groups that have respiratory diseases. Please take precautions! Also, the CO2 level in this area is considered to be EXTREMELY DANGEROUS. Toxicity or oxygen deprivation could occur. Please be extremely cautious of this! Please leave this area as soon as possible! Thus, the air quality is considered to be CAUTION. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
                else if self.bleManager.tempInt < 40 {
                    message = defaultMessage() + "It is FREEZING COLD outside, please take precautions before going out! In terms of the air quality, the PM2.5 level is a bit high and can be harmful to sensitive groups that have respiratory diseases. Please take precautions! Also, the CO2 level in this area is considered to be EXTREMELY DANGEROUS. Toxicity or oxygen deprivation could occur. Please be extremely cautious of this! Please leave this area as soon as possible! Thus, the air quality is considered to be CAUTION. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
                else if self.bleManager.tempInt > 100 {
                    message = defaultMessage() + "It is hot outside, be aware of how your body reacts to this weather! In terms of the air quality, the PM2.5 level is a bit high and can be harmful to sensitive groups that have respiratory diseases. Please take precautions! Also, the CO2 level in this area is considered to be EXTREMELY DANGEROUS. Toxicity or oxygen deprivation could occur. Please be extremely cautious of this! Please leave this area as soon as possible! Thus, the air quality is considered to be CAUTION. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
                else{
                message = defaultMessage() + "In terms of the air quality, the PM2.5 level is a bit high and can be harmful to sensitive groups that have respiratory diseases. Please take precautions! Also, the CO2 level in this area is considered to be EXTREMELY DANGEROUS. Toxicity or oxygen deprivation could occur. Please be extremely cautious of this! Please leave this area as soon as possible! Thus, the air quality is considered to be CAUTION. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
            }
            else {
                if self.bleManager.tempInt < 60 && self.bleManager.tempInt >= 40 {
                    message = defaultMessage() + "It is cold outside, don't forget to wear something warm! In terms of the air quality, the CO2 level in this area is in good range. However, the PM2.5 level is a bit high and can be harmful to sensitive groups that have respiratory diseases. Please take precautions! Thus, the air quality is considered to be bad. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
                else if self.bleManager.tempInt < 40 {
                    message = defaultMessage() + "It is FREEZING COLD outside, please take precautions before going out! In terms of the air quality, the CO2 level in this area is in good range. However, the PM2.5 level is a bit high and can be harmful to sensitive groups that have respiratory diseases. Please take precautions! Thus, the air quality is considered to be bad. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
                else if self.bleManager.tempInt > 100 {
                    message = defaultMessage() + "It is hot outside, be aware of how your body reacts to this weather! In terms of the air quality, the CO2 level in this area is in good range. However, the PM2.5 level is a bit high and can be harmful to sensitive groups that have respiratory diseases. Please take precautions! Thus, the air quality is considered to be bad. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
                else{
                message = defaultMessage() + "In terms of the air quality, the CO2 level in this area is in good range. However, the PM2.5 level is a bit high and can be harmful to sensitive groups that have respiratory diseases. Please take precautions! Thus, the air quality is considered to be bad. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
            }
        }
        else if self.bleManager.pm25Int > 150 && self.bleManager.pm25Int <= 200{
            if self.bleManager.co2Int > 1000 &&  self.bleManager.co2Int < 2000{
                if self.bleManager.tempInt < 60 && self.bleManager.tempInt >= 40 {
                    message = defaultMessage() + "It is cold outside, don't forget to wear something warm! In terms of the air quality, the PM2.5 level is considered to be high and can be EXTREMELY UNHEALTHY. Please leave this area as soon as possible! The CO2 level in this area is also a bit high. Thus, the air quality is considered to be CAUTION. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
                else if self.bleManager.tempInt < 40 {
                    message = defaultMessage() + "It is FREEZING COLD outside, please take precautions before going out! In terms of the air quality, the PM2.5 level is considered to be high and can be EXTREMELY UNHEALTHY. Please leave this area as soon as possible! The CO2 level in this area is also a bit high. Thus, the air quality is considered to be CAUTION. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
                else if self.bleManager.tempInt > 100 {
                    message = defaultMessage() + "It is hot outside, be aware of how your body reacts to this weather! In terms of the air quality, the PM2.5 level is considered to be high and can be EXTREMELY UNHEALTHY. Please leave this area as soon as possible! The CO2 level in this area is also a bit high. Thus, the air quality is considered to be CAUTION. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
                else{
                message = defaultMessage() + "In terms of the air quality, the PM2.5 level is considered to be high and can be EXTREMELY UNHEALTHY. Please leave this area as soon as possible! The CO2 level in this area is also a bit high. Thus, the air quality is considered to be CAUTION. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
            }
            else if self.bleManager.co2Int >= 2000 && self.bleManager.co2Int < 5000{
                if self.bleManager.tempInt < 60 && self.bleManager.tempInt >= 40 {
                    message = defaultMessage() + "It is cold outside, don't forget to wear something warm! In terms of the air quality, the PM2.5 level is considered to be high and can be EXTREMELY UNHEALTHY. Please leave this area as soon as possible! Also, the CO2 level in this area is considered to be dangerous. You might experience headache, dizziness, and increased heart rate if you continue to be exposed in this environment. Please be aware of this! Thus, the air quality is considered to be CAUTION. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
                else if self.bleManager.tempInt < 40 {
                    message = defaultMessage() + "It is FREEZING COLD outside, please take precautions before going out! In terms of the air quality, the PM2.5 level is considered to be high and can be EXTREMELY UNHEALTHY. Please leave this area as soon as possible! Also, the CO2 level in this area is considered to be dangerous. You might experience headache, dizziness, and increased heart rate if you continue to be exposed in this environment. Please be aware of this! Thus, the air quality is considered to be CAUTION. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
                else if self.bleManager.tempInt > 100 {
                    message = defaultMessage() + "It is hot outside, be aware of how your body reacts to this weather! In terms of the air quality, the PM2.5 level is considered to be high and can be EXTREMELY UNHEALTHY. Please leave this area as soon as possible! Also, the CO2 level in this area is considered to be dangerous. You might experience headache, dizziness, and increased heart rate if you continue to be exposed in this environment. Please be aware of this! Thus, the air quality is considered to be CAUTION. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
                else{
                message = defaultMessage() + "In terms of the air quality, the PM2.5 level is considered to be high and can be EXTREMELY UNHEALTHY. Please leave this area as soon as possible! Also, the CO2 level in this area is considered to be dangerous. You might experience headache, dizziness, and increased heart rate if you continue to be exposed in this environment. Please be aware of this! Thus, the air quality is considered to be CAUTION. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
            }
            else if self.bleManager.co2Int >= 5000{
                if self.bleManager.tempInt < 60 && self.bleManager.tempInt >= 40 {
                    message = defaultMessage() + "It is cold outside, don't forget to wear something warm! In terms of the air quality, the PM2.5 level is considered to be high and can be EXTREMELY UNHEALTHY. Please leave this area as soon as possible! Also, the CO2 level in this area is considered to be EXTREMELY DANGEROUS. Toxicity or oxygen deprivation could occur. Please be extremely cautious of this! Thus, the air quality is considered to be CAUTION. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
                else if self.bleManager.tempInt < 40 {
                    message = defaultMessage() + "It is FREEZING COLD outside, please take precautions before going out! In terms of the air quality, the PM2.5 level is considered to be high and can be EXTREMELY UNHEALTHY. Please leave this area as soon as possible! Also, the CO2 level in this area is considered to be EXTREMELY DANGEROUS. Toxicity or oxygen deprivation could occur. Please be extremely cautious of this! Thus, the air quality is considered to be CAUTION. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
                else if self.bleManager.tempInt > 100 {
                    message = defaultMessage() + "It is hot outside, be aware of how your body reacts to this weather! In terms of the air quality, the PM2.5 level is considered to be high and can be EXTREMELY UNHEALTHY. Please leave this area as soon as possible! Also, the CO2 level in this area is considered to be EXTREMELY DANGEROUS. Toxicity or oxygen deprivation could occur. Please be extremely cautious of this! Thus, the air quality is considered to be CAUTION. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
                else{
                message = defaultMessage() + "In terms of the air quality, the PM2.5 level is considered to be high and can be EXTREMELY UNHEALTHY. Please leave this area as soon as possible! Also, the CO2 level in this area is considered to be EXTREMELY DANGEROUS. Toxicity or oxygen deprivation could occur. Please be extremely cautious of this! Thus, the air quality is considered to be CAUTION. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
            }
            else {
                if self.bleManager.tempInt < 60 && self.bleManager.tempInt >= 40 {
                    message = defaultMessage() + "It is cold outside, don't forget to wear something warm! In terms of the air quality, the CO2 level in this area is in good range. However, the PM2.5 level is considered to be high and can be EXTREMELY UNHEALTHY. Please leave this area as soon as possible! Thus, the air quality is considered to be CAUTION. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
                else if self.bleManager.tempInt < 40 {
                    message = defaultMessage() + "It is FREEZING COLD outside, please take precautions before going out! In terms of the air quality, the CO2 level in this area is in good range. However, the PM2.5 level is considered to be high and can be EXTREMELY UNHEALTHY. Please leave this area as soon as possible! Thus, the air quality is considered to be CAUTION. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
                else if self.bleManager.tempInt > 100 {
                    message = defaultMessage() + "It is hot outside, be aware of how your body reacts to this weather! In terms of the air quality, the CO2 level in this area is in good range. However, the PM2.5 level is considered to be high and can be EXTREMELY UNHEALTHY. Please leave this area as soon as possible! Thus, the air quality is considered to be CAUTION. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
                else{
                message = defaultMessage() + "In terms of the air quality, the CO2 level in this area is in good range. However, the PM2.5 level is considered to be high and can be EXTREMELY UNHEALTHY. Please leave this area as soon as possible! Thus, the air quality is considered to be CAUTION. If you have any concern regarding the meaning of the sensor readings, please refer to each sensor category by clicking on it!"
                }
            }
        }
        return message
    }
    
    func airQuality() -> String{
        var message: String = ""
        if self.bleManager.pm25Int >= 0 && self.bleManager.pm25Int <= 50{
            if self.bleManager.co2Int > 1000 &&  self.bleManager.co2Int < 2000{
                message = "Poor"
            }
            else if self.bleManager.co2Int >= 2000 && self.bleManager.co2Int < 5000{
                message = "Bad"
            }
            else if self.bleManager.co2Int >= 5000{
                message = "Caution"
            }
            else {
                message = "Good"
            }
        }
        else if self.bleManager.pm25Int > 50 && self.bleManager.pm25Int <=  100{
            if self.bleManager.co2Int > 1000 &&  self.bleManager.co2Int < 2000{
                message = "Poor"
            }
            else if self.bleManager.co2Int >= 2000 && self.bleManager.co2Int < 5000{
                message = "Bad"
            }
            else if self.bleManager.co2Int >= 5000{
                message = "Caution"
            }
            else {
                message = "Moderate"
            }
        }
        else if self.bleManager.pm25Int > 100 &&  self.bleManager.pm25Int <= 150{
            if self.bleManager.co2Int > 1000 &&  self.bleManager.co2Int < 2000{
                message = "Bad"
            }
            else if self.bleManager.co2Int >= 2000 && self.bleManager.co2Int < 5000{
                message = "Bad"
            }
            else if self.bleManager.co2Int >= 5000{
                message = "Caution"
            }
            else {
                message = "Bad"
            }
        }
        else if self.bleManager.pm25Int > 150 && self.bleManager.pm25Int <= 200{
            if self.bleManager.co2Int > 1000 &&  self.bleManager.co2Int < 2000{
                message = "Caution"
            }
            else if self.bleManager.co2Int >= 2000 && self.bleManager.co2Int < 5000{
                message = "Caution"
            }
            else if self.bleManager.co2Int >= 5000{
                message = "Caution"
            }
            else {
                message = "Caution"
            }
        }
        return message
    }
    
}
struct TransparentGroupBox: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.content
            .frame(width:150,height: 60)//maxWidth: .infinity
            .padding()
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.3)))
            .overlay(configuration.label.padding(.leading, 10).padding(.vertical,5), alignment: .topLeading)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .previewDevice("iPhone 13")
            .previewDisplayName("iPhone 13")
        }
    }
}

