import 'package:flutter/material.dart';
import 'package:flute_music_player/flute_music_player.dart';
import 'dart:ui';

class myAlbum extends StatelessWidget {
  var albumData;

  myAlbum({this.albumData});

  @override
  Widget build(BuildContext context) {
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
  var songTitle = '';

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
    return new Container(
        decoration: new BoxDecoration(
            image: new DecorationImage(
                image: new AssetImage(data["thumbnail"]), fit: BoxFit.cover)),
        child: new BackdropFilter(
            filter: new ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
            child: new Hero(
              tag: data["albumName"],
              child: new Column(children: <Widget>[
                /* Song image */
                new CustomSongImageWidget(data: data),

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
                                child: Text(
                                  data["songs"][0].title,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    wordSpacing: 2,
                                    letterSpacing: 1.5,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              new Padding(
                                  padding:
                                      EdgeInsets.only(top: 20.0, bottom: 5.0),
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
                                          if (playerState ==
                                              PlayerState.stopped) {
                                            audioPlayer
                                                .play(data["songs"][0].uri);
                                            playerState = PlayerState.playing;
                                          } else if (playerState ==
                                              PlayerState.playing) {
                                            audioPlayer.pause();
                                            playerState = PlayerState.paused;
                                          } else if (playerState ==
                                              PlayerState.paused) {
                                            audioPlayer
                                                .play(data["songs"][0].uri);
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
              ]),
              transitionOnUserGestures: true,
            )));
  }
}

class CustomSongImageWidget extends StatelessWidget {
  CustomSongImageWidget({Key key, @required this.data}) : super(key: key);
  var data;

  @override
  Widget build(BuildContext context) {
    return new Expanded(
        child: new Center(
            child: new Container(
                height: 350.0,
                width: 350.0,
                child: new ClipRRect(
                  borderRadius: new BorderRadius.circular(10.0),
                  // clipper: new CircleClipper(),
                  child: new Image(
                    image: new AssetImage(data["thumbnail"]),
                    fit: BoxFit.cover,
                  ),
                ))));
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
