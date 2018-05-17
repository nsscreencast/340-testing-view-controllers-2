//
//  CoinList.swift
//  CoinList
//
//  Created by Ben Scheirman on 2/23/18.
//  Copyright © 2018 Fickle Bits, LLC. All rights reserved.
//

import Foundation

struct CoinList : Decodable {
    var response: String
    var message: String
    var baseImageURL: URL
    var baseLinkURL: URL
    var data: Data
    
    enum CodingKeys : String, CodingKey {
        case response = "Response"
        case message = "Message"
        case baseImageURL = "BaseImageUrl"
        case baseLinkURL = "BaseLinkUrl"
        case data = "Data"
    }
    
    struct Data : Decodable {
        private struct Keys : CodingKey {
            var stringValue: String
            
            init?(stringValue: String) {
                self.stringValue = stringValue
            }
            
            var intValue: Int?
            
            init?(intValue: Int) {
                self.stringValue = String(intValue)
                self.intValue = intValue
            }
        }
        
        private var coins: [String : Coin] = [:]
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: Keys.self)
            for key in container.allKeys {
                coins[key.stringValue] = try container.decode(Coin.self, forKey: key)
            }
        }
        
        init() {
        }
        
        init(coins: [Coin]) {
            var coinLookup = [String : Coin]()
            for coin in coins {
                coinLookup[coin.symbol] = coin
            }
            self.coins = coinLookup
        }
        
        func allCoins() -> [Coin] {
            return Array(coins.values).sorted {a, b in
                return a.name < b.name
            }
        }
        
        subscript(_ key: String) -> Coin? {
            return coins[key]
        }
    }
    
    struct Coin : Decodable {
        let name: String
        let symbol: String
        let imagePath: String?
        
        enum CodingKeys : String, CodingKey {
            case name = "CoinName"
            case symbol = "Symbol"
            case imagePath = "ImageUrl"
        }
    }
}
