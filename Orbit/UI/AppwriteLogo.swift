//
//  AppwriteLogo.swift
//  Appwrite Jobs
//
//  Created by Damodar Lohani on 14/10/2021.
//

import SwiftUI

struct AppwriteLogo<Content: View>: View {
    
    @ViewBuilder var content: Content
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    Image("bg")
                }
                Spacer()
            }.ignoresSafeArea()
            content
//            VStack (alignment: .trailing){
//                Spacer()
//                HStack {
//                    Spacer()
//                    Image("built-with-appwrite")
//                        .resizable()
//                        .frame(width: 132, height: 90)
//                }
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct AppwriteLogo_Previews: PreviewProvider {
    static var previews: some View {
        AppwriteLogo() {
            Text("Hello Appwrite")
        }
            .preferredColorScheme(.dark)
    }
}
