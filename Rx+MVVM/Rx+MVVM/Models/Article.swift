//
//  Artocle.swift
//  Rx+MVVM
//
//  Created by song on 2023/02/01.
//

import Foundation

struct ArticleResponse: Codable {
  let status: String
  let totalResults: Int
  let articles: [Article]
}

struct Article: Codable {
  let author: String?
  let title: String?
  let description: String?
  let url: String?
  let urlToImage: String?
  let publishedAt: String?
}
