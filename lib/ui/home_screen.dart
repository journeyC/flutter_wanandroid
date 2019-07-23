import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wanandroid/common/common.dart';
import 'package:flutter_wanandroid/common/user.dart';
import 'package:flutter_wanandroid/data/api/apis_service.dart';
import 'package:flutter_wanandroid/data/model/article_model.dart';
import 'package:flutter_wanandroid/data/model/base_model.dart';
import 'package:flutter_wanandroid/ui/base_widget.dart';
import 'package:flutter_wanandroid/ui/home_banner_screen.dart';
import 'package:flutter_wanandroid/utils/route_util.dart';
import 'package:flutter_wanandroid/utils/theme_util.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomeScreen extends BaseWidget {
  @override
  BaseWidgetState<BaseWidget> attachState() {
    return HomeScreenState();
  }
}

class HomeScreenState extends BaseWidgetState<HomeScreen> {
  /// 首页文章列表数据
  List<ArticleBean> _articles = new List();

  /// listview 控制器
  ScrollController _scrollController = new ScrollController();

  /// 是否显示悬浮按钮
  bool _isShowFAB = false;

  /// 页码，从0开始
  int _page = 0;

  @override
  void initState() {
    super.initState();
    setAppBarVisible(false);

    showLoading();
    getTopArticleList();

    _scrollController.addListener(() {
      /// 滑动到底部，加载更多
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        getMoreArticleList();
      }
      if (_scrollController.offset < 200 && _isShowFAB) {
        setState(() {
          _isShowFAB = false;
        });
      } else if (_scrollController.offset >= 200 && !_isShowFAB) {
        setState(() {
          _isShowFAB = true;
        });
      }
    });
  }

  /// 获取置顶文章数据
  Future<Null> getTopArticleList() async {
    ApiService().getTopArticleList((TopArticleModel topArticleModel) {
      if (topArticleModel.errorCode == Constants.STATUS_SUCCESS) {
        topArticleModel.data.forEach((v) {
          v.top = 1;
        });
        _articles.clear();
        _articles.addAll(topArticleModel.data);
      }
      getArticleList();
    }, (DioError error) {
      print(error.response);
    });
  }

  /// 获取文章列表数据
  Future<Null> getArticleList() async {
    _page = 0;
    ApiService().getArticleList((ArticleModel model) {
      if (model.errorCode == Constants.STATUS_SUCCESS) {
        if (model.data.datas.length > 0) {
          showContent();
          setState(() {
            _articles.addAll(model.data.datas);
          });
        } else {
          showEmpty();
        }
      } else {
        Fluttertoast.showToast(msg: model.errorMsg);
      }
    }, (DioError error) {
      /// 发生错误
      print(error.response);
      setState(() {
        showError();
      });
    }, _page);
  }

  /// 获取更多文章列表数据
  Future<Null> getMoreArticleList() async {
    _page++;
    ApiService().getArticleList((ArticleModel model) {
      if (model.errorCode == Constants.STATUS_SUCCESS) {
        if (model.data.datas.length > 0) {
          showContent();
          setState(() {
            _articles.addAll(model.data.datas);
          });
        } else {
          Fluttertoast.showToast(msg: "没有更多数据了");
        }
      } else {
        Fluttertoast.showToast(msg: model.errorMsg);
      }
    }, (DioError error) {
      /// 发生错误
      print(error.response);
      setState(() {
        showError();
      });
    }, _page);
  }

  @override
  AppBar attachAppBar() {
    return AppBar(
      title: Text(""),
    );
  }

  @override
  Widget attachContentWidget(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        displacement: 15,
        onRefresh: getTopArticleList,
        child: ListView.separated(
            itemBuilder: itemView,
            separatorBuilder: (BuildContext context, int index) {
              return Container(
                height: 0.5,
                color: Colors.black26,
              );
            },
            physics: new AlwaysScrollableScrollPhysics(),
            controller: _scrollController,
            // 包含轮播和加载更多
            itemCount: _articles.length + 2),
      ),
      floatingActionButton: !_isShowFAB
          ? null
          : FloatingActionButton(
              heroTag: "home",
              child: Icon(Icons.arrow_upward),
              backgroundColor: ThemeUtils.currentColorTheme,
              onPressed: () {
                /// 回到顶部时要执行的动画
                _scrollController.animateTo(0,
                    duration: Duration(milliseconds: 2000), curve: Curves.ease);
              },
            ),
    );
  }

  @override
  void onClickErrorWidget() {
    showLoading();
    getTopArticleList();
  }

  Widget itemView(BuildContext context, int index) {
    if (index == 0) {
      return Container(
        height: 200,
        color: Colors.transparent,
        child: new HomeBannerScreen(),
      );
    }

    if (index < _articles.length - 1) {
      ArticleBean item = _articles[index - 1];

      return InkWell(
        onTap: () {
          RouteUtil.toWebView(context, item.title, item.link);
        },
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Row(
                children: <Widget>[
                  Offstage(
                    offstage: item.top == 0,
                    child: Container(
                      decoration: new BoxDecoration(
                        border: new Border.all(
                            color: Color(0xFFF44336), width: 0.5),
                        borderRadius: new BorderRadius.vertical(
                            top: Radius.elliptical(2, 2),
                            bottom: Radius.elliptical(2, 2)),
                      ),
                      padding: EdgeInsets.fromLTRB(4, 2, 4, 2),
                      margin: EdgeInsets.fromLTRB(0, 0, 4, 0),
                      child: Text(
                        "置顶",
                        style: TextStyle(
                            fontSize: 10, color: const Color(0xFFF44336)),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  Offstage(
                    offstage: !item.fresh,
                    child: Container(
                      decoration: new BoxDecoration(
                        border: new Border.all(
                            color: Color(0xFFF44336), width: 0.5),
                        borderRadius: new BorderRadius.vertical(
                            top: Radius.elliptical(2, 2),
                            bottom: Radius.elliptical(2, 2)),
                      ),
                      padding: EdgeInsets.fromLTRB(4, 2, 4, 2),
                      margin: EdgeInsets.fromLTRB(0, 0, 4, 0),
                      child: Text(
                        "新",
                        style: TextStyle(
                            fontSize: 10, color: const Color(0xFFF44336)),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  Offstage(
                    offstage: item.tags.length == 0,
                    child: Container(
                      decoration: new BoxDecoration(
                        border: new Border.all(
                            color: Color(0xFF00BCD4), width: 0.5),
                        borderRadius: new BorderRadius.vertical(
                            top: Radius.elliptical(2, 2),
                            bottom: Radius.elliptical(2, 2)),
                      ),
                      padding: EdgeInsets.fromLTRB(4, 2, 4, 2),
                      margin: EdgeInsets.fromLTRB(0, 0, 4, 0),
                      child: Text(
                        item.tags.length > 0 ? item.tags[0].name : "",
                        style: TextStyle(
                            fontSize: 10, color: const Color(0xFF00BCD4)),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  Text(
                    item.author,
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.left,
                  ),
                  Expanded(
                    child: Text(
                      item.niceDate,
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      item.title,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 16,
                        // fontWeight: FontWeight.bold,
                        color: const Color(0xFF3D4E5F),
                      ),
                      textAlign: TextAlign.left,
                    ),
                  )
                ],
              ),
            ),
            Container(
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      item.superChapterName + " / " + item.chapterName,
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  InkWell(
                    child: Container(
                      child: Image(
                        // color: Colors.black12,
                        image: AssetImage(item.collect
                            ? 'images/ic_like.png'
                            : 'images/ic_like_not.png'),
                        width: 24,
                        height: 24,
                      ),
                    ),
                    onTap: () {
                      addOrCancelCollect(item);
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      );
    }
    return null;
  }

  /// 添加收藏或者取消收藏
  void addOrCancelCollect(item) {
    List<String> cookies = User.singleton.cookie;
    if (cookies == null) {
      Fluttertoast.showToast(msg: '请先登录~');
    } else {
      if (item.collect) {
        ApiService().cancelCollection((BaseModel model) {
          if (model.errorCode == Constants.STATUS_SUCCESS) {
            Fluttertoast.showToast(msg: '已取消收藏~');
            setState(() {
              item.collect = false;
            });
          } else {
            Fluttertoast.showToast(msg: '取消收藏失败~');
          }
        }, (DioError error) {
          print(error.response);
        }, item.id);
      } else {
        ApiService().addCollection((BaseModel model) {
          if (model.errorCode == Constants.STATUS_SUCCESS) {
            Fluttertoast.showToast(msg: '收藏成功~');
            setState(() {
              item.collect = true;
            });
          } else {
            Fluttertoast.showToast(msg: '收藏失败~');
          }
        }, (DioError error) {
          print(error.response);
        }, item.id);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }
}
