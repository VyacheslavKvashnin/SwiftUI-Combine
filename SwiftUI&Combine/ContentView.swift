//
//  ContentView.swift
//  SwiftUI&Combine
//
//  Created by Вячеслав Квашнин on 04.05.2022.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var userViewModel = UserViewModel()
    @State private var presentAlert = false
    
    var body: some View {
        Form {
            Section(content: {
                TextField("Enter Your Name", text: $userViewModel.userName)
            }, header: {
                Text(userViewModel.usernameMessage)
            })
            
            Section(content: {
                SecureField("Enter Your Password", text: $userViewModel.password)
                SecureField("Enter Your Password Again", text: $userViewModel.passwordAgain)
                
            }, header: {
                Text(userViewModel.passwordMessage)
            })
            
            Button {
                singUp()
            } label: {
                Text("Sing Up")
            }.disabled(!userViewModel.isValid)
        }
        .sheet(isPresented: $presentAlert) {
            WelcomeView()
        }
    }
    func singUp() {
        self.presentAlert = true
    }
}

struct WelcomeView: View {
    var body: some View {
        Text("Welcome! Great to have you on board!")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
