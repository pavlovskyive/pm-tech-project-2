//
//  TextAttachementCache.swift
//  Project-2
//
//  Created by Ilya Senchukov on 23.02.2021.
//

import UIKit

class DefaultTextAttachmentProcessor: TextAttachmentPreloader {

    let networkService = NetworkService(baseURLString: "https://i.stack.imgur.com")

    func preloadAttachments(attrString: NSMutableAttributedString) -> NSMutableAttributedString {
        let fullLengthRange = NSRange(location: 0, length: attrString.length)

        attrString.enumerateAttributes(
            in: fullLengthRange,
            options: .reverse) { (attrDict, range, _) in

            if let attachement = attrDict[.attachment] as? NSTextAttachment {
                if let fileWrapper = attachement.fileWrapper, let imageName = fileWrapper.preferredFilename {
                    let workItem = fetchImage(imageName: imageName) { [weak self] res in
                        guard let self = self, let image = try? res.get() else {
                            return
                        }

                        guard let imageAttachmentAttrString = self.getBase64ImageAttrString(image: image) else {
                            return
                        }

                        attrString.replaceCharacters(in: range, with: imageAttachmentAttrString)
                    }

                    DispatchQueue.global().asyncAndWait(execute: workItem)
                }
            }
        }

        return attrString
    }

    func fetchImage(
        imageName: String,
        completion: @escaping (Result<UIImage, NetworkError>) -> Void) -> DispatchWorkItem {

        return DispatchWorkItem { [weak self] in
            self?.networkService.getRequest(pathComponent: "/\(imageName)") { res in
                switch res {
                case .failure(let error):
                    completion(.failure(error))

                case .success(let data):
                    guard let image = UIImage(data: data) else {
                        completion(.failure(.badData))
                        return
                    }

                    completion(.success(image))
                }
            }
        }
    }
}

private extension DefaultTextAttachmentProcessor {
    func getBase64ImageAttrString(image: UIImage) -> NSAttributedString? {
        guard let imageData = image.pngData() else {
            return nil
        }
        let encodedImageString = imageData.base64EncodedString()

        let html = "<img src='data:image/png;base64,\(encodedImageString)'"
        let data = Data(html.utf8)
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        return try? NSAttributedString(data: data, options: options, documentAttributes: nil)
    }
}
