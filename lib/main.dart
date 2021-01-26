import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/model/articles.dart';
import 'package:news_app/network/api_request.dart';
import 'package:news_app/screens/news_detail.dart';
import 'package:news_app/screens/state/state_management.dart';
import 'package:page_transition/page_transition.dart';

import 'model/news.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/detail':
            return PageTransition(
                child: NewsDetail(),
                type: PageTransitionType.fade,
                settings: settings);
            break;
          default:
            return null;
        }
      },
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.white,
        accentColor: Colors.teal,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'News App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  final List<Tab> tabs = <Tab>[
    new Tab(
      text: 'General',
    ),
    new Tab(
      text: 'Technology',
    ),
    new Tab(
      text: 'Sports',
    ),
    new Tab(
      text: 'Business',
    ),
    new Tab(
      text: 'Entertainment',
    ),
    new Tab(
      text: 'Health',
    ),
  ];

  TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = new TabController(length: tabs.length, vsync: this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('News'),
        bottom: TabBar(
          isScrollable: true,
          unselectedLabelColor: Colors.grey,
          labelColor: Colors.white,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BubbleTabIndicator(
            indicatorColor: Colors.teal,
            indicatorHeight: 25.0,
            tabBarIndicatorSize: TabBarIndicatorSize.tab,
          ),
          tabs: tabs,
          controller: _tabController,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: tabs.map((tab) {
          return FutureBuilder(
              future: fetchNewsByCategory(tab.text),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('${snapshot.error}'),
                  );
                } else if (snapshot.hasData) {
                  var newsList = snapshot.data as News;
                  var sliderList = newsList.articles != null
                      ? newsList.articles.length > 10
                          ? newsList.articles.getRange(0, 10).toList()
                          : newsList.articles
                              .take(newsList.articles.length)
                              .toList()
                      : [];
                  var contestList = newsList.articles != null
                      ? newsList.articles.length > 10
                          ? newsList.articles
                              .getRange(11, newsList.articles.length - 1)
                              .toList()
                          : []
                      : [];
                  return SafeArea(
                      child: Column(
                    children: [
                      CarouselSlider(
                        items: sliderList.map((item) {
                          return Builder(builder: (context) {
                            return GestureDetector(
                              onTap: () {
                                context.read(urlState).state = item.url;
                                Navigator.pushNamed(context, '/detail');
                              },
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      '${item.urlToImage}',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        color: Color(0xAA333639),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            '${item.title}',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            );
                          });
                        }).toList(),
                        options: CarouselOptions(
                            aspectRatio: 16 / 9,
                            enlargeCenterPage: true,
                            viewportFraction: 0.8),
                      ),
                      Divider(
                        thickness: 3,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          'Trending*',
                          style: TextStyle(
                              fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Divider(
                        thickness: 3,
                      ),
                      Expanded(
                          child: ListView.builder(
                              itemCount: contestList.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    context.read(urlState).state =
                                        contestList[index].url;
                                    Navigator.pushNamed(context, '/detail');
                                  },
                                  child: ListTile(
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        '${contestList[index].urlToImage}',
                                        fit: BoxFit.fitWidth,
                                        height: 80,
                                        width: 80,
                                      ),
                                    ),
                                    title: Text(
                                      '${contestList[index].title}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      '${contestList[index].publishedAt}',
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                );
                              }))
                    ],
                  ));
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              });
        }).toList(),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
