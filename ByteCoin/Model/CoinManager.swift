//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdatePrice(_ coinManager: CoinManager, price: String, currency: String)
    func didFailWithError(with error: Error)
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = API_KEYS.API_KEY
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]

    var delegate: CoinManagerDelegate?
    
    func getCoinPrice(for currency: String) {
        let urlString = baseURL + "/\(currency)" + "?apikey=\(apiKey)"
        performRequest(with: urlString, for: currency)
    }
    
    func performRequest(with urlString: String, for currency: String) {
        guard let url = URL(string: urlString) else { return }
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url) { (data, response, error) in
            
            if let error = error {
                self.delegate?.didFailWithError(with: error)
                return
            }
            
            if let data = data {
                guard let bitcoinPrice = self.parseJSON(data) else { return }
                self.delegate?.didUpdatePrice(self, price: String(format: "%.2f", bitcoinPrice), currency: currency)
            }
        }
        
        dataTask.resume()
    }
    
    func parseJSON(_ data: Data) -> Double? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CoinData.self, from: data)
            return decodedData.rate
        } catch {
            self.delegate?.didFailWithError(with: error)
            return nil
        }
    }
}
