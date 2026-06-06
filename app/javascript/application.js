/* eslint no-console:0 */
import LocalTime from 'local-time'
import { Turbo } from '@hotwired/turbo-rails'
import { Application } from '@hotwired/stimulus'
import gsap from 'gsap'
import './misc/bugsnag'

import BigPlayController from './controllers/big_play_controller'
import BlankSlateController from './controllers/blank_slate_controller'
import CommentController from './controllers/comment_controller'
import FavoriteController from './controllers/favorite_controller'
import FlashController from './controllers/flash_controller'
import FollowController from './controllers/follow_controller'
import FolloweesController from './controllers/followees_controller'
import HeaderSearchController from './controllers/header_search_controller'
import HeartController from './controllers/heart_controller'
import ImageUploadController from './controllers/image_upload_controller'
import NormalPlaybackController from './controllers/normal_playback_controller'
import PlayerController from './controllers/player_controller'
import PlaylistController from './controllers/playlist_controller'
import PlaylistFormController from './controllers/playlist_form_controller'
import PlaylistSortController from './controllers/playlist_sort_controller'
import PlaylistUpdateController from './controllers/playlist_update_controller'
import PlaylistsSortController from './controllers/playlists_sort_controller'
import SaveController from './controllers/save_controller'
import SubnavController from './controllers/subnav_controller'
import SvgCoverController from './controllers/svg_cover_controller'
import ToggleSettingController from './controllers/toggle_setting_controller'
import TracklistController from './controllers/tracklist_controller'
import UserDropdownController from './controllers/user_dropdown_controller'
import UserFavoritesController from './controllers/user_favorites_controller'

LocalTime.config.i18n.en.datetime.at = '{date}' // drop the time from the date
LocalTime.config.i18n.en.date.on = '{date}' // no "on Sunday", just "Sunday"
LocalTime.start()

window.Stimulus = Application.start()
Stimulus.register('big-play', BigPlayController)
Stimulus.register('blank-slate', BlankSlateController)
Stimulus.register('comment', CommentController)
Stimulus.register('favorite', FavoriteController)
Stimulus.register('flash', FlashController)
Stimulus.register('follow', FollowController)
Stimulus.register('followees', FolloweesController)
Stimulus.register('header-search', HeaderSearchController)
Stimulus.register('heart', HeartController)
Stimulus.register('image-upload', ImageUploadController)
Stimulus.register('normal-playback', NormalPlaybackController)
Stimulus.register('player', PlayerController)
Stimulus.register('playlist', PlaylistController)
Stimulus.register('playlist-form', PlaylistFormController)
Stimulus.register('playlist-sort', PlaylistSortController)
Stimulus.register('playlist-update', PlaylistUpdateController)
Stimulus.register('playlists-sort', PlaylistsSortController)
Stimulus.register('save', SaveController)
Stimulus.register('subnav', SubnavController)
Stimulus.register('svg-cover', SvgCoverController)
Stimulus.register('toggle-setting', ToggleSettingController)
Stimulus.register('tracklist', TracklistController)
Stimulus.register('user-dropdown', UserDropdownController)
Stimulus.register('user-favorites', UserFavoritesController)

function handlers() {
  document.querySelectorAll('.slide_open_href').forEach((link) => {
    link.addEventListener('click', (event) => {
      const id = event.target.getAttribute('href')
      document.querySelector(id).style.display = 'block'
      event.preventDefault()
    })
  })
}
document.addEventListener('turbo:load', handlers)

// Re-exported so esbuild's --global-name=Alonetone exposes Alonetone.gsap
export { gsap, Turbo }
