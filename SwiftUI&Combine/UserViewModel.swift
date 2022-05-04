//
//  UserViewModel.swift
//  SwiftUI&Combine
//
//  Created by Вячеслав Квашнин on 04.05.2022.
//

import Combine
import Foundation

class UserViewModel: ObservableObject {
    @Published var userName = ""
    @Published var password = ""
    @Published var passwordAgain = ""
    
    @Published var isValid = false
    private var cancellableSet: Set<AnyCancellable> = []
    
    init() {
        $userName
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { input in
                input.count >= 3
            }
            .assign(to: \.isValid, on: self)
            .store(in: &cancellableSet)
    }
    
    private var isPasswordEmptyPublisher: AnyPublisher<Bool, Never> {
        $password
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { password in
                password == ""
            }
            .eraseToAnyPublisher()
    }
    
    private var arePasswordsEqualPublisher: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest($password, $passwordAgain)
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .map { password, passwordAgain in
                password == passwordAgain
            }
            .eraseToAnyPublisher()
    }
}
