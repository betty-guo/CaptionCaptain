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

func getCaption(for request: getCaptionRequest, completion: @escaping ((Result<String, Error>) -> Void)) {


    do {
        let jsonData = try JSONEncoder().encode(request)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        print(jsonString)

        var urlRequest = URLRequest(url: URL(string: "https://cc-backend-iq3v3yeavq-uk.a.run.app/caption")!)
        urlRequest.httpBody = jsonData
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(Result.failure(error))
                return
            }

            guard let data = data else { return }

            if let value = String(bytes: data, encoding: .utf8){
                completion(Result.success(value))
            } else {
                return
            }
        }
        task.resume()
    } catch {
        print(error)
    }
}
