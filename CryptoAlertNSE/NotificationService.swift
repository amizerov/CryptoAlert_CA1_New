//
//  NotificationService.swift
//  CryptoAlertNSE
//
//  Created by Andrey Mizerov on 17.01.2022.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest,
							 withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {

        let imageKey = "icon_image"
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        // MARK: - Rich Push
        if let bestAttemptContent = bestAttemptContent {
            let userInfo = request.content.userInfo;
            
            if userInfo[imageKey] == nil {
                contentHandler(bestAttemptContent);
                return;
            }
            
			let para_id = userInfo["para_id"] ?? "AM: ***"
			print(para_id)
			
            // If there is an image in the payload,
            // download and display the image.
            if let attachmentMedia = userInfo[imageKey] as? String {
                let mediaUrl = URL(string: attachmentMedia)
                let urs = URLSession(configuration: .default)
                urs.downloadTask(with: mediaUrl!, completionHandler: { temporaryLocation, response, error in
                    if let err = error {
                        print("AM: Error with downloading rich push: \(String(describing: err.localizedDescription))")
                        contentHandler(bestAttemptContent);
                        return;
                    }
                    
                    let fileType = self.determineType(fileType: (response?.mimeType)!)
                    let fileName = temporaryLocation?.lastPathComponent.appending(fileType)
                    
                    let temporaryDirectory = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName!)
                    
                    do {
                        try FileManager.default.moveItem(at: temporaryLocation!, to: temporaryDirectory)
                        let attachment = try UNNotificationAttachment(identifier: "", url: temporaryDirectory, options: nil)
                        
                        bestAttemptContent.attachments = [attachment];
						//bestAttemptContent.body += "\n{\(para_id)}"
						bestAttemptContent.targetContentIdentifier = "\(para_id)"
						
                        contentHandler(bestAttemptContent);
                        // The file should be removed automatically from temp
                        // Delete it manually if it is not
                        if FileManager.default.fileExists(atPath: temporaryDirectory.path) {
                            try FileManager.default.removeItem(at: temporaryDirectory)
                        }
                    } catch {
                        print("AM: Error with the rich push attachment: \(error)")
                        contentHandler(bestAttemptContent);
                        return;
                    }
                }).resume()
            }
        }
    }
    
    // MARK: - Leanplum Rich Push
    func determineType(fileType: String) -> String {
        // Determines the file type of the attachment to append to URL.
        if fileType == "image/jpeg" {
            return ".jpg";
        }
        if fileType == "image/gif" {
            return ".gif";
        }
        if fileType == "image/png" {
            return ".png";
        } else {
            return ".tmp";
        }
    }

    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
