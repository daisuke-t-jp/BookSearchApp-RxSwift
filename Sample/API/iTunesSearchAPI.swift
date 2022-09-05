//
//  iTunesSearchAPI.swift
//  Sample
//
//  Created by Daisuke TONOSAKI on 2022/09/03.
//

import Foundation

import Moya

private extension String {
    var urlEscaped: String {
        addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    var utf8Encoded: Data { Data(self.utf8) }
}

// `iTunes` という名前をそのまま使用したいため、 Lint ルールを一時的に無効にする
// swiftlint:disable type_name
enum iTuneSearchAPI {
    case searchBook(name: String, limit: Int = 20)
}
// swiftlint:enable type_name

// iTunes Search API について
// https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/iTuneSearchAPI/index.html
extension iTuneSearchAPI: TargetType {
    var baseURL: URL { return URL(string: "https://itunes.apple.com/search")! }
    var path: String {
        switch self {
        case .searchBook:
            return ""
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        switch self {
        case .searchBook(let name, let limit):
            return .requestParameters(
                parameters: [
                    "term": name,
                    "attribute": "artistTerm",
                    "entity": "ebook",
                    "country": "JP",
                    "lang": "ja_jp",
                    "limit": limit
                ],
                encoding: URLEncoding.queryString
            )
        }
    }
    
    var headers: [String: String]? { return nil }
    
    var sampleData: Data {
        let path = Bundle.main.path(forResource: "books", ofType: "json")!
        return FileHandle(forReadingAtPath: path)!.readDataToEndOfFile()
    }
}
