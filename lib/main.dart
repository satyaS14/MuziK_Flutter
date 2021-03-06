import 'dart:async';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flute_music_player/flute_music_player.dart';
import './songData.dart';
import 'dart:ui';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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

var initializationSettingsAndroid = new AndroidInitializationSettings('');
var initializationSettingsIOS = new IOSInitializationSettings();
var initializationSettings = new InitializationSettings(
    initializationSettingsAndroid, initializationSettingsIOS);
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    new FlutterLocalNotificationsPlugin();

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
    Future onSelectNotification(String payload) async {
      if (payload != null) {
        debugPrint('notification payload: ' + payload);
      }
      await Navigator.push(
        context,
        new MaterialPageRoute(builder: (context) => MyMuzik()),
      );
    }

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);

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
      var rng = new Random();
      try {
        songs = await MusicFinder.allSongs();
      } catch (e) {
        print(e.toString());
      }
      playingSong = songs[rng.nextInt(songs.length)];
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
                    body: SlidingUpPanel(
                        color: Colors.transparent,
                        isDraggable: true,
                        minHeight: 75,
                        maxHeight: 725,
                        collapsed: MyPlayerHome(),
                        panel: ExpandedPlayer(),
                        body: Container(
                          padding: EdgeInsets.only(bottom: 170),
                          child: new Column(children: <Widget>[
                            /* Divisions */

                            /* Albums */
                            new CustomAlbumWidget(),
                          ]),
                        ))));
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
        child: new InkResponse(
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

class ExpandedPlayer extends StatefulWidget {
  @override
  ExpandedPlayerHomeState createState() {
    return ExpandedPlayerHomeState();
  }
}

class ExpandedPlayerHomeState extends State<ExpandedPlayer> {
  @override
  Widget build(BuildContext context) {
    return new ClipRRect(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15), topRight: Radius.circular(15)),
        child: Container(
            color: Colors.indigo,
            padding: EdgeInsets.only(bottom: 60, top: 0, left: 0, right: 0),
            child: Column(children: <Widget>[
              Container(
                  height: 480,
                  child: FractionallySizedBox(
                      widthFactor: 1,
                      child: Image.asset(
                        playingSong.albumArt,
                        fit: BoxFit.cover,
                      ))),

              /* Song title */
              Padding(
                padding:
                    EdgeInsets.only(top: 40, right: 40, left: 40, bottom: 0),
                child: HomeScreenTitle(),
              ),

              /* Seekbar */
              Expanded(
                child: Padding(
                    padding: const EdgeInsets.only(
                        top: 20, left: 60, right: 60, bottom: 0),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ValueListenableBuilder(
                              valueListenable: _position,
                              builder: (BuildContext context,
                                  Duration _position, Widget child) {
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
                              }),
                        ])),
              ),

              /* Controls */
              Padding(
                padding: const EdgeInsets.only(
                    top: 20, left: 60, right: 60, bottom: 0),
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
            ])));
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
    return ClipRRect(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15), topRight: Radius.circular(15)),
        child: Container(
            height: 75,
            decoration: BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15))),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                /* Play icon */
                Container(
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
                Expanded(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                      ValueListenableBuilder(
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
                          }),
                      /* Song title */
                      HomeScreenTitle(),
                    ])),
                Image.asset(
                  playingSong.albumArt,
                  height: 75,
                  fit: BoxFit.fitHeight,
                )
              ],
            )));
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
      body: SlidingUpPanel(
          isDraggable: true,
          minHeight: 75,
          maxHeight: 725,
          color: Colors.transparent,
          collapsed: MyPlayerHome(),
          panel: ExpandedPlayer(),
          body: this._getSongs(albums[widget.albumIndex])),
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
