//
//  ExploreView.swift
//  SwiftUIFirebasePractice
//
//  Created by song on 2023/01/24.
//

import SwiftUI

struct ExploreView: View {
  @ObservedObject var viewModel = ExploreViewModel()

  var body: some View {
      VStack {
        SearchBar(text: $viewModel.searchText)
          .padding()
        
        ScrollView {
          LazyVStack {
            ForEach(viewModel.searchableUsers) { user in
              NavigationLink(
                destination: {
                  ProfileView(user: user)
                },
                label: {
                  UserRowView(user: user)
                })
            }
          }
        }
      }
      .navigationTitle("Explore")
      .navigationBarTitleDisplayMode(.inline)
    
  }
}

struct ExploreView_Previews: PreviewProvider {
  static var previews: some View {
    ExploreView()
  }
}
