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

  internal enum Download {
    /// Remove download
    internal static let deleteTitle = L10n.tr("Localizable", "download.delete_title")
    /// Download
    internal static let startTitle = L10n.tr("Localizable", "download.start_title")
    /// Stop download
    internal static let stopTitle = L10n.tr("Localizable", "download.stop_title")
  }

  internal enum Downloads {
    /// Downloads
    internal static let title = L10n.tr("Localizable", "downloads.title")
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
    internal enum AvailableOffline {
      /// Offline
      internal static let title = L10n.tr("Localizable", "episodes.available_offline.title")
    }
    internal enum Liked {
      internal enum State {
        internal enum Empty {
          /// You haven't liked any episodes yet
          internal static let title = L10n.tr("Localizable", "episodes.liked.state.empty.title")
        }
      }
    }
    internal enum Offline {
      internal enum State {
        internal enum Empty {
          /// You haven't downloaded any episodes yet
          internal static let title = L10n.tr("Localizable", "episodes.offline.state.empty.title")
        }
      }
    }
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
    /// %d series have new episodes to watch.
    internal static func newEpisodesAvailableSubtitle(_ p1: Int) -> String {
      return L10n.tr("Localizable", "series.new_episodes_available_subtitle", p1)
    }
    /// New episodes are available to watch
    internal static let newEpisodesAvailableTitle = L10n.tr("Localizable", "series.new_episodes_available_title")
    /// Series
    internal static let title = L10n.tr("Localizable", "series.title")
    internal enum Liked {
      internal enum State {
        internal enum Empty {
          /// You haven't liked any series yet
          internal static let title = L10n.tr("Localizable", "series.liked.state.empty.title")
        }
      }
    }
    internal enum Subscribe {
      /// Notifications are deactivated
      internal static let failedTitle = L10n.tr("Localizable", "series.subscribe.failed_title")
      internal enum Failed {
        /// You will not receive notifications when new episodes will become available for "%@". You can change this in the settings.
        internal static func description(_ p1: String) -> String {
          return L10n.tr("Localizable", "series.subscribe.failed.description", p1)
        }
      }
    }
  }

  internal enum Settings {
    /// Settings
    internal static let title = L10n.tr("Localizable", "settings.title")
    internal enum Reset {
      /// Did you finish the semester? Then let it all out and press this button!
      internal static let description = L10n.tr("Localizable", "settings.reset.description")
      /// Reset
      internal static let title = L10n.tr("Localizable", "settings.reset.title")
    }
    internal enum ResetAlert {
      /// This will remove all your liked series/episodes and delete all downloaded episodes.
      internal static let description = L10n.tr("Localizable", "settings.reset_alert.description")
      /// Do you want to reset the app?
      internal static let title = L10n.tr("Localizable", "settings.reset_alert.title")
    }
    internal enum Series {
      /// Episodes listed inside series will be displayed with the creation date rather then the original title.
      internal static let preferDateDescription = L10n.tr("Localizable", "settings.series.preferDateDescription")
      /// Prefer creation date over title
      internal static let preferDateTitle = L10n.tr("Localizable", "settings.series.preferDateTitle")
      internal enum AutoSubscribe {
        /// For series that you like you will receive notifications when new episodes become available.
        internal static let description = L10n.tr("Localizable", "settings.series.auto_subscribe.description")
        /// Automatically subscribe to favorite series
        internal static let title = L10n.tr("Localizable", "settings.series.auto_subscribe.title")
      }
    }
    internal enum SourceIcons {
      /// Asset were provided by icons8.com
      internal static let title = L10n.tr("Localizable", "settings.source_icons.title")
    }
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
