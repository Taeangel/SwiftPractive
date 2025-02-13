//
//  HomeView.swift
//  CoinApp
//
//  Created by song on 2022/11/18.
//

import SwiftUI

struct HomeView: View {
  @EnvironmentObject private var vm: HomeViewModel
  @State private var showPortfolio: Bool = true // animate right
  @State private var showPortfolioView: Bool = false //new sheet
  @State private var showSettingView: Bool = false
  
  @State private var showDetailView: Bool = false
  @State private var selectedCoin: CoinModel? = nil
  var body: some View {
    ZStack {
      Color.theme.background
        .ignoresSafeArea()
        .sheet(isPresented: $showPortfolioView) {
          PortfolioView()
            .environmentObject(vm)
        }
        .sheet(isPresented: $showSettingView) {
          SettingView()
        }
      
      VStack {
        
        homeHeader
        
        SearchBarView(seachText: $vm.searchText)
        
        columnTitles
        
        if !showPortfolio {
          allCoinsList
            .transition(.move(edge: .leading))
        }
        
        if showPortfolio {
          
          ZStack(alignment: .top) {
            if vm.portfolioCoins.isEmpty && vm.searchText.isEmpty {
              portfolioEmptyText
            } else {
              portfolioCoinsList
            }
          }
         .transition(.move(edge: .trailing))
        }
        
        Spacer(minLength: 0)
        
      }
    }
    .background(
    NavigationLink(destination: DetailLoadingView(coin: $selectedCoin),
                   isActive: $showDetailView,
                   label: { EmptyView() })
    )
  }
}

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      HomeView()
        .toolbar(.hidden)
    }
    .environmentObject(dev.homeVM)
  }
}

// ViewMethod
extension HomeView  {
  private func segue(coin: CoinModel) {
    self.selectedCoin = coin
    self.showDetailView.toggle()
  }
}


// Views
extension HomeView {
  private var homeHeader: some View {
    HStack {
      CircleButtonView(iconeName: showPortfolio ? "plus" : "info")
         .onTapGesture {
          if showPortfolio {
            showPortfolioView.toggle()
          } else {
            showSettingView.toggle()
          }
          
        }
        .background(
          CircleButtonAnimationView(animate: $showPortfolio)
        )
      Spacer()
      
      Text(showPortfolio ? "Portfolio" : "Live Prices")
        .font(.headline)
        .fontWeight(.heavy)
        .foregroundColor(Color.theme.accent)
      
      Spacer()
      CircleButtonView(iconeName: "chevron.right")
        .rotationEffect(Angle(degrees: showPortfolio ? 180 : 0))
        .onTapGesture {
          withAnimation(.spring()) {
            showPortfolio.toggle()
          }
        }
    }
    .padding(.horizontal)
  }
  
  private var portfolioEmptyText: some View {
    Text("you haven't added any coins to your portfolio yet! clicj the + button to get started 🤫")
      .font(.callout)
      .foregroundColor(Color.theme.accent)
      .fontWeight(.medium)
      .multilineTextAlignment(.center)
  }
  
  private var allCoinsList: some View {
    List {
      ForEach(vm.allCoins) { coin in
        CoinRowView(coin: coin, showHoldingColumn: false)
          .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 10))
          .onTapGesture {
            self.segue(coin: coin)
          }
      }
    }
    .listStyle(PlainListStyle())
  }
  
  private var portfolioCoinsList: some View {
    List {
      ForEach(vm.portfolioCoins) { coin in
        CoinRowView(coin: coin, showHoldingColumn: true)
          .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 10))
      }
    }
    .listStyle(PlainListStyle())
  }
  
  private var columnTitles: some View {
    HStack {
      
      HStack(spacing: 4) {
        Text("Coin")
        Image(systemName: "chevron.down")
          .opacity(vm.sortOption == .rank || vm.sortOption == .rankReversed ? 1.0 : 0.0)
          .rotationEffect(Angle(degrees: vm.sortOption == .rank ? 180 : 0))
      }
      .onTapGesture {
        withAnimation {
          vm.sortOption = vm.sortOption == .rank ? .rankReversed : .rank
        }
      }
      
      Spacer()
      
      if showPortfolio {
        HStack(spacing: 4) {
          Text("Holdings")
          Image(systemName: "chevron.down")
            .opacity(vm.sortOption == .holdings || vm.sortOption == .holdingsReversed ? 1.0 : 0.0)
            .rotationEffect(Angle(degrees: vm.sortOption == .holdings ? 180 : 0))
        }
          .frame(width: UIScreen.main.bounds.width / 3.5,
                 alignment: .trailing)
          .onTapGesture {
            withAnimation {
              vm.sortOption = vm.sortOption == .holdings ? .holdingsReversed : .holdings
             }
          }
      }
     
      Spacer()
      
      HStack(spacing: 4) {
        Text("Price")
        Image(systemName: "chevron.down")
          .opacity(vm.sortOption == .price || vm.sortOption == .priceReversed ? 1.0 : 0.0)
          .rotationEffect(Angle(degrees: vm.sortOption == .price ? 180 : 0))
      }
        .frame(width: UIScreen.main.bounds.width / 3.5, alignment: .trailing)
        .onTapGesture {
          withAnimation {
            vm.sortOption = vm.sortOption == .price ? .priceReversed : .price
          }
        }
      
      Button(action: {
        withAnimation {
          vm.reloadData()
        }
      },
             label: {
        Image(systemName: "goforward")
          .foregroundColor(Color.theme.accent)
      })
      .rotationEffect(Angle(degrees: vm.isLoading ? 360 : 0) ,anchor: .center)
      
    }
    .font(.caption)
    .foregroundColor(Color.theme.secondaryText)
    .padding(.horizontal)
  }
}
