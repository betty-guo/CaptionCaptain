//
//  URLService.swift
//  UglySweaterApp
//
//  Created by Cristian Palage on 2021-01-16.
//

import Foundation

struct getCaptionRequest: Codable {
    let words: [String]
}

struct getCaptionResponse: Codable {
    let caption: String
}

func getCaption(for request: getCaptionRequest, completion: @escaping ((Result<getCaptionResponse, Error>) -> Void)) {


    do {
        let jsonData = try JSONEncoder().encode(request)
        //let jsonString = String(data: jsonData, encoding: .utf8)!

        var urlRequest = URLRequest(url: URL(string: "https://endpoint")!)
        urlRequest.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(Result.failure(error))
                return
            }

            guard let data = data else { return }

            do {
                let decoder = JSONDecoder()

                let response = try decoder.decode(getCaptionResponse.self, from: data)
                print(response)
                completion(Result.success(response))
            } catch let error {
                print(error.localizedDescription)
                return
            }
        }
        task.resume()
    } catch {
        print(error)
    }
}
