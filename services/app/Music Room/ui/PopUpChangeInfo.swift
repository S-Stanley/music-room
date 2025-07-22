//
//  PopUpChangeInfo.swift
//  Music Room
//
//  Created by Nathan Bechon on 13/03/2025.
//

import SwiftUI

struct PopUpChangeInfo: View {
    @Binding var isPresented: Bool
    @State private var newPassword: String = ""
    var onConfirm: (String) -> Void
    var isPassword: Bool
    var title: String

    var body: some View {
        ZStack {
         
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
         
            VStack(spacing: 20) {
                if (isPassword) {
                    SecureField(title, text: $newPassword)
                        .onChange(of: newPassword) {
                                    newPassword = newPassword.lowercased()
                                }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                else {
                    TextField(title, text: $newPassword)
                        .onChange(of: newPassword) {
                                    newPassword = newPassword.lowercased()
                                }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                
                
                HStack(spacing: 20) {
                   
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Cancel")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .foregroundColor(.black)
                            .cornerRadius(8)
                    }

                    
                    Button(action: {
                        onConfirm(newPassword)
                        isPresented = false
                    }) {
                        Text("Confirm")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding(.bottom, 10)
            }
            .padding()
            .frame(maxWidth: 300)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(radius: 10)
        }
    }
}

struct PopUpChangeName: View {
    @Binding var isPresented: Bool
    @State private var newName: String = ""
    var onConfirm: (String) -> Void
    var title: String

    var body: some View {
        ZStack {
         
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
         
            VStack(spacing: 20) {
                TextField(title, text: $newName)
                    .onChange(of: newName) { value in
                        newName = value
                            .filter { $0.isLetter }
                            .prefix(10)
                            .lowercased()               
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)

                
                
                
                HStack(spacing: 20) {
                   
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Cancel")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .foregroundColor(.black)
                            .cornerRadius(8)
                    }

                    
                    Button(action: {
                        onConfirm(newName)
                        isPresented = false
                    }) {
                        Text("Confirm")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding(.bottom, 10)
            }
            .padding()
            .frame(maxWidth: 300)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(radius: 10)
        }
    }
}

struct PopUpChangeEmail: View {
    @Binding var isPresented: Bool
    @State private var newEmail: String = ""
    var onConfirm: (String) -> Void
    var title: String

    // Validation de l'adresse e-mail
    var isValidEmail: Bool {
        let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: newEmail)
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                TextField(title, text: $newEmail)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)

                if !newEmail.isEmpty && !isValidEmail {
                    Text("Adresse e-mail invalide")
                        .font(.caption)
                        .foregroundColor(.red)
                }

                HStack(spacing: 20) {
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Cancel")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .foregroundColor(.black)
                            .cornerRadius(8)
                    }

                    Button(action: {
                        onConfirm(newEmail)
                        isPresented = false
                    }) {
                        Text("Confirm")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isValidEmail ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(!isValidEmail) // Désactive si email invalide
                }
                .padding(.bottom, 10)
            }
            .padding()
            .frame(maxWidth: 300)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(radius: 10)
        }
    }
}
