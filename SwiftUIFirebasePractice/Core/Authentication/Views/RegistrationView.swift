//
//  RegistrationView.swift
//  SwiftUIFirebasePractice
//
//  Created by song on 2023/01/26.
//

import SwiftUI

struct RegistrationView: View {
  @State private var email = ""
  @State private var username = ""
  @State private var fullname = ""
  @State private var password = ""
  @Environment(\.presentationMode) var presentationMode
  @EnvironmentObject var viewModel: AuthViewModel
  
  var body: some View {
    VStack {
      
      AuthenticationHeaderView(title1: "Get started.", title2: "Create your account")
      
      VStack(spacing: 40) {
        CustomInputField(imageName: "envelope",
                         placeholderText: "Email",
                         text: $email)
      
        CustomInputField(imageName: "person",
                         placeholderText: "Username",
                         text: $username)
      
        CustomInputField(imageName: "person",
                         placeholderText: "Full name",
                         text: $fullname)
      
        CustomInputField(imageName: "lock",
                         placeholderText: "password",
                         isSecureField: true,
                         text: $password)
      }
      .padding(32)
      
      Button {
        viewModel.register(withEmail: email,
                           password: password,
                           fullname: fullname,
                           username: username)
      } label: {
        Text("Sign In")
          .font(.headline)
          .foregroundColor(.white)
          .frame(width: 340, height: 50)
          .background(Color(.systemBlue))
          .clipShape(Capsule())
          .padding()
      }
      .shadow(color: .gray.opacity(0.5), radius: 10, x: 0, y: 0)
      .sheet(isPresented: $viewModel.didAuthenticateUser) {
        ProfilePhotoSelectorView()
      }
      
      Spacer()
      
      Button(action: {
        presentationMode.wrappedValue.dismiss()
      }, label: {
        HStack {
          Text("Already have an account?")
            .font(.footnote)
          
          Text("Sign In")
            .font(.footnote)
            .fontWeight(.semibold)
        }
      })
      .padding(.bottom, 32)
    }
    .ignoresSafeArea()
  }
}

struct RegistrationView_Previews: PreviewProvider {
  static var previews: some View {
    RegistrationView()
  }
}
