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
    @State private var termsAccepted = false
    @State private var amountOfStock = ""
    @State private var pricePerShare = ""
    
    
    // this variable is somit shared through all views with this line
    @EnvironmentObject var settings: UserSettings
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        VStack {
            Form {
                HStack{
                    Image(myDic_Symb2Img[getKey(value: self.compName)]!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 40)
                        .cornerRadius(10)
                    Text(compName)
                        .font(.title)
                }
                
                Section(header: HStack{
                    Image(systemName: "cart")
                    Text("Purchase Informations")}, footer: Text("If you don't set the price manually the purchased price will be the close price of the purchase date.")){
                        DatePicker("Your stock purchase date:", selection: $selectedDate, displayedComponents: .date)
                        
                        TextField("Purchased amount", text: $amountOfStock)
                            .keyboardType(.numberPad)
                            .onReceive(Just(amountOfStock)) { newValue in
                                let filtered = newValue.filter { ".0123456789".contains($0) }
                                if filtered != newValue {
                                    self.amountOfStock = filtered
                                }
                        }
                }
                
                Toggle(isOn: $termsAccepted,
                       label: {
                        Text("Enter directly the price")
                })
                if termsAccepted{
                    TextField("Price per share", text: $pricePerShare)
                        .keyboardType(.numberPad)
                        .onReceive(Just(pricePerShare)) { newValue in
                            let filtered = newValue.filter { ".0123456789".contains($0) }
                            if filtered != newValue {
                                self.pricePerShare = filtered
                            }
                    }
                }
            }
            .gesture(DragGesture().onChanged{_ in UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)})

            .padding(.bottom, -1111.0)
            
            //
            Spacer()
            Button(action: {
                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd"
                let date = df.string(from: self.selectedDate)
                
                let userInput = UserInput(compName: self.compName, purchaseDate:date, purchaseAmount: Double(self.amountOfStock)!)
                self.settings.portfolio.append(userInput)
                print(self.selectedDate)
                
                //                self.shouldPopToRootView = false
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
                .padding()
                .foregroundColor(.white)
                .background(LinearGradient(gradient: Gradient(colors: [Color.red, Color.blue]), startPoint: .leading, endPoint: .trailing))
                .cornerRadius(40)
                .padding(.vertical, 30)
            }.frame(alignment: .bottom)
            //
        }
    }
}

// to use this first comment out @Binding var shouldPopToRootView : Bool
struct AskingView_Previews: PreviewProvider {
    static var previews: some View {
        AskingView(compName: "Apple Inc.")
    }
}
