//
//  CoinListViewController.swift
//  CoinList
//
//  Created by Ben Scheirman on 4/30/18.
//  Copyright © 2018 Fickle Bits, LLC. All rights reserved.
//

import UIKit

final class CoinListViewController : UITableViewController, StoryboardInitializable {
    
    var cryptoCompareClient: CryptoCompareClient = CryptoCompareClient(session: URLSession.shared)
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        indicator.hidesWhenStopped = true
        
        indicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        
        return indicator
    }()
    
    var coins: [Coin]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.startAnimating()
        cryptoCompareClient.fetchCoinList { result in
            self.activityIndicator.stopAnimating()
            
            switch result {
            case .success(let coinList):
                self.coins = Coin.convert(coinList)
                self.tableView.reloadData()
            default:
                fatalError()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coins?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CoinListCell", for: indexPath) as! CoinListCell
        
        guard let coin = coins?[indexPath.row] else { return cell }
        
        cell.coinNameLabel.text = coin.name
        cell.coinSymbolLabel.text = coin.symbol
        
        
        return cell
    }
    
    
    
}

