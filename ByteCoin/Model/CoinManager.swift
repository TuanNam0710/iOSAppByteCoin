//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdateRate(_ coinManager: CoinManager, rate: Double)
    func didFailWithError(error: Error)

}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "839EB542-3413-4463-B3B0-C7B90CF2021F"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]

    var delegate: CoinManagerDelegate?
    
    func getCoinPrice(for currency: String) {
        let urlString = "\(baseURL)/\(currency)?apiKey=\(apiKey)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error!)
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let rate = self.parseJSON(coinData: safeData) {
                        self.delegate?.didUpdateRate(self, rate: rate)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(coinData: Data) -> Double?{
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CoinData.self, from: coinData)
            let rate = decodedData.rate
            return rate
        } catch {
            self.delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
