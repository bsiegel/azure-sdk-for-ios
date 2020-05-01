// --------------------------------------------------------------------------
//
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// The MIT License (MIT)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the ""Software""), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//
// --------------------------------------------------------------------------

import Foundation

public struct TransferCollection {
    /// Get all transfers in this `TransferCollection`.
    public let all: [BlobTransfer]

    internal init(_ items: [BlobTransfer]) {
        self.all = items
    }

    /// Get a single transfer in this `TransferCollection` by its id.
    /// - Parameters:
    ///   - transferId: The id of the transfer to retrieve.
    public subscript(_ transferId: UUID) -> BlobTransfer? { return all.first { $0.id == transferId } }

    /// Cancel all currently active transfers in this `TransferCollection`.
    public func cancelAll() {
        for transfer in all {
            URLSessionTransferManager.shared.cancel(transfer: transfer)
        }
    }

    /// Remove all transfers in this `TransferCollection` from the database. All currently active transfers will be
    /// cancelled.
    public func removeAll() {
        for transfer in all {
            URLSessionTransferManager.shared.remove(transfer: transfer)
        }
    }

    /// Pause all currently active transfers in this `TransferCollection`.
    public func pauseAll() {
        for transfer in all {
            URLSessionTransferManager.shared.pause(transfer: transfer)
        }
    }

    /// Resume all currently paused transfers in this `TransferCollection`.
    public func resumeAll() {
        for transfer in all {
            URLSessionTransferManager.shared.resume(transfer: transfer)
        }
    }

    /// Get all transfers in this `TransferCollection` that match the provided filter values.
    /// - Parameters:
    ///   - containerName: The name of the blob container involved in the transfer. For downloads this is the source
    ///   container, whereas for uploads this is the destination container.
    ///   - blobName: The name of the blob involved in the transfer. For downloads this is the source blob, whereas for
    ///   uploads this is the destination blob.
    ///   - localUrl: The `LocalURL` involved in the transfer. For downloads this is the destination, whereas for
    ///   uploads this is the source.
    ///   - state: The current state of the transfer.
    public func filterWhere(
        containerName _: String? = nil,
        blobName _: String? = nil,
        localUrl _: LocalURL? = nil,
        state _: TransferState? = nil
    ) -> [BlobTransfer] {
        return all.filter { match($0) }
    }

    /// Get the first transfer in this `TransferCollection` that matches the provided filter values.
    /// - Parameters:
    ///   - containerName: The name of the blob container involved in the transfer. For downloads this is the source
    ///   container, whereas for uploads this is the destination container.
    ///   - blobName: The name of the blob involved in the transfer. For downloads this is the source blob, whereas for
    ///   uploads this is the destination blob.
    ///   - localUrl: The `LocalURL` involved in the transfer. For downloads this is the destination, whereas for
    ///   uploads this is the source.
    ///   - state: The current state of the transfer.
    public func firstWith(
        containerName _: String? = nil,
        blobName _: String? = nil,
        localUrl _: LocalURL? = nil,
        state _: TransferState? = nil
    ) -> BlobTransfer? {
        return all.first { match($0) }
    }

    /// Get all transfers in this `TransferCollection` that satisfy the given predicate.
    /// - Parameters:
    ///   - isIncluded: A closure that takes a Transfer as its argument and returns a Boolean value indicating whether
    ///   the Transfer should be included in the returned array.
    public func filter(_ isIncluded: (BlobTransfer) throws -> Bool) rethrows -> [BlobTransfer] {
        return try all.filter(isIncluded)
    }

    /// Get the first transfer in this `TransferCollection` that satisfies the given predicate.
    /// - Parameters:
    ///   - predicate: A closure that takes a Transfer as its argument and returns a Boolean value indicating whether
    ///   the transfer is a match.
    public func first(where predicate: (BlobTransfer) throws -> Bool) rethrows -> BlobTransfer? {
        return try all.first(where: predicate)
    }

    private func match(
        _ transfer: BlobTransfer,
        containerName: String? = nil,
        blobName: String? = nil,
        localUrl: LocalURL? = nil,
        state: TransferState? = nil
    ) -> Bool {
        var matched = true

        if let state = state {
            matched = matched && transfer.state == state
        }

        if let localUrl = localUrl {
            guard let url = transfer.transferType == .download ? transfer.destination : transfer.source
            else { return false }
            matched = matched && url == localUrl.rawUrl
        }

        if let blobName = blobName {
            guard let url = transfer.transferType == .download ? transfer.source : transfer.destination
            else { return false }
            matched = matched && url.path.hasSuffix(blobName)
        }

        if let containerName = containerName {
            guard let url = transfer.transferType == .download ? transfer.source : transfer.destination
            else { return false }
            matched = matched && url.path.hasPrefix(containerName)
        }

        return matched
    }
}
