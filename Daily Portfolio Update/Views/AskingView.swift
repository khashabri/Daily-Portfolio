//
//  AskingView.swift
//  url_swiftUi-bilder
//
//  Created by Khashayar Abri on 26.08.20.
//  Copyright © 2020 Khashayar Abri. All rights reserved.
//

import SwiftUI
import Combine

struct AskingView: View {
    @State var compName: String
    @State var selectedDate = Date()
    @State private var toggleOn = false
    @State private var amountOfStock = ""
    @State private var manualPurchasedPrice = ""
    @State private var today = get_today()
    
    // this variable is somit shared through all views with this line
    @EnvironmentObject var settings: UserSettings
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        VStack {
            Form {
                HStack{
                    if (UIImage(named: myDic_Symb2Img[getKey(value: self.compName)]!) != nil) {
                        Image(myDic_Symb2Img[getKey(value: self.compName)]!)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 40)
                            .cornerRadius(10)
                    }
                    Text(compName)
                        .font(.title)
                        .lineLimit(1)
                        .minimumScaleFactor(0.1)
                }
                
                Section(header: HStack{
                    Image(systemName: "cart")
                    Text("Purchase Informations")}){
                        DatePicker("Your stock purchase date:", selection: $selectedDate, displayedComponents: .date)
                        
                        TextField("Purchased amount", text: $amountOfStock)
                            .keyboardType(.decimalPad)
                            .onReceive(Just(amountOfStock)) { newValue in
                                let filtered = newValue.filter { ",.0123456789".contains($0) }
                                if filtered != newValue {
                                    self.amountOfStock = filtered
                                }
                        }
                }
                
                Toggle(isOn: $toggleOn,
                       label: {
                        Text("Enter price per share manually")
                            .lineLimit(1)
                            .minimumScaleFactor(0.1)
                })
                if toggleOn{
                    TextField("Price per share", text: $manualPurchasedPrice)
                        .keyboardType(.decimalPad)
                        .onReceive(Just(manualPurchasedPrice)) { newValue in
                            let filtered = newValue.filter { ",.0123456789".contains($0) }
                            if filtered != newValue {
                                self.manualPurchasedPrice = filtered
                            }
                    }
                }
                
                Section(footer: Text("If you don't set the price manually the purchased price will be the close price of the purchase date.")){
                    Button(action: {
                        settingsForPreview.isLoading = true
                        let df = DateFormatter()
                        df.dateFormat = "yyyy-MM-dd"
                        let date = df.string(from: self.selectedDate)
                        
                        let userInput: UserInput
                        
                        self.amountOfStock = self.amountOfStock.replacingOccurrences(of: ",", with: ".")
                        self.manualPurchasedPrice = self.manualPurchasedPrice.replacingOccurrences(of: ",", with: ".")
                        
                        if self.toggleOn && self.manualPurchasedPrice != ""{
                            userInput = UserInput(compName: self.compName, purchaseDate:date, purchaseAmount: Double(self.amountOfStock)!, manualPurchasedPrice: Double(self.manualPurchasedPrice)!)
                        }
                        else{
                            userInput = UserInput(compName: self.compName, purchaseDate:date, purchaseAmount: Double(self.amountOfStock)!)
                        }
                        
                        self.settings.portfolio.append(userInput)
                        print(self.selectedDate)
                        
                        self.presentationMode.wrappedValue.dismiss()
                        self.presentationMode.wrappedValue.dismiss()
                        
                    }) {
                        HStack {
                            Image(systemName: "cart.badge.plus")
                                .font(.title)
                            Text("Done")
                                .fontWeight(.semibold)
                                .font(.callout)
                            
                        }
                        .frame(minWidth: 0, maxWidth: 200)
                        .padding(.vertical,15)
                        .foregroundColor(buttonTextColor)
                        .cornerRadius(40)
                        
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                    .disabled(buttonTextColor == .gray)
                }
            }
                
            .gesture(DragGesture().onChanged{_ in UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)})
        }
    }
    
    var buttonTextColor: Color {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let date = df.string(from: self.selectedDate)
        let color: Color = (amountOfStock != "") && (today>date) && (!toggleOn || manualPurchasedPrice != "") ? .blue : .gray
        return color
    }
    
}

// to use this first comment out @Binding var shouldPopToRootView : Bool
struct AskingView_Previews: PreviewProvider {
    static var previews: some View {
        AskingView(compName: "Apple Inc.")
    }
}
