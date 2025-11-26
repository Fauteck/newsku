import 'package:app/feed/models/feed_item.dart';



class TimeBlockFeed {
  /// for the highest ranked news if any importance >= 90
  FeedItem? mainHeadline;

  /// the top 5 news with importance more than 80
  List<FeedItem> headlines = [];

  /// The next 10 items with importance more than 50
  List<FeedItem> notableNews = [];

  /// the rest of the stuff
  List<FeedItem> others = [];

  int get headLineListCount {
    var total = 0;

    if(mainHeadline != null){
      total++;
    }

    if(headlines.isNotEmpty){
      total++;
    }

    return total;


  }
}
