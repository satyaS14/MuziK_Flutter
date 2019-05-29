import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flute_music_player/flute_music_player.dart';

void main() {
  // runApp(myMuZik());
  runApp(MaterialApp(
      title: 'MuZiK',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        // When we navigate to the "/" route, build the FirstScreen Widget
        '/': (context) => myMuZik(),
        // // When we navigate to the "/album" route, build the AlbumScreen Widget
        '/album': (context) {
          return myAlbum();
        }
      }));
}

class myMuZik extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return muzik();
  }
}

class muzik extends StatefulWidget {
  @override
  muzikState createState() {
    return muzikState();
  }
}

class muzikState extends State<muzik> {
  var songs;
  // MusicFinder audioPlayer;

  Future getSongs() async {
    // this.audioPlayer = new MusicFinder();

    try {
      this.songs = await MusicFinder.allSongs();
    } catch (e) {
      print(e.toString());
    }

    return this.songs;
  }

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder(
      future: getSongs(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data != null) {
            // Dividing songs into albums
            var albums = new Map();
            for (var song in snapshot.data) {
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

            return Scaffold(
                appBar: AppBar(
                  title: Text("MuZikk"),
                ),
                body: _buildBody(context, albums),
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    // Add your onPressed code here!
                  },
                  child: Icon(
                    Icons.music_note,
                    color: Colors.white,
                  ),
                  backgroundColor: Colors.pink,
                ));
          }
        } else {
          return new CircularProgressIndicator();
        }
      },
    );
  }
}

Widget _buildBody(BuildContext context, var albums) {
  var albumList = new List();

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

    return Column(children: <Widget>[
      new Expanded(
          child: GridView.count(
        primary: true,
        crossAxisCount: 2,
        childAspectRatio: 0.9,
        children: _buildRows(context, albumList),
      )),
      new Container(
          padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
          color: const Color(0xFFf08f8f),
          child: new Row(
            children: <Widget>[
              new Expanded(child: new Container()),
              new IconButton(
                  icon: new Icon(Icons.skip_previous, color: Colors.white),
                  onPressed: () {}),
              new Expanded(child: new Container()),
              new IconButton(
                  icon: new Icon(Icons.play_arrow, color: Colors.white),
                  onPressed: () {}),
              new Expanded(child: new Container()),
              new IconButton(
                  icon: new Icon(Icons.skip_next, color: Colors.white),
                  onPressed: () {}),
              new Expanded(child: new Container())
            ],
          ))
    ]);
  }
}

List<Widget> _buildRows(BuildContext context, var albumData) {
  final List<Widget> gridTiles = <Widget>[];
  for (var i = 0; i < albumData.length; i++) {
    gridTiles.add(new GridTile(
        child: new InkResponse(
      enableFeedback: true,
      child: new Container(
        decoration: new BoxDecoration(
            borderRadius: new BorderRadius.all(new Radius.elliptical(1.0, 1.0)),
            boxShadow: [
              new BoxShadow(
                color: Colors.white54,
                offset: new Offset(5.0, 5.0),
                blurRadius: 10.0,
                // spreadRadius: 1.0),
              )
            ]),
        padding: const EdgeInsets.all(0),
        margin: const EdgeInsets.all(6),
        child: new Card(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Image.asset(
            albumData[i]["thumbnail"],
            fit: BoxFit.fitWidth,
          ),
          Container(
              padding: const EdgeInsets.only(left: 6, top: 2, bottom: 2),
              child: Row(children: [
                Text(
                  albumData[i]["albumName"],
                )
              ]))
        ])),
      ),
      onTap: () {
        Navigator.pushNamed(context, '/album', arguments: albumData[i]);
      },
    )));
  }
  return gridTiles;
}

class myAlbum extends StatelessWidget {
  var albumData;

  @override
  Widget build(BuildContext context) {
    this.albumData = ModalRoute.of(context).settings.arguments;
    return albumNSongs(this.albumData);
  }
}

class albumNSongs extends StatefulWidget {
  var albumData;
  albumNSongs(var data) {
    this.albumData = data;
  }
  @override
  albumNSongsState createState() {
    return albumNSongsState();
  }
}

enum PlayerState { stopped, playing, paused }

class albumNSongsState extends State<albumNSongs> {
  MusicFinder audioPlayer;

  PlayerState playerState = PlayerState.stopped;

  @override
  Widget build(BuildContext context) {
    this.audioPlayer = new MusicFinder();
    return Scaffold(
      appBar: AppBar(
        title: Text("MuZikk"),
      ),
      body: _getSongs(widget.albumData),
    );
  }

  Widget _getSongs(var data) {
    return new Column(children: <Widget>[
      /* Song image */
      new Expanded(
          child: new Center(
              child: new Container(
                  height: 350.0,
                  width: 350.0,
                  child: new ClipOval(
                    clipper: new CircleClipper(),
                    child: new Image(
                      image: new AssetImage(data["thumbnail"]),
                      fit: BoxFit.cover,
                    ),
                  )))),

      /* Song title and controls */
      new Container(
          width: double.infinity,
          child: new Material(
              color: Color(0xFFf08f8f),
              shadowColor: Colors.white,
              child: new Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: new Column(children: <Widget>[
                    /* Song title */
                    new Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: new RichText(
                            text: new TextSpan(text: '', children: [
                          new TextSpan(
                              text: 'title',
                              style: new TextStyle(
                                color: Colors.white,
                                fontSize: 14.0,
                                height: 1.5,
                                letterSpacing: 4.0,
                              ))
                        ]))),
                    new Padding(
                        padding: EdgeInsets.only(top: 20.0, bottom: 5.0),
                        child: new Row(
                          children: <Widget>[
                            new Expanded(child: new Container()),
                            new IconButton(
                                splashColor: Color(0xFFf08f8f),
                                highlightColor: Colors.transparent,
                                icon: new Icon(Icons.skip_previous,
                                    color: Colors.white),
                                onPressed: () {}),
                            new Expanded(child: new Container()),
                            new RawMaterialButton(
                              shape: CircleBorder(),
                              fillColor: Colors.white,
                              splashColor: Color(0xFFf08f8f),
                              highlightColor: Color(0xFFf08f8f),
                              elevation: 5.0,
                              highlightElevation: 5.0,
                              onPressed: () {
                                if (playerState == PlayerState.stopped) {
                                  audioPlayer.play(data["songs"][0].uri);
                                  playerState = PlayerState.playing;
                                } else if (playerState == PlayerState.playing) {
                                  audioPlayer.pause();
                                  playerState = PlayerState.paused;
                                } else if (playerState == PlayerState.paused) {
                                  audioPlayer.play(data["songs"][0].uri);
                                  playerState = PlayerState.playing;
                                }
                              },
                              child: new Icon(Icons.play_arrow,
                                  color: Color(0xFFf08f8f)),
                            ),
                            new Expanded(child: new Container()),
                            new IconButton(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                icon: new Icon(Icons.skip_next,
                                    color: Colors.white),
                                onPressed: () {}),
                            new Expanded(child: new Container())
                          ],
                        ))
                  ]))))
    ]);
    // return new Container(
    //     decoration: new BoxDecoration(
    //         borderRadius: new BorderRadius.all(new Radius.elliptical(1.0, 1.0)),
    //         boxShadow: [
    //           new BoxShadow(
    //             color: Colors.white54,
    //             offset: new Offset(5.0, 5.0),
    //             blurRadius: 10.0,
    //             // spreadRadius: 1.0),
    //           )
    //         ]),
    //     padding: const EdgeInsets.all(0),
    //     margin: const EdgeInsets.all(0),
    //     child: _getSongsList(data));
  }

  ListView _getSongsList(var data) {
    var returnData = ListView.builder(
        itemCount: 2 * (data["songs"].length + 1),
        padding: const EdgeInsets.all(8.0),
        itemBuilder: /*1*/ (context, i) {
          if (i == 0) {
            return Image.asset(
              data["thumbnail"],
              fit: BoxFit.contain,
            );
          }
          if (i.isOdd) return Divider();

          return _buildSong(data, (i ~/ 2) - 1);
        });

    return returnData;
  }

  Widget _buildSong(var data, var index) {
    return ListTile(
      onTap: () {
        audioPlayer.play(data["songs"][index].uri);
        // onCartChanged(product, !inCart);
      },
      leading: CircleAvatar(
        // backgroundColor: _getColor(context),
        child: new Image(image: new AssetImage(data["thumbnail"])),
      ),
      title: new Row(
        children: [
          new Expanded(
            child: new Text(data["songs"][index].title),
          )
        ],
      ),
    );
  }
}

class CircleClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return new Rect.fromCircle(
      center: new Offset(size.width, size.height) / 2,
      radius: size.width < size.height ? size.width / 2 : size.height / 2,
      //  min(size.width, size.height) / 2,
    );
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}
