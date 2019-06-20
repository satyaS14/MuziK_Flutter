// import 'package:flutter/material.dart';
// import 'package:flute_music_player/flute_music_player.dart';
// import 'dart:ui';

// class myAlbum extends StatelessWidget {
//   var albumData;

//   myAlbum({this.albumData});

//   @override
//   Widget build(BuildContext context) {
//     return albumNSongs(this.albumData);
//   }
// }

// class albumNSongs extends StatefulWidget {
//   var albumData;
//   albumNSongs(var data) {
//     this.albumData = data;
//   }
//   @override
//   albumNSongsState createState() {
//     return albumNSongsState();
//   }
// }

// enum PlayerState { stopped, playing, paused }

// class albumNSongsState extends State<albumNSongs> {
//   MusicFinder audioPlayer;
//   PlayerState playerState = PlayerState.stopped;

//   bool isSameSong = false;
//   Song playingSong = new Song(null, null, null, null, null, null, null, null);

//   Duration _duration = new Duration();
//   Duration _position = new Duration();

//   Color _color = Colors.white;

//   var songTitle = null;
//   var cardIndex = 0;
//   ScrollController scrollController;
//   IconData icon = Icons.play_arrow;

//   @override
//   void initState() {
//     super.initState();
//     scrollController = new ScrollController();
//     this.audioPlayer = new MusicFinder();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomPadding: false,
//       appBar: AppBar(
//         title: Text("MuZikk"),
//       ),
//       body: this._getSongs(widget.albumData),
//     );
//   }

//   Widget _getSongs(var data) {
//     if (isSameSong) {
//       _color = Colors.white;
//     } else {
//       _color = Color(0xFFf08f8f);
//     }

//     audioPlayer.setDurationHandler((Duration d) => setState(() {
//           _duration = d;
//         }));

//     audioPlayer.setPositionHandler((Duration p) => setState(() {
//           if (isSameSong) {
//             _position = p;
//           } else {
//             _position = Duration(seconds: 0);
//           }
//         }));

//     audioPlayer.setCompletionHandler(() {
//       setState(() {
//         playerState = PlayerState.stopped;

//         if (isSameSong) {
//           _position = Duration(seconds: 0);
//           icon = Icons.play_arrow;
//         }
//       });
//     });

//     this.songTitle = data["songs"][cardIndex].title;

//     return new Column(children: [
//       new Expanded(
//           child: new Container(
//               decoration: new BoxDecoration(
//                   image: new DecorationImage(
//                       image: new AssetImage(data["thumbnail"]),
//                       fit: BoxFit.cover)),
//               child: new BackdropFilter(
//                   filter: new ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
//                   child: Padding(
//                     padding: const EdgeInsets.all(20.0),
//                     child: new Hero(
//                       tag: data["albumName"],
//                       child: new Center(
//                           child: new Container(
//                               child: ListView.builder(
//                                   physics: NeverScrollableScrollPhysics(),
//                                   itemCount: data["songs"].length,
//                                   controller: scrollController,
//                                   scrollDirection: Axis.horizontal,
//                                   itemBuilder: (context, position) {
//                                     return GestureDetector(
//                                         child: Padding(
//                                           padding: const EdgeInsets.all(20.0),
//                                           child: Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment.center,
//                                               children: [
//                                                 Container(
//                                                     width: 300,
//                                                     child: new ClipRRect(
//                                                         borderRadius:
//                                                             BorderRadius
//                                                                 .circular(20),
//                                                         child: Image.asset(
//                                                             data["thumbnail"],
//                                                             fit: BoxFit
//                                                                 .contain))),
//                                               ]),
//                                         ),
//                                         onHorizontalDragEnd: (details) {
//                                           if (details
//                                                   .velocity.pixelsPerSecond.dx >
//                                               0) {
//                                             if (cardIndex > 0) cardIndex--;
//                                           } else {
//                                             if (cardIndex <
//                                                 data["songs"].length - 1)
//                                               cardIndex++;
//                                           }
//                                           setState(() {
//                                             if (playingSong.title != null &&
//                                                 data["songs"][cardIndex]
//                                                         .title ==
//                                                     playingSong.title) {
//                                               isSameSong = true;

//                                               if (playerState ==
//                                                       PlayerState.paused ||
//                                                   playerState ==
//                                                       PlayerState.stopped) {
//                                                 icon = Icons.play_arrow;
//                                               } else if (playerState ==
//                                                   PlayerState.playing) {
//                                                 icon = Icons.pause;
//                                               }
//                                             } else {
//                                               isSameSong = false;
//                                               icon = Icons.play_arrow;
//                                             }

//                                             scrollController.animateTo(
//                                                 (cardIndex) * 340.0,
//                                                 duration:
//                                                     Duration(milliseconds: 300),
//                                                 curve: Curves.fastOutSlowIn);
//                                           });
//                                         });
//                                   }))),
//                       transitionOnUserGestures: true,
//                     ),
//                   )))),

//       /* Song title and controls */
//       new Container(
//           width: double.infinity,
//           child: new Material(
//               color: Color(0xFFf08f8f),
//               shadowColor: Colors.white,
//               child: new Column(children: <Widget>[
//                 /* Seek bar */
//                 Padding(
//                   padding: const EdgeInsets.only(
//                       top: 30.0, left: 30.0, right: 30.0, bottom: 10.0),
//                   child: Slider(
//                     activeColor: Colors.white,
//                     inactiveColor: Colors.white30,
//                     value: _position.inSeconds.toDouble(),
//                     min: 0.0,
//                     max: _duration.inSeconds.toDouble(),
//                     onChanged: (double newValue) {
//                       if (isSameSong) {
//                         audioPlayer.seek(newValue);
//                       }
//                     },
//                   ),
//                 ),
//                 new Padding(
//                     padding: EdgeInsets.all(15),
//                     child: new Column(children: <Widget>[
//                       /* Song title */
//                       new Padding(
//                         padding: EdgeInsets.only(top: 10.0),
//                         child: Text(
//                           this.songTitle,
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                             wordSpacing: 2,
//                             letterSpacing: 1.5,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                       new Padding(
//                           padding: EdgeInsets.only(top: 20.0, bottom: 5.0),
//                           child: new Row(
//                             children: <Widget>[
//                               new Expanded(child: new Container()),
//                               new IconButton(
//                                   splashColor: Color(0xFFf08f8f),
//                                   highlightColor: Colors.transparent,
//                                   icon: new Icon(Icons.skip_previous,
//                                       color: _color),
//                                   onPressed: () {}),
//                               new Expanded(child: new Container()),
//                               new RawMaterialButton(
//                                 shape: CircleBorder(),
//                                 fillColor: Colors.white,
//                                 splashColor: Color(0xFFf08f8f),
//                                 highlightColor: Color(0xFFf08f8f),
//                                 elevation: 5.0,
//                                 highlightElevation: 5.0,
//                                 onPressed: () {
//                                   setState(() {
//                                     if (icon == Icons.play_arrow) {
//                                       icon = Icons.pause;
//                                       playerState = PlayerState.playing;
//                                       playingSong = data["songs"][cardIndex];
//                                     } else if (icon == Icons.pause) {
//                                       icon = Icons.play_arrow;
//                                       playerState = PlayerState.paused;
//                                     }

//                                     if (playerState == PlayerState.stopped) {
//                                       audioPlayer.stop();
//                                     } else if (playerState ==
//                                         PlayerState.playing) {
//                                       if (!(isSameSong)) {
//                                         audioPlayer.stop();
//                                         isSameSong = true;
//                                       }
//                                       audioPlayer.play(
//                                           data["songs"][cardIndex].uri,
//                                           isLocal: true);
//                                     } else if (playerState ==
//                                         PlayerState.paused) {
//                                       audioPlayer.pause();
//                                     }
//                                   });
//                                 },
//                                 child: Icon(icon, color: Color(0xFFf08f8f)),
//                               ),
//                               new Expanded(child: new Container()),
//                               new IconButton(
//                                   splashColor: Colors.transparent,
//                                   highlightColor: Colors.transparent,
//                                   icon:
//                                       new Icon(Icons.skip_next, color: _color),
//                                   onPressed: () {}),
//                               new Expanded(child: new Container())
//                             ],
//                           ))
//                     ]))
//               ])))
//     ]);
//   }
// }

// Widget getSongCards(var data, int pos) {
//   Widget card = new ClipRRect(
//       borderRadius: new BorderRadius.circular(20.0),
//       child: new Image(
//         image: new AssetImage(data["thumbnail"]),
//         fit: BoxFit.cover,
//       ));
//   return card;
// }
