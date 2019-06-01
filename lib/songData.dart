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

  if (albums != null) {
    albums.forEach((key, value) {
      var albumArt;
      var songsInAlbum;

      value.forEach((key2, value2) {
        if (key2 == "thumbnail") {
          albumArt = value2;
        } else if (key2 == "songs") {
          songsInAlbum = value2;
        }
      });
      albumList.add(
          {"albumName": key, "thumbnail": albumArt, "songs": songsInAlbum});
    });
  }

  return albumList;
}
