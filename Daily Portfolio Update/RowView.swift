//
//  RowView.swift
//  url_swiftUi-bilder
//
//  Created by Khashayar Abri on 01.08.20.
//  Copyright © 2020 Khashayar Abri. All rights reserved.
//

import SwiftUI

struct RowView: View {
    @State var aCompanyData: CompData
    
    var body: some View {
        HStack
            {
                LogoView(name_of_company: myDic_Symb2Img[String(aCompanyData.symbol)]!)
                    .padding(.trailing, 12.0)
                
                VStack(alignment: .leading)
                {
                    Text(String(myDic_Symb2Name[aCompanyData.symbol]!))
                        .font(.title)
                        .padding(.bottom, 6.0)
                        .offset(x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: /*@START_MENU_TOKEN@*/-3.0/*@END_MENU_TOKEN@*/)
                    HStack
                        {
                            Text("Price:")
                                .font(.subheadline)
                            Text(String((aCompanyData.close*100).rounded()/100))
                                .font(.subheadline)
                            Spacer()
                            
                            if aCompanyData.pchange < 0
                            {
                                Text(String(aCompanyData.pchange)+" %")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.red)
                            }
                                
                            else
                            {
                                Text(String(aCompanyData.pchange)+" %")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.green)
                            }
                    }
                }
        }
        .padding()
        .frame(height: 90)
    }
}


struct RowView_Previews: PreviewProvider {
    static var previews: some View {
        RowView(aCompanyData: offlineData[0])
    }
}

