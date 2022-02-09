//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didFailWithError(error: Error)
    func didUpdateCoin(_ coinManager: CoinManager, coin: CoinModel )
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "0ED8BCFC-CCC0-411B-81AA-D8EAADD0E5CA"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]

    func fetchCoinPrice(selection: String) {
        let urlString = "\(baseURL)/\(selection)?apikey=\(apiKey)"
        
        performRequest(with: urlString)
    }
    
    var delegate : CoinManagerDelegate?
    
    func performRequest(with urlString: String) {
        //Make URL, create session, create the task, then start task
        
        if let url = URL(string: urlString) {
            
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url) {data, response, error in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                } else {
                    if let safeData = data {
                        if let coin = self.parseJSON(safeData) {
                            self.delegate?.didUpdateCoin(self, coin: coin)
                        }
                    }
                }
            }
            task.resume()
        }
            
    }
    
    func parseJSON(_ data: Data) -> CoinModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CoinData.self, from: data)
            let lastPrice = String(format: "%.2f", decodedData.rate)
            let idQuote = decodedData.asset_id_quote

            
    
            let coin = CoinModel(assetIdQuote: idQuote, rate: lastPrice)
            
            return coin
        
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    
    
    
}
