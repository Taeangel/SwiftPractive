//
//  HomeViewModel.swift
//  CoinApp
//
//  Created by song on 2022/11/18.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
  
  @Published var statistics: [StatisticModel] = []
  @Published var allCoins: [CoinModel] = []
  @Published var portfolioCoins: [CoinModel] = []
  @Published var searchText: String = ""
  @Published var isLoading: Bool = false
  @Published var sortOption: SortOption = .holdings
  
  private let coinDataService = CoinDataService()
  private let marketDataService = MarketDataService()
  private var cancellalbes = Set<AnyCancellable>()
  private let portfolioDataService = PortfolioDataService()
  
  enum SortOption {
    case rank, rankReversed, holdings, holdingsReversed, price, priceReversed
  }
  
  init() {
    addSubscribers()
  }
  
  func addSubscribers() {
    // updata allCoins
    $searchText
      .combineLatest(coinDataService.$allCoins, $sortOption)
      .map(filterAndSortCoins)
      .sink { [weak self] returnedCoins in
        guard let self = self else { return }
        self.allCoins = self.sortPortfolioCoinsIfNeed(coins: returnedCoins)
        
      }
      .store(in: &cancellalbes)
    
    // updates marketData
    marketDataService.$marketData
      .combineLatest($portfolioCoins)
      .map(mapGlobalMarketData)
      .sink { [weak self] stats in
        self?.statistics = stats
        self?.isLoading = false
      }
      .store(in: &cancellalbes)
    
    // updates portfolioCoins
    $allCoins
      .combineLatest(portfolioDataService.$saveEntities)
      .map(mapAllCoinsToPortfolioCoins)
      .sink { [weak self] returnedCoins in
        self?.portfolioCoins = returnedCoins
      }
      .store(in: &cancellalbes)
  }
  
  func updatePortfolio(coin: CoinModel, amount: Double) {
    portfolioDataService.updatePortfolio(coin: coin, amount: amount)
  }
  
  func reloadData() {
    isLoading = true
    coinDataService.getCoins()
    marketDataService.getCoins()
    HapticManager.notification(type: .success)
  }
  
  private func mapAllCoinsToPortfolioCoins(allCoins: [CoinModel], portfolioCoins: [PortfolioEntity]) -> [CoinModel] {
    allCoins
      .compactMap { coin -> CoinModel? in
        guard let entity = portfolioCoins.first(where: { $0.coinID == coin.id }) else {
          return nil
        }
        return coin.updateHoldings(amount: entity.amount)
      }
    
  }
    
    private func filterAndSortCoins(text: String, coins: [CoinModel], sort: SortOption) -> [CoinModel] {
      var filteredCoin = filterCoins(text: text, coins: coins)
      sortCoins(sort: sort, coins: &filteredCoin)
      return filteredCoin
    }
    
    
    private func filterCoins(text: String, coins: [CoinModel]) -> [CoinModel] {
      guard !text.isEmpty else {
        return coins
      }
      
      let lowercasedText = text.lowercased()
      
      let filteredCoins = coins.filter { coin -> Bool in
        return coin.name.lowercased().contains(lowercasedText) ||
        coin.symbol.lowercased().contains(lowercasedText) ||
        coin.id.lowercased().contains(lowercasedText)
      }
      
      return filteredCoins
    }
    
    private func sortCoins(sort: SortOption, coins: inout [CoinModel]){
      switch sort {
      case .rank:
        coins.sort { $0.rank < $1.rank }
      case .rankReversed:
        coins.sort { $0.rank > $1.rank }
      case .holdings:
        coins.sort { $0.rank < $1.rank }
      case .holdingsReversed:
        coins.sort { $0.rank > $1.rank }
      case .price:
        coins.sort { $0.currentPrice > $1.currentPrice }
      case .priceReversed:
        coins.sort { $0.currentPrice < $1.currentPrice }
      }
    }
    
    private func sortPortfolioCoinsIfNeed(coins: [CoinModel]) -> [CoinModel] {
      switch sortOption {
      case .holdings:
        return coins.sorted { $0.currentHoldingsValue > $1.currentHoldingsValue }
      case .holdingsReversed:
        return coins.sorted { $0.currentHoldingsValue < $1.currentHoldingsValue }
      default:
        return coins
      }
    }
    
    private func mapGlobalMarketData(data: MarketDataModel?, portfolioCoins: [CoinModel]) -> [StatisticModel] {
      var stats: [StatisticModel] = []
      
      guard let data = data else {
        return stats
      }
      
      let marketCap = StatisticModel(title: "Market Cap",
                                     value: data.marketCap,
                                     percentageChaange: data.marketCapChangePercentage24HUsd)
      
      let volume = StatisticModel(title: "24h Volume",
                                  value: data.volum)
      
      let btcDominance = StatisticModel(title: "BTC Dominance",
                                        value: data.btcDominance)
      
      let portfolioValue = portfolioCoins
        .map { $0.currentHoldingsValue }
        .reduce(0, +)
      
      let previousValue = portfolioCoins
        .map { coin -> Double in
          let currentValue = coin.currentHoldingsValue
          let percentChange = (coin.priceChangePercentage24H ?? 0) / 100
          let previousValue = currentValue / (1 + percentChange)
          return previousValue
        }
        .reduce(0, +)
      
      let percentagerChange = ((portfolioValue - previousValue) / previousValue) * 100
      
      
      let portfolio = StatisticModel(title: "Portfolio",
                                     value: portfolioValue.asCurrencyWith2Decimals(),
                                     percentageChaange: percentagerChange  )
      
      stats.append(contentsOf: [marketCap, volume, btcDominance, portfolio])
      
      return stats
    }
  }

