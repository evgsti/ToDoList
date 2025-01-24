//
//  NetworkManager.swift
//  ToDoList
//
//  Created by Евгений on 22.01.2025.
//

import Foundation
import Network

final class NetworkManager {
    static let shared = NetworkManager()
    
    private enum Constants {
        static let api = "https://" + (Bundle.main.object(forInfoDictionaryKey: "API_URL") as! String)
        static let requestTimeout: TimeInterval = 15
        static let networkCheckTimeout: TimeInterval = 15
    }
    
    private enum NetworkError: LocalizedError {
        case noInternet
        case timeout
        case decodingError
        case noData
        case cancelled
        case connectionFailed
        
        var errorDescription: String? {
            switch self {
            case .noInternet:
                return "Не удалось получить данные. Проверьте интернет подключение"
            case .timeout:
                return "Превышено время ожидания запроса"
            case .decodingError:
                return "Не удалось обработать данные"
            case .noData:
                return "Не удалось получить данные"
            case .cancelled:
                return "Запрос был отменен"
            case .connectionFailed:
                return "Не удалось подключиться к серверу"
            }
        }
    }
    
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")
    private let lock = NSLock()
    private var currentTask: URLSessionDataTask?
    private var currentMonitor: NWPathMonitor?
    private var timeoutWorkItem: DispatchWorkItem?
    private var isCancelled = false
    private var hasCompletedCallback: Bool = false {
        willSet {
            lock.lock()
            do { lock.unlock() }
        }
    }
    
    private init() {
        print("API URL: \(Constants.api)")
    }
    
    func cancelFetch() {
        isCancelled = true
        currentTask?.cancel()
        currentTask = nil
        currentMonitor?.cancel()
        currentMonitor = nil
        timeoutWorkItem?.cancel()
        timeoutWorkItem = nil
    }
    
    func fetchData(completion: @escaping ([Task]?, Error?) -> Void) {
        isCancelled = false
        timeoutWorkItem?.cancel()
        hasCompletedCallback = false
        currentMonitor?.cancel()
        
        timeoutWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            if !self.isCancelled {
                self.currentTask?.cancel()
                self.currentTask = nil
                self.currentMonitor?.cancel()
                self.currentMonitor = nil
                self.hasCompletedCallback = false
                DispatchQueue.main.async {
                    completion(nil, NetworkError.timeout)
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.requestTimeout) {
            self.timeoutWorkItem?.perform()
        }
        
        isConnectedToNetwork { [weak self] isAvailable in
            guard let self = self else { return }
            guard !self.isCancelled else { return }
            
            if isAvailable {
                self.performNetworkRequest(completion: completion)
            } else {
                self.currentMonitor?.pathUpdateHandler = { [weak self] path in
                    guard let self = self else { return }
                    guard !self.hasCompletedCallback else { return }
                    
                    if path.status == .satisfied && !self.isCancelled {
                        self.hasCompletedCallback = true
                        DispatchQueue.main.async {
                            self.performNetworkRequest(completion: completion)
                        }
                    }
                }
            }
        }
    }
    
    private func performNetworkRequest(completion: @escaping ([Task]?, Error?) -> Void) {
        guard let url = URL(string: Constants.api) else { return }
        
        self.currentTask = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            self.timeoutWorkItem?.cancel()
            
            if let error = error as? NSError {
                if error.code == NSURLErrorCancelled {
                    return
                }
                
                if error.code == NSURLErrorCannotConnectToHost || 
                   error.code == NSURLErrorNotConnectedToInternet ||
                   error.code == NSURLErrorTimedOut {
                    DispatchQueue.main.async {
                        completion(nil, NetworkError.connectionFailed)
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    completion(nil, NetworkError.noData)
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse,
               !(200...299).contains(httpResponse.statusCode) {
                DispatchQueue.main.async {
                    completion(nil, NetworkError.connectionFailed)
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, NetworkError.noData)
                }
                return
            }
            
            do {
                let response = try JSONDecoder().decode(TodosResponse.self, from: data)
                let tasks = response.todos.map { taskJSON in
                    Task(description: taskJSON.todo, isCompleted: taskJSON.completed)
                }
                
                DispatchQueue.main.async {
                    completion(tasks, nil)
                }
            } catch let error {
                self.handleDecodingError(error: error, completion: completion)
            }
        }
        self.currentTask?.resume()
    }
    
    private func isConnectedToNetwork(completion: @escaping (Bool) -> Void) {
        currentMonitor?.cancel()
        
        let monitor = NWPathMonitor()
        currentMonitor = monitor
        hasCompletedCallback = false
        
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if !self.isCancelled && !self.hasCompletedCallback {
                    if path.status == .satisfied {
                        self.hasCompletedCallback = true
                        monitor.cancel()
                        completion(true)
                    }
                }
            }
        }
        
        monitor.start(queue: queue)
        
        if monitor.currentPath.status == .satisfied && !hasCompletedCallback && !isCancelled {
            hasCompletedCallback = true
            monitor.cancel()
            completion(true)
            return
        }
        
        if !hasCompletedCallback && !isCancelled {
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.networkCheckTimeout) { [weak self] in
                guard let self = self else { return }
                if !self.hasCompletedCallback && !self.isCancelled {
                    self.hasCompletedCallback = true
                    monitor.cancel()
                    completion(false)
                }
            }
        }
    }
    
    private func handleNetworkError(completion: @escaping ([Task]?, Error?) -> Void) {
        DispatchQueue.main.async {
            completion(nil, NetworkError.noInternet)
        }
    }
    
    private func handleDecodingError(error: Error, completion: @escaping ([Task]?, Error?) -> Void) {
        DispatchQueue.main.async {
            completion(nil, NetworkError.decodingError)
        }
        print("Error decoding JSON:", error)
    }
    
    deinit {
        currentMonitor?.cancel()
    }
}
