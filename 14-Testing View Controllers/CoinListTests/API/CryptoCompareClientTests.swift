//
//  CryptoCompareClientTests.swift
//  CoinListTests
//
//  Created by Ben Scheirman on 2/23/18.
//  Copyright © 2018 Fickle Bits, LLC. All rights reserved.
//

import XCTest
import OHHTTPStubs
@testable import CoinList

extension CryptoCompareClient {
    func testFetchCoinListVerifyingResponse(file: StaticString = #file, line: UInt = #line, resultBlock: @escaping (ApiResult<CoinList>) -> Void) {
        
        let exp = XCTestExpectation(description: "Received coin list response")
        fetchCoinList { result in
            exp.fulfill()
            resultBlock(result)
        }
        
        let result = XCTWaiter.wait(for: [exp], timeout: 3.0)
        switch result {
        case .timedOut:
            XCTFail("Timed out waiting for coin list response", file: file, line: line)
        default:
            break
        }
    }
    
    func testFetchCoinListSuccessfully(file: StaticString = #file, line: UInt = #line, coinListBlock: @escaping (CoinList) -> Void) {
        testFetchCoinListVerifyingResponse { (result) in
            switch result {
            case .success(let coinList):
                XCTAssertEqual(coinList.response, "Success", file: file, line: line)
                coinListBlock(coinList)
            case .failure(let error):
                XCTFail("Error in coin list request: \(error)", file: file, line: line)
            }
        }
    }
}

class CryptoCompareClientTests : XCTestCase {
    var client: CryptoCompareClient!
    
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        
        OHHTTPStubs.onStubMissing { request in
            XCTFail("Missing stub for \(request)")
        }
        
        FixtureLoader.stubCoinListResponse()
        
        client = CryptoCompareClient(session: URLSession.shared)
    }
    
    override func tearDown() {
        super.tearDown()
        FixtureLoader.reset()
    }
    
    func testFetchesCoinListResponse() {
        client.testFetchCoinListSuccessfully { (coinList) in
            XCTAssertEqual(coinList.baseLinkURL, URL(string: "https://www.cryptocompare.com")!)
        }
    }
    
    func testCoinListResponseReturnsServerError() {
        FixtureLoader.stubCoinListReturningError()
        
        client.testFetchCoinListVerifyingResponse { result in
            switch result {
            case .success(_):
                XCTFail("Should have returned an error")
                
            case .failure(let error):
                
                if case ApiError.serverError(let status) = error {
                    XCTAssertEqual(status, 500)
                } else {
                    XCTFail("Expected a server error but got \(error)")
                }
            }
        }
    }
    
    func testCallsBackOnMainQueue() {
        client.testFetchCoinListVerifyingResponse { result in
            XCTAssert(Thread.isMainThread, "Expected to be called back on the main queue")
        }
    }
    
    func testCoinListRetrievesCoins() {
        client.testFetchCoinListSuccessfully { coinList in
            self.assertContainsCoin(name: "Bitcoin", symbol: "BTC", coinList: coinList)
        }
    }
    
    private func assertContainsCoin(name: String, symbol: String, coinList: CoinList, file: StaticString = #file, line: UInt = #line) {
        
        XCTAssertGreaterThan(coinList.data.allCoins().count, 1, "Coin list was empty", file: file, line: line)
        
        let coin = coinList.data[symbol]
        XCTAssertNotNil(coin, "Could not find a coin in the list with symbol \(symbol)", file: file, line: line)
        XCTAssertEqual(coin?.symbol, symbol, "Symbol incorrect", file: file, line: line)
        XCTAssertEqual(coin?.name, name, "Name is incorret", file: file, line: line)
        XCTAssertNotNil(coin?.imagePath, "Did not contain an image", file: file, line: line)
    }
    
    func testConnectionErrorIsReturned() {
        FixtureLoader.stubCoinListWithConnectionError(code: 999)
        client.testFetchCoinListVerifyingResponse { result in
            switch result {
            case .success(_):
                XCTFail("Should have failed")
                
            case .failure(let error):
                switch error {
                case .connectionError(let e):
                    XCTAssertEqual( (e as NSError).code, 999)
                    
                default:
                    XCTFail("Expected connection error, but got: \(error)")
                }
            }
        }
    }
    
    func testCatchesInvalidJSONOn200Response() {
        FixtureLoader.stubCoinListWithInvalidJSON()
        client.testFetchCoinListVerifyingResponse { result in
            switch result {
            case .success(_):
                XCTFail("Should have failed")
                
            case .failure(let error):
                switch error {
                case .responseFormatInvalid(let body):
                    XCTAssertEqual(body, "this is not valid json")
                    
                default:
                    XCTFail("Expected connection error, but got: \(error)")
                }
            }
        }
    }
    
    func testCatchesInvalidJSONWithNoBody() {
        let invalidData = Data(bytes: [UInt8.max])
        FixtureLoader.stubCoinListWithData(invalidData)
        client.testFetchCoinListVerifyingResponse { result in
            switch result {
            case .success(_):
                XCTFail("Should have failed")
                
            case .failure(let error):
                switch error {
                case .responseFormatInvalid(let body):
                    XCTAssertEqual(body, "<no body>")
                    
                default:
                    XCTFail("Expected connection error, but got: \(error)")
                }
            }
        }
    }
}
