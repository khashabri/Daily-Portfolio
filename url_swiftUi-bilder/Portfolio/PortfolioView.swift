//
//  PortfolioView.swift
//  url_swiftUi-bilder
//
//  Created by Khashayar Abri on 08.08.20.
//  Copyright © 2020 Khashayar Abri. All rights reserved.
//

import SwiftUI

struct PortfolioView: View {
    var body: some View {
        NavigationView{
            VStack{
                List(0..<3) {_ in
                    Text("Item 1")
                }
                
                Form {
                    
                    Section(header: Text("ABOUT")) {
                        HStack {
                            Text("Version")
                            Spacer()
                            Text("2.2.1")
                        }
                        HStack {
                            Text("Copyright")
                            Spacer()
                            Text("@ khashabri")
                        }
                    }
                }
                .padding(.bottom, -100.0)
                .offset(x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: -100)
            }
            
            .navigationBarTitle(Text("Portfolio"))
        }
    }
}

struct PortfolioView_Previews: PreviewProvider {
    static var previews: some View {
        PortfolioView()
    }
}
