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

struct StatefulPreviewWrapper<Value>: View {
    @State var value: Value
    var content: (Binding<Value>) -> AnyView

    init(_ value: Value, content: @escaping (Binding<Value>) -> AnyView) {
        _value = State(initialValue: value)
        self.content = content
    }

    var body: some View {
        content($value)
    }
}

extension StatefulPreviewWrapper where Value == Bool {
    init(_ value: Value, content: @escaping (Binding<Value>) -> some View) {
        _value = State(initialValue: value)
        self.content = { AnyView(content($0)) }
    }
}

#Preview {
    StatefulPreviewWrapper(true) { isPresented in
        PopUpChangeInfo(isPresented: isPresented, onConfirm: { _ in }, isPassword: false, title: "Change your Email")
    }
}
