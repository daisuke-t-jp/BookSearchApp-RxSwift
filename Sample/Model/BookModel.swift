//
//  BookModel.swift
//  Sample
//
//  Created by Daisuke TONOSAKI on 2022/09/04.
//

import Foundation

struct BookResponseModel: Codable {
    let resultCount: Int
    let results: [BookModel]
}

struct BookModel: Codable {
    let trackViewUrl: URL?
    let artworkUrl100: URL?
    let trackName: String
    let description: String?
    let artistName: String
}
