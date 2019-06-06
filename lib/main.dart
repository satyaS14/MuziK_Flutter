import 'dart:async';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flute_music_player/flute_music_player.dart';
import './albumHome.dart';
import './songData.dart';

MusicFinder audioPlayer;

void main() {
  runApp(MaterialApp(
      title: 'MuZiKKK',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        /* When we navigate to the "/" route, build the FirstScreen Widget */
        '/': (context) => myMuZik(),

        /* When we navigate to the "/album" route, build the AlbumScreen Widget */
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
  final AsyncMemoizer _memoizer = AsyncMemoizer();

  @override
  muzikState createState() {
    return muzikState();
  }
}

class muzikState extends State<muzik> {
  Future getSongs() async {
    var songs;

    return widget._memoizer.runOnce(() async {
      try {
        songs = await MusicFinder.allSongs();
      } catch (e) {
        print(e.toString());
      }
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
            List albums = buildAlbumData(snapshot.data);

            return Scaffold(
                appBar: AppBar(
                  title: Text("MuZikk"),
                ),
                // body: _buildBody(context, albums),
                body: new Column(children: <Widget>[
                  /* Albums */
                  new CustomAlbumWidget(albums: albums),

                  /* Player */
                  new CustomPlayerWidget()
                ]),
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

  Widget _buildBody(BuildContext context, var albums) {
    if (albums != null) {
      return Column(children: <Widget>[
        /* Albums */
        new CustomAlbumWidget(albums: albums),

        /* Player */
        new CustomPlayerWidget()
      ]);
    } else {
      return new CustomNoSongsWidget();
    }
  }
}

class CustomAlbumWidget extends StatelessWidget {
  final List albums;
  const CustomAlbumWidget({Key key, this.albums}) : super(key: key);

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
                  children: _buildRows(context, albums)),
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

List<Widget> _buildRows(BuildContext context, var albumData) {
  final List<Widget> gridTiles = <Widget>[];
  for (var i = 0; i < albumData.length; i++) {
    gridTiles.add(
      new CustomGridTileWidget(albumData: albumData[i]),
    );
  }
  return gridTiles;
}

class CustomGridTileWidget extends StatelessWidget {
  const CustomGridTileWidget({
    Key key,
    @required this.albumData,
  }) : super(key: key);

  final albumData;

  @override
  Widget build(BuildContext context) {
    return new GridTile(
        child: new Scaffold(
            body: new InkResponse(
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
        child: new CustomCardWidget(albumData: albumData),
      ),
      onTap: () {
        GoToAlbum(context, albumData);
      },
    )));
  }
}

GoToAlbum(BuildContext context, var albumData) async {
  audioPlayer = await Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (context, anim1, anim2) => myAlbum(albumData: albumData),
      transitionsBuilder: (context, anim1, anim2, child) =>
          FadeTransition(opacity: anim1, child: child),
      transitionDuration: Duration(milliseconds: 750),
    ),
  );
}

class CustomCardWidget extends StatelessWidget {
  CustomCardWidget({
    Key key,
    @required this.albumData,
  }) : super(key: key);

  var albumData;

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 5.0,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          new Hero(
            tag: albumData["albumName"],
            child: new Container(
                height: 185,
                decoration: new BoxDecoration(
                  borderRadius:
                      new BorderRadius.all(new Radius.elliptical(1.0, 1.0)),
                ),
                child: Center(
                    child: Image.asset(albumData["thumbnail"],
                        fit: BoxFit.fitWidth))),
            transitionOnUserGestures: true,
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.only(left: 8, top: 3, bottom: 3),
            child: Text(
              albumData["albumName"],
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: .5,
                  wordSpacing: 1),
              textAlign: TextAlign.left,
            ),
          )),
        ]));
  }
}
