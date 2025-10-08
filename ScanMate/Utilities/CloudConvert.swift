//
//  ConvertAPI.swift
//  ScanMate
//
//  Created by Vrushti Nilesh Shah on 4/23/25.
//

import Foundation

struct ConvertAPI {
    private static let apiKey = "secret_A8S4bNLC0yKd8x9E"

    // Existing method for Office files (doc, ppt, xls to PDF)
    static func convertToPDF(_ url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        let fileExtension = url.pathExtension.lowercased()
        let baseURL: String

        switch fileExtension {
        case "ppt":
            baseURL = "https://v2.convertapi.com/convert/ppt/to/pdf"
        case "pptx":
            baseURL = "https://v2.convertapi.com/convert/pptx/to/pdf"
        case "doc", "docx":
            baseURL = "https://v2.convertapi.com/convert/doc/to/pdf"
        case "xls", "xlsx":
            baseURL = "https://v2.convertapi.com/convert/xls/to/pdf"
        default:
            completion(.failure(NSError(domain: "Unsupported Format", code: 400,
                                        userInfo: [NSLocalizedDescriptionKey: "File type not supported"])))
            return
        }

        performConversion(fileURLs: [url], baseURL: baseURL, completion: completion)
    }

    // New method specifically for converting multiple images to PDF
    static func convertImagesToPDF(imageURLs: [URL], completion: @escaping (Result<URL, Error>) -> Void) {
        let baseURL = "https://v2.convertapi.com/convert/jpg/to/pdf"
        performConversion(fileURLs: imageURLs, baseURL: baseURL, completion: completion)
    }

    // MARK: - Shared Helper Method (Reusable)
    private static func performConversion(fileURLs: [URL], baseURL: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let boundary = UUID().uuidString
        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        for fileURL in fileURLs {
            do {
                let fileData = try Data(contentsOf: fileURL)
                let filename = fileURL.lastPathComponent
                let mimeType = mimeTypeForFile(at: fileURL)

                // Corrected: Using 'File' key without indexing
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"File\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
                body.append(fileData)
                body.append("\r\n".data(using: .utf8)!)
            } catch {
                completion(.failure(error))
                return
            }
        }

        // Parameters
        let params = [
            "StoreFile": "true",
            "CompressPDF": "false",
            "Pdfa": "false"
        ]

        for (key, value) in params {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        // Upload Task
        let uploadTask = URLSession.shared.uploadTask(with: request, from: body) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode),
                  let data = data else {
                completion(.failure(NSError(domain: "API Error", code: (response as? HTTPURLResponse)?.statusCode ?? 500,
                                            userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }

            // Proper JSON response handling
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let files = json["Files"] as? [[String: Any]],
                   let firstFile = files.first,
                   let fileUrlString = firstFile["Url"] as? String,
                   let fileUrl = URL(string: fileUrlString) {

                    downloadConvertedFile(url: fileUrl, completion: completion)
                } else {
                    let responseString = String(data: data, encoding: .utf8)
                    print("Invalid API response: \(responseString ?? "No readable response")")
                    completion(.failure(NSError(domain: "API Error", code: 400,
                                                userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])))
                }
            } catch {
                completion(.failure(error))
            }
        }

        uploadTask.resume()
    }

    // Helper: Download the converted PDF file
    private static func downloadConvertedFile(url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("pdf")

        URLSession.shared.downloadTask(with: url) { localUrl, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let localUrl = localUrl else {
                completion(.failure(NSError(domain: "DownloadError", code: 404,
                                            userInfo: [NSLocalizedDescriptionKey: "No temporary file downloaded"])))
                return
            }

            do {
                try FileManager.default.moveItem(at: localUrl, to: tempURL)
                completion(.success(tempURL))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // Helper: Determine MIME type based on file extension
    private static func mimeTypeForFile(at url: URL) -> String {
        switch url.pathExtension.lowercased() {
        case "jpg", "jpeg":
            return "image/jpeg"
        case "png":
            return "image/png"
        case "doc", "docx":
            return "application/msword"
        case "xls", "xlsx":
            return "application/vnd.ms-excel"
        case "ppt", "pptx":
            return "application/vnd.ms-powerpoint"
        case "pdf":
            return "application/pdf"
        default:
            return "application/octet-stream"
        }
    }
}
