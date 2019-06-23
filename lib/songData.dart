import 'package:flute_music_player/flute_music_player.dart';

List buildAlbumData(data) {
  var albums = new Map();
  var albumList = new List();

  for (var song in data) {
    String albumName = song.album;
    List<Song> songsInAlbum = new List<Song>();

    if (albums.containsKey(albumName)) {
      songsInAlbum = albums[albumName]["songs"];
      songsInAlbum.add(song);
      albums[albumName]["songs"] = songsInAlbum;
    } else {
      songsInAlbum.add(song);
      albums[albumName] = new Map();
      albums[albumName]["songs"] = songsInAlbum;
      if (song.albumArt == null) {
        albums[albumName]["thumbnail"] = 'images/default.jpg';
      } else {
        albums[albumName]["thumbnail"] = song.albumArt;
      }
    }
  }

  var sortedAlbums = albums.keys.toList()..sort();
  if (sortedAlbums != null) {
    for (var album in sortedAlbums) {
      albumList.add({
        "albumName": album,
        "thumbnail": albums[album]["thumbnail"],
        "songs": albums[album]["songs"]
      });
    }
    ;
  }

  return albumList;
}
