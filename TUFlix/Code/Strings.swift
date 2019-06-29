// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
internal enum L10n {

  internal enum Browse {
    /// Browse
    internal static let title = L10n.tr("Localizable", "browse.title")
  }

  internal enum Episode {
    /// Like
    internal static let addLikeTitle = L10n.tr("Localizable", "episode.add_like_title")
    /// Unlike
    internal static let removeLikeTitle = L10n.tr("Localizable", "episode.remove_like_title")
  }

  internal enum Episodes {
    /// All
    internal static let allTitle = L10n.tr("Localizable", "episodes.all_title")
    /// Liked
    internal static let likedTitle = L10n.tr("Localizable", "episodes.liked_title")
    /// Episodes
    internal static let title = L10n.tr("Localizable", "episodes.title")
    /// Show episode names
    internal static let toggleTitle = L10n.tr("Localizable", "episodes.toggle_title")
    internal enum PlayUnavailable {
      /// The selected episode can not be streamed
      internal static let title = L10n.tr("Localizable", "episodes.play_unavailable.title")
    }
    internal enum SelectPlayAudio {
      /// Audio
      internal static let title = L10n.tr("Localizable", "episodes.select_play_audio.title")
    }
    internal enum SelectPlaySource {
      /// Select how you would like to consume the episode
      internal static let title = L10n.tr("Localizable", "episodes.select_play_source.title")
    }
    internal enum SelectPlayVideo {
      /// Video
      internal static let title = L10n.tr("Localizable", "episodes.select_play_video.title")
    }
  }

  internal enum Global {
    /// Tap to retry
    internal static let retryTapTitle = L10n.tr("Localizable", "global.retry_tap_title")
    /// Retry
    internal static let retryTitle = L10n.tr("Localizable", "global.retry_title")
    internal enum Cancel {
      /// Cancel
      internal static let title = L10n.tr("Localizable", "global.cancel.title")
    }
    internal enum EmptyState {
      /// No data to show
      internal static let title = L10n.tr("Localizable", "global.empty_state.title")
    }
    internal enum ErrorState {
      /// An error occured
      internal static let title = L10n.tr("Localizable", "global.error_state.title")
    }
    internal enum LoadingState {
      /// Loading data
      internal static let title = L10n.tr("Localizable", "global.loading_state.title")
    }
    internal enum Ok {
      /// Ok
      internal static let title = L10n.tr("Localizable", "global.ok.title")
    }
  }

  internal enum Library {
    /// Library
    internal static let title = L10n.tr("Localizable", "library.title")
  }

  internal enum Series {
    /// Series
    internal static let title = L10n.tr("Localizable", "series.title")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    // swiftlint:disable:next nslocalizedstring_key
    let format = NSLocalizedString(key, tableName: table, bundle: Bundle(for: BundleToken.self), comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

private final class BundleToken {}
