//
//  Albums.swift
//  GPhotos
//
//  Created by Deivi Taka on 26.08.19.
//

import Foundation
import Moya

public class Albums {
    
    public init() {}
    
    // MARK: List
    private struct List {
        var request = AlbumsList.Request()
        var page = 0
    }
    private var currentList = List()
    
}

// MARK:- List
public extension Albums {
    
    func list(completion: @escaping (([Album])->())) {
        if currentList.page > 0 && currentList.request.pageToken == nil {
            log.d("Reached end of albums")
            completion([])
            return
        }
        
        if !GPhotos.checkScopes(with: [.readAndAppend, .readOnly, .readDevData]) {
            completion([])
            return
        }
        
        GPhotos.refreshTokenIfNeeded() {
            GPhotosApi.albums.request(.list(req: self.currentList.request)) { (result) in
                switch result {
                case let .success(res):
                    guard let dict = GPhotosApi.handle(response: res) else {
                        completion([])
                        return
                    }
                    let listRes = AlbumsList.Response(JSON: dict)
                    self.currentList.request.pageToken = listRes?.nextPageToken
                    self.currentList.page += 1
                    completion(listRes?.albums ?? [])
                    
                case let .failure(error):
                    GPhotosApi.handle(error: error)
                    completion([])
                }
            }
        }
    }
    
    func reloadList(completion: @escaping (([Album])->())) {
        currentList = List()
        list(completion: completion)
    }
    
}

// MARK:- Get
public extension Albums {

    func get(id: String, completion: @escaping ((Album?)->())) {
        GPhotos.refreshTokenIfNeeded() {
            GPhotosApi.albums.request(.get(id: id)) { (result) in
                switch result {
                case let .success(res):
                    guard let dict = GPhotosApi.handle(response: res) else {
                        completion(nil)
                        return
                    }
                    let item = Album(JSON: dict)
                    completion(item)

                case let .failure(error):
                    GPhotosApi.handle(error: error)
                    completion(nil)
                }
            }
        }
    }

}
