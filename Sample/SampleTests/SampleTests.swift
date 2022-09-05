//
//  SampleTests.swift
//  SampleTests
//
//  Created by Daisuke TONOSAKI on 2022/09/01.
//

import XCTest
@testable import Sample

import Moya

class SampleTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    private var provider: MoyaProvider<iTuneSearchAPI>!
    
    // Moya の sampleData を使ったテスト
    func testSampleData() throws {
        provider = MoyaProvider<iTuneSearchAPI>(stubClosure: MoyaProvider.immediatelyStub)
        provider.request(.searchBook(name: "")) { result in
            switch result {
            case let .success(moyaResponse):
                let bookResponse: BookResponseModel = try! JSONDecoder().decode(BookResponseModel.self, from: moyaResponse.data)
                XCTAssertEqual(bookResponse.resultCount, 3)
            default:
                XCTFail()
            }
        }
    }
    
    // ステータスコード400のテスト
    func testStatusCode400() throws {
        let endpointClosure = { (target: iTuneSearchAPI) -> Endpoint in
            return Endpoint(url: URL(target: target).absoluteString,
                            sampleResponseClosure: { .networkResponse(400, Data()) },
                            method: target.method,
                            task: target.task,
                            httpHeaderFields: target.headers)
        }
        provider = MoyaProvider<iTuneSearchAPI>(endpointClosure: endpointClosure,
                                                stubClosure: MoyaProvider.immediatelyStub)
        provider.request(.searchBook(name: "")) { result in
            switch result {
            case let .success(moyaResponse):
                XCTAssertEqual(moyaResponse.statusCode, 400)
            default:
                XCTFail()
            }
        }
    }
    
    // 存在する著者
    func testExist() throws {
        let artistName: String = "村上春樹"
        let expectation = self.expectation(description: "testExist")
        
        provider = MoyaProvider<iTuneSearchAPI>()
        provider.request(.searchBook(name: artistName)) { result in
            switch result {
            case let .success(moyaResponse):
                let bookResponse: BookResponseModel = try! JSONDecoder().decode(BookResponseModel.self, from: moyaResponse.data)
                XCTAssertGreaterThan(bookResponse.resultCount, 0)

                let book: BookModel = bookResponse.results.first!
                XCTAssertTrue(book.artistName.contains(artistName))
                XCTAssertFalse(book.trackName.isEmpty)
                
                expectation.fulfill()
            default:
                XCTFail()
            }
        }
        
        wait(for: [expectation], timeout: 5)
    }
    
    // 存在しない著者
    func testNonExist() {
        let artistName: String = "村上樹"
        let expectation = self.expectation(description: "testNonExist")
        
        provider = MoyaProvider<iTuneSearchAPI>()
        provider.request(.searchBook(name: artistName)) { result in
            switch result {
            case let .success(moyaResponse):
                let bookResponse: BookResponseModel = try! JSONDecoder().decode(BookResponseModel.self, from: moyaResponse.data)
                XCTAssertEqual(bookResponse.resultCount, 0)
                
                expectation.fulfill()
            default:
                XCTFail()
            }
        }
        
        wait(for: [expectation], timeout: 5)
    }
    
    // 検索結果数1
    func testLimit1() throws {
        let artistName: String = "村上春樹"
        let expectation = self.expectation(description: "testLimit1")
        
        provider = MoyaProvider<iTuneSearchAPI>()
        provider.request(.searchBook(name: artistName, limit: 1)) { result in
            switch result {
            case let .success(moyaResponse):
                let bookResponse: BookResponseModel = try! JSONDecoder().decode(BookResponseModel.self, from: moyaResponse.data)
                XCTAssertEqual(bookResponse.resultCount, 1)
                
                expectation.fulfill()
            default:
                XCTFail()
            }
        }
        
        wait(for: [expectation], timeout: 5)
    }
    
    // 検索結果数200
    func testLimit200() throws {
        let artistName: String = "村上春樹"
        let expectation = self.expectation(description: "testLimit200")
        
        provider = MoyaProvider<iTuneSearchAPI>()
        provider.request(.searchBook(name: artistName, limit: 200)) { result in
            switch result {
            case let .success(moyaResponse):
                let bookResponse: BookResponseModel = try! JSONDecoder().decode(BookResponseModel.self, from: moyaResponse.data)
                XCTAssertEqual(bookResponse.resultCount, 200)
                
                expectation.fulfill()
            default:
                XCTFail()
            }
        }
        
        wait(for: [expectation], timeout: 5)
    }
    
    // 著者名を絞った形にすると検索結果数が減るか
    func testArtistNameFilter() throws {
        let expectation = self.expectation(description: "testArtistNameFilter")
        let expectation2 = self.expectation(description: "testArtistNameFilter2")
        var resultCount: Int = 0
        var resultCount2: Int = 0
        
        // 具体的な著者名で検索
        provider = MoyaProvider<iTuneSearchAPI>()
        provider.request(.searchBook(name: "Thomas Pynchon", limit: 200)) { result in
            switch result {
            case let .success(moyaResponse):
                let bookResponse: BookResponseModel = try! JSONDecoder().decode(BookResponseModel.self, from: moyaResponse.data)
                resultCount = bookResponse.resultCount
                expectation.fulfill()
            default:
                XCTFail()
            }
        }
        wait(for: [expectation], timeout: 5)
        
        // あいまいな著者名で検索
        provider.request(.searchBook(name: "Thomas", limit: 200)) { result in
            switch result {
            case let .success(moyaResponse):
                let bookResponse: BookResponseModel = try! JSONDecoder().decode(BookResponseModel.self, from: moyaResponse.data)
                resultCount2 = bookResponse.resultCount
                expectation2.fulfill()
            default:
                XCTFail()
            }
        }
        wait(for: [expectation2], timeout: 5)
        
        // あいまいな著者名で検索した方が、検索結果数は多い
        XCTAssertGreaterThan(resultCount2, resultCount)
    }
}
