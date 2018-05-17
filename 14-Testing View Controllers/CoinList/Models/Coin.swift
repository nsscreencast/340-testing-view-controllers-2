//
//  Coin.swift
//  CoinList
//
//  Created by Ben Scheirman on 5/2/18.
//  Copyright © 2018 Fickle Bits, LLC. All rights reserved.
//

import Foundation

struct Coin {
    let name: String
    let symbol: String
    let imageURL: URL?
    
    static func convert(_ coinList: CoinList) -> [Coin] {
        let baseImageURL = coinList.baseImageURL
        return coinList.data.allCoins().map { coinListCoin in
            let imageURL = coinListCoin.imagePath.flatMap { baseImageURL.appendingPathComponent($0)  }
            return Coin(name: coinListCoin.name,
                        symbol: coinListCoin.symbol,
                        imageURL: imageURL)
        }
    }
}
