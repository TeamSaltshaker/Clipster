import Foundation

struct DomainMapper {
    func folder(from entity: FolderEntity) -> Folder? {
        guard let folders = entity.folders?.compactMap(folder),
              let clips = entity.clips?.compactMap(clip) else {
            return nil
        }

        return Folder(
            id: entity.id,
            parentFolderID: entity.parentFolder?.id,
            title: entity.title,
            depth: Int(entity.depth),
            folders: folders,
            clips: clips,
            createdAt: entity.createdAt,
            updatedAt: entity.updatedAt,
            deletedAt: entity.deletedAt,
        )
    }

    func clip(from entity: ClipEntity) -> Clip? {
        guard let folderID = entity.folder?.id,
              let urlMetadataEntity = entity.urlMetadata,
              let urlMetadata = urlMetadata(from: urlMetadataEntity) else {
            return nil
        }

        return Clip(
            id: entity.id,
            folderID: folderID,
            urlMetadata: urlMetadata,
            memo: entity.memo,
            lastVisitedAt: entity.lastVisitedAt,
            createdAt: entity.createdAt,
            updatedAt: entity.updatedAt,
            deletedAt: entity.deletedAt,
        )
    }

    private func urlMetadata(from entity: URLMetadataEntity) -> URLMetadata? {
        guard let url = URL(string: entity.urlString),
              let thumbnailImageURL = URL(string: entity.thumbnailImageURLString) else {
            return nil
        }

        return URLMetadata(
            url: url,
            title: entity.title,
            thumbnailImageURL: thumbnailImageURL,
            createdAt: entity.createdAt,
            updatedAt: entity.updatedAt,
            deletedAt: entity.deletedAt,
        )
    }
}
