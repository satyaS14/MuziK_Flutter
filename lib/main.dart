import 'dart:async';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flute_music_player/flute_music_player.dart';
import './songData.dart';
import 'dart:ui';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

/* Global vars used by both screens */
MusicFinder audioPlayer;
Duration _duration;
final ValueNotifier<Duration> _position =
    ValueNotifier<Duration>(Duration(seconds: 0));

List albums;
IconData icon;
bool isSameSong;

Song playingSong;

enum PlayerState { stopped, playing, paused }
PlayerState playerState;

/* Stream for position - to be shared by both screens */
// final StreamController<Duration> _streamController =
//     new StreamController<Duration>();

void main() {
  audioPlayer = new MusicFinder();
  _duration = new Duration();

  albums = new List<Song>();
  icon = Icons.play_arrow;
  isSameSong = true;

  playingSong = new Song(null, null, null, null, null, null, null, null);
  playerState = PlayerState.stopped;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'MuZiKKK',
        theme: ThemeData(fontFamily: "JosefinSans-SemiBold"),
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          /* When we navigate to the "/" route, build the FirstScreen Widget */
          '/': (context) => MyMuzik(),

          /* When we navigate to the "/album" route, build the AlbumScreen Widget */
          '/album': (context) {
            return MyAlbum();
          }
        });
  }
}

class MyMuzik extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Muzik();
  }
}

class Muzik extends StatefulWidget {
  final AsyncMemoizer _memoizer = AsyncMemoizer();

  @override
  MuzikState createState() {
    return MuzikState();
  }
}

class MuzikState extends State<Muzik> {
  Future getSongs() async {
    var songs;

    audioPlayer.setDurationHandler((Duration d) => setState(() {
          _duration = d;
        }));

    audioPlayer.setPositionHandler((Duration p) => setState(() {
          _position.value = p;
        }));

    audioPlayer.setCompletionHandler(() {
      setState(() {
        playerState = PlayerState.stopped;

        _position.value = Duration(seconds: 0);
        icon = Icons.play_arrow;
      });
    });

    return widget._memoizer.runOnce(() async {
      try {
        songs = await MusicFinder.allSongs();
      } catch (e) {
        print(e.toString());
      }
      playingSong = songs[0];
      return songs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder(
      future: getSongs(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data != null) {
            // Dividing songs into albums
            albums = buildAlbumData(snapshot.data);

            return new WillPopScope(
                onWillPop: () => _exitApp(context),
                child: Scaffold(
                  // backgroundColor: Colors.black,
                  appBar: AppBar(
                    title: Text("MuZikk"),
                    backgroundColor: Colors.indigo,
                  ),
                  body: new Column(children: <Widget>[
                    /* Divisions */

                    /* Albums */
                    new CustomAlbumWidget(),

                    /* Player */
                    MyPlayerHome(),
                  ]),
                  // floatingActionButton: FloatingActionButton(
                  //   onPressed: () {
                  //     // Add your onPressed code here!
                  //   },
                  //   child: Icon(
                  //     Icons.music_note,
                  //     color: Colors.white,
                  //   ),
                  //   backgroundColor: Colors.pink,
                  // )
                ));
          }
        } else {
          return new CircularProgressIndicator();
        }
      },
    );
  }
}

class CustomAlbumWidget extends StatelessWidget {
  const CustomAlbumWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (albums == null) {
      return CustomNoSongsWidget();
    } else {
      return new Expanded(
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          primary: true,
          slivers: <Widget>[
            SliverPadding(
              padding: const EdgeInsets.all(1.0),
              sliver: SliverGrid.count(
                  childAspectRatio: 0.9,
                  crossAxisCount: 2,
                  children: _buildRows(context)),
            ),
          ],
        ),
      );
    }
  }
}

class CustomPlayerWidget extends StatelessWidget {
  const CustomPlayerWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Container(
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
        ));
  }
}

class CustomNoSongsWidget extends StatelessWidget {
  const CustomNoSongsWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      new RichText(
          text: new TextSpan(text: '', children: [
        new TextSpan(
            text: 'No Songs Found !!!',
            style: new TextStyle(
              color: Colors.white,
              fontSize: 14.0,
              height: 1.5,
              letterSpacing: 4.0,
            ))
      ]))
    ]);
  }
}

List<Widget> _buildRows(BuildContext context) {
  final List<Widget> gridTiles = <Widget>[];
  for (var i = 0; i < albums.length; i++) {
    gridTiles.add(
      new CustomGridTileWidget(albumIndex: i),
    );
  }
  return gridTiles;
}

class CustomGridTileWidget extends StatelessWidget {
  const CustomGridTileWidget({
    Key key,
    @required this.albumIndex,
  }) : super(key: key);

  final albumIndex;

  @override
  Widget build(BuildContext context) {
    return new GridTile(
        child:
            // new Scaffold(
            //     body:
            new InkResponse(
      enableFeedback: true,
      child: new Container(
        height: 300,
        decoration: new BoxDecoration(
            borderRadius: new BorderRadius.all(new Radius.elliptical(1.0, 1.0)),
            boxShadow: [
              new BoxShadow(
                color: Colors.white54,
                offset: new Offset(5.0, 5.0),
                blurRadius: 10.0,
              )
            ]),
        padding: const EdgeInsets.all(0),
        margin: const EdgeInsets.all(6),
        child: new CustomCardWidget(albumIndex: albumIndex),
      ),
      onTap: () {
        goToAlbum(context, albumIndex);
      },
      // )
    ));
  }
}

goToAlbum(BuildContext context, var albumIndex) {
  Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (context, anim1, anim2) => MyAlbum(albumIndex: albumIndex),
      transitionsBuilder: (context, anim1, anim2, child) =>
          FadeTransition(opacity: anim1, child: child),
      transitionDuration: Duration(milliseconds: 750),
    ),
  );
}

class CustomCardWidget extends StatelessWidget {
  CustomCardWidget({
    Key key,
    @required this.albumIndex,
  }) : super(key: key);

  final albumIndex;

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 5.0,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          new Hero(
            tag: albums[albumIndex]["albumName"],
            child: new Container(
                height: 185,
                decoration: new BoxDecoration(
                  borderRadius:
                      new BorderRadius.all(new Radius.elliptical(1.0, 1.0)),
                ),
                child: Center(
                    child: Image.asset(albums[albumIndex]["thumbnail"],
                        fit: BoxFit.fitWidth))),
            transitionOnUserGestures: true,
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.only(left: 8, top: 3, bottom: 3),
            child: Text(
              albums[albumIndex]["albumName"],
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: .5,
                wordSpacing: 1,
              ),
              textAlign: TextAlign.left,
            ),
          )),
        ]));
  }
}

class MyPlayerHome extends StatefulWidget {
  @override
  MyPlayerHomeState createState() {
    return MyPlayerHomeState();
  }
}

class MyPlayerHomeState extends State<MyPlayerHome> {
  @override
  Widget build(BuildContext context) {
    return new Container(
        height: 75,
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.indigo),
        // padding: EdgeInsets.all(0),
        // child:
        //   new Material(
        //     color: Colors.indigo,
        //     // Color(0xFFf08f8f),
        //     shadowColor: Colors.white,
        child: StaggeredGridView.count(
            // scrollDirection: Axis.horizontal,
            crossAxisSpacing: 8.0,
            crossAxisCount: 12,
            staggeredTiles: [
              /* Play icon */
              StaggeredTile.count(2, 2.75),
              /* seekbar & title*/
              StaggeredTile.count(8, 2.75),
              /* Album logo */
              StaggeredTile.count(2, 2.75),
            ],
            children: <Widget>[
              /* Play icon */
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: RawMaterialButton(
                  shape: CircleBorder(),
                  fillColor: Colors.white,
                  splashColor: Color(0xFFf08f8f),
                  highlightColor: Color(0xFFf08f8f),
                  elevation: 3.0,
                  highlightElevation: 3.0,
                  onPressed: () {
                    setState(() {
                      if (icon == Icons.play_arrow) {
                        icon = Icons.pause;
                        playerState = PlayerState.playing;
                        audioPlayer.play(playingSong.uri, isLocal: true);
                      } else if (icon == Icons.pause) {
                        icon = Icons.play_arrow;
                        playerState = PlayerState.paused;
                        audioPlayer.pause();
                      }

                      /* Only applicable for the first time */
                      if (playerState == PlayerState.stopped) {
                        audioPlayer.stop();
                      }
                    });
                  },
                  child: Icon(
                    icon,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
              ),
              Column(children: <Widget>[
                Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: ValueListenableBuilder(
                        valueListenable: _position,
                        builder: (BuildContext context, Duration _position,
                            Widget child) {
                          return Slider(
                            activeColor: Colors.white,
                            inactiveColor: Colors.white30,
                            value: _position.inSeconds.toDouble(),
                            min: 0.0,
                            max: _duration.inSeconds.toDouble(),
                            onChanged: (double newValue) {
                              audioPlayer.seek(newValue);
                            },
                          );
                        })),
                /* Song title */
                HomeScreenTitle(),
              ]),
              Image.asset(playingSong.albumArt, fit: BoxFit.fitHeight)
            ])
        // )
        );
  }
}

class HomeScreenTitle extends StatefulWidget {
  @override
  HomeScreenTitleState createState() {
    return HomeScreenTitleState();
  }
}

class HomeScreenTitleState extends State<HomeScreenTitle> {
  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: EdgeInsets.only(top: 5.0),
      child: Text(
        playingSong.title,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          wordSpacing: 2,
          letterSpacing: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class MyAlbum extends StatelessWidget {
  final albumIndex;

  MyAlbum({this.albumIndex});

  @override
  Widget build(BuildContext context) {
    return AlbumNSongs(albumIndex: this.albumIndex);
  }
}

class AlbumNSongs extends StatefulWidget {
  const AlbumNSongs({Key key, this.albumIndex}) : super(key: key);

  final albumIndex;

  @override
  AlbumNSongsState createState() {
    return AlbumNSongsState();
  }
}

class AlbumNSongsState extends State<AlbumNSongs> {
  // Color _color = Colors.white;

  var songTitle;
  var cardIndex = 0;
  ScrollController scrollController;

  @override
  void initState() {
    super.initState();

    scrollController = new ScrollController();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text("MuZikk"),
        backgroundColor: Colors.indigo,
      ),
      body: this._getSongs(albums[widget.albumIndex]),
    );
  }

  Widget _getSongs(var data) {
    audioPlayer.setPositionHandler((Duration p) => setState(() {
          _position.value = p;
        }));

    audioPlayer.setCompletionHandler(() {
      setState(() {
        playerState = PlayerState.stopped;

        if (isSameSong) {
          _position.value = Duration(seconds: 0);
          icon = Icons.play_arrow;
        }
      });
    });

    this.songTitle = data["songs"][cardIndex].title;

    return new Column(children: [
      new Expanded(
        child: new Container(
            decoration: new BoxDecoration(
                image: new DecorationImage(
                    image: new AssetImage(data["thumbnail"]),
                    fit: BoxFit.cover)),
            child: new BackdropFilter(
                filter: new ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: new Center(
                      child: ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: data["songs"].length,
                          controller: scrollController,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, position) {
                            return GestureDetector(
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                            width: 300,
                                            child: InkResponse(
                                              child: Column(children: <Widget>[
                                                ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    child: getImage(data,
                                                        position, cardIndex)),

                                                /* Title */
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 30.0,
                                                          bottom: 10.0,
                                                          left: 10.0,
                                                          right: 10.0),
                                                  child: Text(
                                                    data["songs"][position]
                                                        .title,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      shadows: [
                                                        const Shadow(
                                                            color: Colors.white,
                                                            offset: Offset.zero,
                                                            blurRadius: 2)
                                                      ],
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                      wordSpacing: 2,
                                                      letterSpacing: 1.5,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                )
                                              ]),
                                              onTap: () {
                                                setState(() {
                                                  /* If not the Same song */
                                                  if (data["songs"][position]
                                                          .title !=
                                                      playingSong.title) {
                                                    playingSong = data["songs"]
                                                        [cardIndex];
                                                    icon = Icons.pause;
                                                    playerState =
                                                        PlayerState.playing;
                                                    audioPlayer.stop();
                                                    audioPlayer.play(
                                                        data["songs"][cardIndex]
                                                            .uri,
                                                        isLocal: true);
                                                    _position.value =
                                                        Duration(seconds: 0);
                                                  }
                                                });
                                              },
                                            )),
                                      ]),
                                ),
                                onHorizontalDragEnd: (details) {
                                  if (details.velocity.pixelsPerSecond.dx > 0) {
                                    if (cardIndex > 0) cardIndex--;
                                  } else if (details
                                          .velocity.pixelsPerSecond.dx <
                                      0) {
                                    if (cardIndex < data["songs"].length - 1)
                                      cardIndex++;
                                  }
                                  setState(() {
                                    scrollController.animateTo(
                                        (cardIndex) * 340.0,
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.fastOutSlowIn);
                                  });
                                });
                          })),
                ))),
      ),

      MyPlayerHome(),
      /* Song title and controls */
      // new Container(
      //     width: double.infinity,
      //     child: new Material(
      //         color: Color(0xFFf08f8f),
      //         shadowColor: Colors.white,
      //         child: new Column(children: <Widget>[
      //           /* Seek bar */
      //           Padding(
      //             padding: const EdgeInsets.only(
      //                 top: 30.0, left: 30.0, right: 30.0, bottom: 10.0),
      //             child: Slider(
      //               activeColor: Colors.white,
      //               inactiveColor: Colors.white30,
      //               value: _position.inSeconds.toDouble(),
      //               min: 0.0,
      //               max: _duration.inSeconds.toDouble(),
      //               onChanged: (double newValue) {
      //                 if (isSameSong) {
      //                   audioPlayer.seek(newValue);
      //                 }
      //               },
      //             ),
      //           ),
      //           new Padding(
      //               padding: EdgeInsets.all(15),
      //               child: new Column(children: <Widget>[
      //                 /* Song title */
      //                 new Padding(
      //                   padding: EdgeInsets.only(top: 10.0),
      //                   child: Text(
      //                     songTitle,
      //                     overflow: TextOverflow.ellipsis,
      //                     style: TextStyle(
      //                       fontWeight: FontWeight.bold,
      //                       color: Colors.white,
      //                       wordSpacing: 2,
      //                       letterSpacing: 1.5,
      //                     ),
      //                     textAlign: TextAlign.center,
      //                   ),
      //                 ),
      //                 new Padding(
      //                     padding: EdgeInsets.only(top: 20.0, bottom: 5.0),
      //                     child: new Row(
      //                       children: <Widget>[
      //                         new Expanded(child: new Container()),
      //                         new IconButton(
      //                             splashColor: Color(0xFFf08f8f),
      //                             highlightColor: Colors.transparent,
      //                             icon: new Icon(Icons.skip_previous,
      //                                 color: _color),
      //                             onPressed: () {}),
      //                         new Expanded(child: new Container()),
      //                         new RawMaterialButton(
      //                           shape: CircleBorder(),
      //                           fillColor: Colors.white,
      //                           splashColor: Color(0xFFf08f8f),
      //                           highlightColor: Color(0xFFf08f8f),
      //                           elevation: 5.0,
      //                           highlightElevation: 5.0,
      //                           onPressed: () {
      //                             setState(() {
      //                               if (icon == Icons.play_arrow) {
      //                                 icon = Icons.pause;
      //                                 playerState = PlayerState.playing;
      //                                 playingSong = data["songs"][cardIndex];
      //                               } else if (icon == Icons.pause) {
      //                                 icon = Icons.play_arrow;
      //                                 playerState = PlayerState.paused;
      //                               }

      //                               if (playerState == PlayerState.stopped) {
      //                                 audioPlayer.stop();
      //                               } else if (playerState ==
      //                                   PlayerState.playing) {
      //                                 if (!(isSameSong)) {
      //                                   audioPlayer.stop();
      //                                   isSameSong = true;
      //                                 }
      //                                 audioPlayer.play(
      //                                     data["songs"][cardIndex].uri,
      //                                     isLocal: true);
      //                               } else if (playerState ==
      //                                   PlayerState.paused) {
      //                                 audioPlayer.pause();
      //                               }
      //                             });
      //                           },
      //                           child: Icon(icon, color: Color(0xFFf08f8f)),
      //                         ),
      //                         new Expanded(child: new Container()),
      //                         new IconButton(
      //                             splashColor: Colors.transparent,
      //                             highlightColor: Colors.transparent,
      //                             icon:
      //                                 new Icon(Icons.skip_next, color: _color),
      //                             onPressed: () {}),
      //                         new Expanded(child: new Container())
      //                       ],
      //                     ))
      //               ]))
      //         ]))),
    ]);
  }
}

Widget getSongCards(var data, int pos) {
  Widget card = new ClipRRect(
      borderRadius: new BorderRadius.circular(20.0),
      child: new Image(
        image: new AssetImage(data["thumbnail"]),
        fit: BoxFit.cover,
      ));
  return card;
}

_exitApp(BuildContext context) {
  // Navigator.of(context).pop(false);
}

Widget getImage(var data, int position, int cardIndex) {
  if (position == cardIndex) {
    return new Hero(
      tag: data["albumName"],
      child: Image.asset(data["thumbnail"], fit: BoxFit.contain),
      transitionOnUserGestures: true,
    );
  } else {
    return Image.asset(data["thumbnail"], fit: BoxFit.contain);
  }
}
