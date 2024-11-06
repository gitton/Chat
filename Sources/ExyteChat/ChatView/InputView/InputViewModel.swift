//
//  Created by Alex.M on 20.06.2022.
//

import Foundation
import Combine
import ExyteMediaPicker

final class InputViewModel: ObservableObject {

    @Published var text = ""
    @Published var attachments = InputViewAttachments()
    @Published var state: InputViewState = .empty

    @Published var showPicker = false
    @Published var mediaPickerMode = MediaPickerMode.photos

    @Published var showActivityIndicator = false

    var didSendMessage: ((DraftMessage) -> Void)?
    var didClickSuggestions: (() -> Void)?

    private var saveEditingClosure: ((String) -> Void)?

    private var subscriptions = Set<AnyCancellable>()

    func onStart() {
        subscribeValidation()
        subscribePicker()
    }

    func onStop() {
        subscriptions.removeAll()
    }

    func reset() {
        // Clear text first
        self.text = ""
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Reset other properties
            self.showPicker = false
            self.saveEditingClosure = nil
            self.attachments = InputViewAttachments()
            self.subscribeValidation()
            self.state = .empty
            
            // Force UI update for text field
            self.objectWillChange.send()
        }
    }

    func send() {
        sendMessage()
            .store(in: &subscriptions)
    }

    func edit(_ closure: @escaping (String) -> Void) {
        saveEditingClosure = closure
        state = .editing
    }

    func inputViewAction() -> (InputViewAction) -> Void {
        { [weak self] in
            self?.inputViewActionInternal($0)
        }
    }
    
    private func inputViewActionInternal(_ action: InputViewAction) {
        switch action {
        case .photo:
            mediaPickerMode = .photos
            showPicker = true
        case .add:
            mediaPickerMode = .camera
        case .camera:
            mediaPickerMode = .camera
            showPicker = true
        case .send:
            send()
        case .saveEdit:
            saveEditingClosure?(text)
            reset()
        case .cancelEdit:
            reset()
        }
    }
    
    func clickedSuggestions() {
        self.didClickSuggestions?()
    }
}

private extension InputViewModel {

    func validateDraft() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard state != .editing else { return } // special case
            if !self.text.isEmpty || !self.attachments.medias.isEmpty {
                self.state = .hasTextOrMedia
            } else if self.text.isEmpty,
                      self.attachments.medias.isEmpty {
                self.state = .empty
            }
        }
    }

    func subscribeValidation() {
        $attachments.sink { [weak self] _ in
            self?.validateDraft()
        }
        .store(in: &subscriptions)

        $text.sink { [weak self] _ in
            self?.validateDraft()
        }
        .store(in: &subscriptions)
    }

    func subscribePicker() {
        $showPicker
            .sink { [weak self] value in
                if !value {
                    self?.attachments.medias = []
                }
            }
            .store(in: &subscriptions)
    }

    // func subscribeRecordPlayer() {
    //     // recordPlayerSubscription = recordingPlayer?.didPlayTillEnd
    //     //     .sink { [weak self] in
    //     //         self?.state = .hasRecording
    //     //     }
    // }

    // func unsubscribeRecordPlayer() {
    //     // recordPlayerSubscription = nil
    // }
}

private extension InputViewModel {
    
    func mapAttachmentsForSend() -> AnyPublisher<[Attachment], Never> {
        attachments.medias.publisher
            .receive(on: DispatchQueue.global())
            .asyncMap { media in
                guard let thumbnailURL = await media.getThumbnailURL() else {
                    return nil
                }

                switch media.type {
                case .image:
                    return Attachment(id: UUID().uuidString, url: thumbnailURL, type: .image)
                case .video:
                    guard let fullURL = await media.getURL() else {
                        return nil
                    }
                    return Attachment(id: UUID().uuidString, thumbnail: thumbnailURL, full: fullURL, type: .video)
                }
            }
            .compactMap {
                $0
            }
            .collect()
            .eraseToAnyPublisher()
    }

    func sendMessage() -> AnyCancellable {
        showActivityIndicator = true
        return mapAttachmentsForSend()
            .compactMap { [attachments] _ in
                DraftMessage(
                    text: self.text,
                    medias: attachments.medias,
//                    recording: attachments.recording,
                    replyMessage: attachments.replyMessage,
                    createdAt: Date()
                )
            }
            .sink { [weak self] draft in
                self?.didSendMessage?(draft)
                DispatchQueue.main.async { [weak self] in
                    self?.showActivityIndicator = false
                    self?.reset()
                }
            }
    }
}

extension Publisher {
    func asyncMap<T>(
        _ transform: @escaping (Output) async -> T
    ) -> Publishers.FlatMap<Future<T, Never>, Self> {
        flatMap { value in
            Future { promise in
                Task {
                    let output = await transform(value)
                    promise(.success(output))
                }
            }
        }
    }
}
