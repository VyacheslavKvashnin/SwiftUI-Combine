//
//  UserViewModel.swift
//  SwiftUI&Combine
//
//  Created by Вячеслав Квашнин on 04.05.2022.
//

import Combine
import Foundation
import Navajo_Swift

enum PasswordCheck {
    case valid
    case empty
    case noMatch
    case notStrongEnough
}

class UserViewModel: ObservableObject {
    @Published var userName = ""
    @Published var password = ""
    @Published var passwordAgain = ""
    
    @Published var isValid = false
    
    @Published var usernameMessage = ""
    @Published var passwordMessage = ""
    
    private var cancellableSet: Set<AnyCancellable> = []
    
    private var isUsernameValidPublisher: AnyPublisher<Bool, Never> {
        $userName
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { input in
                input.count >= 3
            }
            .eraseToAnyPublisher()
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
    
    private var passwordStrengthPublisher: AnyPublisher<PasswordStrength, Never> {
        $password
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { input in
                Navajo.strength(ofPassword: input)
            }
            .eraseToAnyPublisher()
    }
    
    private var isPasswordStrongEnoughPublisher: AnyPublisher<Bool, Never> {
        passwordStrengthPublisher
            .map { strength in
                switch strength {
                case .reasonable, .strong, .veryStrong:
                    return true
                default:
                    return false
                }
            }
            .eraseToAnyPublisher()
    }
    
    private var isPasswordValidPublisher: AnyPublisher<PasswordCheck, Never> {
        Publishers.CombineLatest3(
            isPasswordEmptyPublisher,
            arePasswordsEqualPublisher,
            isPasswordStrongEnoughPublisher
        )
            .map { passwordEmpty, passwordAreEqual, passwordIsStrongEnough in
                if passwordEmpty {
                    return .empty
                } else if !passwordAreEqual {
                    return .noMatch
                } else if !passwordIsStrongEnough {
                    return .notStrongEnough
                } else {
                    return .valid
                }
            }
            .eraseToAnyPublisher()
    }
    
    private var isFormValidPublisher: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest(isUsernameValidPublisher, isPasswordValidPublisher)
            .map { userNameIsValid, passwordIsValid in
                return userNameIsValid && (passwordIsValid == .valid)
            }
            .eraseToAnyPublisher()
    }
    
//    init() {
//        isFormValidPublisher
//            .receive(on: RunLoop.main)
//            .assign(to: \.isValid, on: self)
//            .store(in: &cancellableSet)
//    }
    
    init() {
        isUsernameValidPublisher
            .receive(on: RunLoop.main)
            .map { valid in
                valid ? "" : "User name must at least have 3 characters"
            }
            .assign(to: \.usernameMessage, on: self)
            .store(in: &cancellableSet)
        
        isPasswordValidPublisher
            .receive(on: RunLoop.main)
            .map { passwordCheck in
                switch passwordCheck {
                case .empty:
                    "Password must not be empty"
                case .noMatch:
                    "Password don't match"
                case .notStrongEnough:
                    "Password not strong enough"
                default:
                    ""
                }
                return true
            }
            .assign(to: \.isValid, on: self)
            .store(in: &cancellableSet)
        
        isFormValidPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.isValid, on: self)
            .store(in: &cancellableSet)
    }
}
