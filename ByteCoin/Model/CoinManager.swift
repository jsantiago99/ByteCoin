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
    
    //creates delegate variable
    var delegate : CoinManagerDelegate?
    
    //perform API call
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
            task.resume() //starts task
        }
            
    }
    
    //want to return coin model
    //Note: We want optional coinmodel so that if there is an error we can return nil
    func parseJSON(_ data: Data) -> CoinModel? {
        let decoder = JSONDecoder() //decodes
        do {
            let decodedData = try decoder.decode(CoinData.self, from: data)
            let lastPrice = String(format: "%.2f", decodedData.rate) //formats rate so that we dont have long trailing numbers in the UI
            let idQuote = decodedData.asset_id_quote //assssed from the coindata pulled form api

            // initialize variables in coin model to be accessed
            let coin = CoinModel(assetIdQuote: idQuote, rate: lastPrice)
            
        
            return coin
        
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    
    
    
}
