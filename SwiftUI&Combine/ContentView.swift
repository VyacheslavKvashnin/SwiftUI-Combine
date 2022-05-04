//
//  ContentView.swift
//  SwiftUI&Combine
//
//  Created by Вячеслав Квашнин on 04.05.2022.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var userViewModel = UserViewModel()
    var body: some View {
        Form {
            TextField("Enter Your Name", text: $userViewModel.userName)
            
            Section {
                SecureField("Enter Your Password", text: $userViewModel.password)
                
                SecureField("Enter Your Password Again", text: $userViewModel.passwordAgain)
            }
            
            Button {
                
            } label: {
                Text("Sing Up")
            }.disabled(!userViewModel.isValid)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
