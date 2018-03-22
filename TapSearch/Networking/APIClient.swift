//
//  APIClient.swift
//  TapSearch
//
//

import Foundation

//Borrowed heavily from James Rochabrun / Natascha Murashev talks on protocol oriented network layers.
protocol APIClient {
  var session: URLSession { get }
  func fetchArray<T: Decodable>(with request: URLRequest, decode: @escaping (Decodable) -> T?, completion: @escaping (Result<[T], APIError>) -> Void)
}

extension APIClient {
  typealias JSONArrayTaskCompletionHandler = ([Decodable]?, APIError?) -> Void
  
  private func decodingMultipleObjectsFromDocumentTask<T: Decodable>(with request: URLRequest, decodingType: T.Type, completionHandler completion: @escaping JSONArrayTaskCompletionHandler) -> URLSessionDataTask {
    
    //Creates a task object using your Decodable struct. This one accounts for parsing lines as well
    let task = session.dataTask(with: request) { data, response, error in
      guard let httpResponse = response as? HTTPURLResponse else {
        completion(nil, APIError.dataTaskError )
        return
      }
      guard httpResponse.statusCode == 200 else {
        completion(nil, APIError.responseDataNil )
        return
      }
      guard let data = data  else {
        completion(nil, APIError.responseDataNil )
        return
      }
      guard let stringData = String(data: data, encoding: .utf8) else {
        completion(nil, APIError.stringDecodingError)

        return
      }
      
      //Split objects into lines to be decoded
      var stringJSONObjects = [String]()
      var decodedObjects = [T]()
      
      stringData.enumerateLines { stringJSONObject, _ in
        stringJSONObjects.append(stringJSONObject)
      }
      
      for JSONobject in stringJSONObjects {
        do {
          //Attempts to decode data based on the input decodable struct
          let jsonDecoder = JSONDecoder()
          let genericModel = try jsonDecoder.decode(decodingType, from: JSONobject.data(using: .utf8)!)
          decodedObjects.append(genericModel)
        } catch {
          completion(nil, APIError.missingRequiredValues )
        }
      }
      //SUCCESS!
      completion(decodedObjects, nil)
    }
    return task
  }
  
  
  func fetchArray<T: Decodable>(with request: URLRequest, decode: @escaping (Decodable) -> T?, completion: @escaping (Result<[T], APIError>) -> Void) {
    
    //Takes the task from above and runs it, handles case of either success or failure
    let task = decodingMultipleObjectsFromDocumentTask(with: request, decodingType: T.self) { (jsonArray , error) in
      
      
      DispatchQueue.main.async {
        guard let jsonArray = jsonArray else {
          if let error = error {
            completion(Result.failure(error))
          }
          return
        }
        
        var decodedObjectArray = [T]()
        for item in jsonArray {
          if let value = decode(item) {
            decodedObjectArray.append(value)
          } else {
            completion(Result.failure(APIError.stringDecodingError))
          }
        }
        completion(Result.success(decodedObjectArray))
      }
    }
    task.resume()
  }
}
