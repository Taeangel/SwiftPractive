//
//  FeedView.swift
//  SwiftUIFirebasePractice
//
//  Created by song on 2023/01/24.
//

import SwiftUI

struct FeedView: View {
  @State private var showNewTweetView = false
  @ObservedObject var viewModel = FeedViewModel()
  var body: some View {
    ZStack(alignment: .bottomTrailing) {
      ScrollView {
        LazyVStack {
          
          ForEach(viewModel.tweets) { tweet in
            
            TweetRowView(tweet: tweet)
          }
        }
      }
      
      Button(action: {
        showNewTweetView.toggle()
      },
             label: {
        Image("tweet")
          .resizable()
          .renderingMode(.template)
          .frame(width: 28, height: 28)
          .padding()
      })
      .background(Color(.systemBlue))
      .foregroundColor(.white)
      .clipShape(Circle())
      .padding()
      .fullScreenCover(isPresented: $showNewTweetView) {
        NewTweetView()
      }
    }
    .navigationBarTitleDisplayMode(.inline)
  }
}

struct FeedView_Previews: PreviewProvider {
  static var previews: some View {
    FeedView()
  }
}
