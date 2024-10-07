//
//  Extensions.swift
//  Appwrite Jobs
//
//  Created by Damodar Lohani on 15/10/2021.
//

import SwiftUI

extension Text {
    func largeSemiBoldFont() -> Text {
        self.font(.custom("Poppins", size: 34))
            .fontWeight(.semibold)
    }
    
    func normalSemiBoldFont() -> Text {
        self.font(.custom("Poppins", size: 16))
            .fontWeight(.semibold)
    }
    
    func largeLightFont() -> Text {
        self.font(.custom("Poppins", size: 30))
            .fontWeight(.light)
    }
    
    func largeBoldFont() -> Text {
        self.font(.custom("Poppins", size: 24))
            .fontWeight(.bold)
    }
    
}

extension View {
    func regularFont() -> some View {
        self.font(.custom("Poppins", size: 16))
    }
    
}
