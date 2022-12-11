import 'package:flutter/cupertino.dart';
import 'package:zmrd/ui/home/widgets/slider_images.dart';
import 'package:zmrd/utils/app_colors.dart';
import 'package:zmrd/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:zmrd/custom_widgets/ad_item/ad_item.dart';
import 'package:zmrd/custom_widgets/no_data/no_data.dart';
import 'package:zmrd/custom_widgets/safe_area/page_container.dart';
import 'package:zmrd/locale/app_localizations.dart';

import 'package:zmrd/models/ad.dart';
import 'package:zmrd/models/category.dart';
import 'package:zmrd/models/city.dart';
import 'package:zmrd/models/marka.dart';
import 'package:zmrd/models/model.dart';
import 'package:zmrd/providers/home_provider.dart';
import 'package:zmrd/providers/navigation_provider.dart';
import 'package:zmrd/ui/ad_details/ad_details_screen.dart';
import 'package:zmrd/ui/home/widgets/category_item.dart';
import 'package:zmrd/ui/home/widgets/map_widget.dart';
import 'package:zmrd/ui/search/search_bottom_sheet.dart';
import 'package:zmrd/utils/app_colors.dart';
import 'package:zmrd/ui/account/account_screen.dart';
import 'package:provider/provider.dart';
import 'package:zmrd/utils/error.dart';
import 'package:zmrd/providers/navigation_provider.dart';
import 'package:zmrd/providers/auth_provider.dart';
import 'package:zmrd/custom_widgets/drop_down_list_selector/drop_down_list_selector.dart';
import 'package:zmrd/custom_widgets/MainDrawer.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  double _height = 0, _width = 0;
  NavigationProvider _navigationProvider;
  Future<List<CategoryModel>> _categoryList;
  Future<List<CategoryModel>> _subList;
  bool _initialRun = true;
  HomeProvider _homeProvider;
  AnimationController _animationController;
  AuthProvider _authProvider;

  Future<List<City>> _cityList;
  City _selectedCity;

  Future<List<Marka>> _markaList;
  Marka _selectedMarka;

  Future<List<Model>> _modelList;
  Model _selectedModel;

  CategoryModel _selectedSub;
  String _selectedCat;
  bool _isLoading = false;

  String _xx=null;
  String omar="";

  @override
  void initState() {
    _animationController = AnimationController(
        duration: Duration(milliseconds: 2000), vsync: this);
    super.initState();

  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialRun) {
      _homeProvider = Provider.of<HomeProvider>(context);
      _categoryList = _homeProvider.getCategoryList(categoryModel:  CategoryModel(isSelected:true ,catId: '0',catName:
      _homeProvider.currentLang=="ar"?"الكل":"ALl",catImage: 'assets/images/all.png'),enableSub: false);


      _subList = _homeProvider.getSubList(enableSub: false,catId:_homeProvider.age!=''?_homeProvider.age:"6");


      _cityList = _homeProvider.getCityList(enableCountry: false);
      _markaList = _homeProvider.getMarkaList();
      _modelList = _homeProvider.getModelList();
      _initialRun = false;
    }
  }


  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildBodyItem() {
    return ListView(

      padding: EdgeInsets.all(0),
      children: <Widget>[
        FutureBuilder<String>(
            future: Provider.of<HomeProvider>(context,
                listen: false)
                .getOmar() ,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return Center(
                    child: SpinKitFadingCircle(color: Colors.black),
                  );
                case ConnectionState.active:
                  return Text('');
                case ConnectionState.waiting:
                  return Center(
                    child: SpinKitFadingCircle(color: Colors.black),
                  );
                case ConnectionState.done:
                  if (snapshot.hasError) {
                    return Error(
                      //  errorMessage: snapshot.error.toString(),
                      errorMessage: AppLocalizations.of(context).translate('error'),
                    );
                  } else {
                    omar=snapshot.data;

                    return  Row(
                      children: <Widget>[

                        Text("",style: TextStyle(height: 0),)
                      ],
                    );
                  }
              }
              return Center(
                child: SpinKitFadingCircle(color: mainAppColor),
              );
            }),

SizedBox(height: _height*.01,),
        SliderImages(),
        Container(
            height: _height * 0.18,
            color: Color(0xffeef4f6),
            padding: EdgeInsets.fromLTRB(5,5,5,0),
            child: FutureBuilder<List<CategoryModel>>(
                future: _categoryList,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                      return Center(
                        child: SpinKitFadingCircle(color: mainAppColor),
                      );
                    case ConnectionState.active:
                      return Text('');
                    case ConnectionState.waiting:
                      return Center(
                        child: SpinKitFadingCircle(color: mainAppColor),
                      );
                    case ConnectionState.done:
                      if (snapshot.hasError) {
                        return Error(
                          //  errorMessage: snapshot.error.toString(),
                          errorMessage: "حدث خطأ ما ",
                        );
                      } else {
                        if (snapshot.data.length > 0) {
                          return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: snapshot.data.length,
                              itemBuilder: (BuildContext context, int index) {

                                return Consumer<HomeProvider>(
                                    builder: (context, homeProvider, child) {
                                      return InkWell(
                                        onTap: (){


                                          _homeProvider
                                              .updateChangesOnCategoriesList(index);

                                          _homeProvider.setEnableSearch(false);

                                          _homeProvider.setSelectedCat(snapshot.data[index]);
                                          print(_homeProvider.selectedCat);

                                          _selectedSub=null;
                                          _selectedMarka=null;
                                          _selectedModel=null;
                                          _selectedCity=null;
                                          _homeProvider.setSelectedSub(_selectedSub);
                                          _homeProvider.setSelectedMarka(_selectedMarka);
                                          _homeProvider.setSelectedModel(_selectedModel);
                                          _homeProvider.setSelectedCity(_selectedCity);



                                          _homeProvider.setSelectedCat(snapshot.data[index]);
                                          _homeProvider.setAge(snapshot.data[index].catId);

                                          _xx=_homeProvider.selectedCat.catId;
                                          _subList = _homeProvider.getSubList(enableSub: true,catId:_homeProvider.age!=''?_homeProvider.age:"6");



                                        },
                                        child: Container(

                                          color: Color(0xffeef4f6),
                                          width: _width * 0.25,
                                          child: CategoryItem(
                                            category: snapshot.data[index],
                                          ),
                                        ),
                                      );
                                    });
                              });
                        } else {
                          return NoData(message: 'لاتوجد نتائج');
                        }
                      }
                  }
                  return Center(
                    child: SpinKitFadingCircle(color: mainAppColor),
                  );
                })),


        SizedBox(height: 10,),
        Container(
          margin: EdgeInsets.only(right: _width*.04),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Image.asset('assets/images/prev.png'),
              Padding(padding: EdgeInsets.all(3)),
              Text(_homeProvider.currentLang=="ar"?"أحدث الاعلانات":"Last Ads",style: TextStyle(fontWeight: FontWeight.bold,color: CupertinoColors.black),),
              Text(_homeProvider.currentLang=="ar"?"المضافة":"added",style: TextStyle(color: mainAppColor),),
            ],
          ),
        ),
        Padding(padding: EdgeInsets.all(3)),

        Container(
            height: _height*.55,
            width: _width,
            child:
            Consumer<HomeProvider>(builder: (context, homeProvider, child) {
              return FutureBuilder<List<Ad>>(
                  future: homeProvider.enableSearch
                      ? Provider.of<HomeProvider>(context, listen: true)
                      .getAdsSearchList()
                      : Provider.of<HomeProvider>(context, listen: true)
                      .getAdsList(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                        return Center(
                          child: SpinKitFadingCircle(color: mainAppColor),
                        );
                      case ConnectionState.active:
                        return Text('');
                      case ConnectionState.waiting:
                        return Center(
                          child: SpinKitFadingCircle(color: mainAppColor),
                        );
                      case ConnectionState.done:
                        if (snapshot.hasError) {
                          return Error(
                            errorMessage: snapshot.error.toString(),
                            //errorMessage: "حدث خطأ ما ",
                          );
                        } else {
                          if (snapshot.data.length > 0) {

                            return ListView.builder(
                                itemCount: snapshot.data.length,
                                itemBuilder:
                                    (BuildContext context, int index) {
                                  var count = snapshot.data.length;
                                  var animation =
                                  Tween(begin: 0.0, end: 1.0).animate(
                                    CurvedAnimation(
                                      parent: _animationController,
                                      curve: Interval(
                                          (1 / count) * index, 1.0,
                                          curve: Curves.fastOutSlowIn),
                                    ),
                                  );
                                  _animationController.forward();
                                  return Container(
                                      height: 125,
                                      width: _width,
                                      child: InkWell(
                                          onTap: () {
                                            _homeProvider.setCurrentAds(snapshot
                                                .data[index].adsId);
                                            _homeProvider.setOmarKey(omar);
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        AdDetailsScreen(
                                                          ad: snapshot
                                                              .data[index],
                                                        )));
                                          },
                                          child: AdItem(
                                            animationController:
                                            _animationController,
                                            animation: animation,
                                            ad: snapshot.data[index],
                                          )));
                                });

                          } else {
                            return NoData(message: 'لاتوجد نتائج');
                          }
                        }
                    }
                    return Center(
                      child: SpinKitFadingCircle(color: mainAppColor),
                    );
                  });
            }))

      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _navigationProvider = Provider.of<NavigationProvider>(context);
    _authProvider = Provider.of<AuthProvider>(context);

    final appBar = AppBar(
      elevation: 0,
      backgroundColor: mainAppColor,
      titleSpacing: 0,
      centerTitle: true,
      title: _authProvider.currentLang == 'ar' ? Text("الرئيسية",style: TextStyle(fontSize: 17),) :Text("Home",style: TextStyle(fontSize: 17)),
      actions: <Widget>[
        GestureDetector(
            onTap: () {
              showModalBottomSheet<dynamic>(
                  isScrollControlled: true,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20))),
                  context: context,
                  builder: (builder) {
                    return Container(
                        width: _width,
                        height: _height * 0.55,
                        child: SearchBottomSheet());
                  });
            },
            child:Image.asset(
              'assets/images/search.png',
              color: Colors.white,
            )),


      ],
    );
    _height = MediaQuery.of(context).size.height -
        appBar.preferredSize.height -
        MediaQuery.of(context).padding.top;
    _width = MediaQuery.of(context).size.width;
    _navigationProvider = Provider.of<NavigationProvider>(context);

    return PageContainer(
      child:  WillPopScope(
          onWillPop: () async {


            // This dialog will exit your app on saying yes
            return (await showDialog(
              context: context,
              builder: (context) => new AlertDialog(
                title: new Text(_homeProvider.currentLang=="ar"?'هل انت متاكد ؟':'are you sure ?'),
                content: new Text(_homeProvider.currentLang=="ar"?'هل تريد بالفعل الخروج من التطبيق ؟':'Do you really want to exit the application?'),
                actions: <Widget>[
                  new FlatButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: new Text(_homeProvider.currentLang=="ar"?'لا':'no'),
                  ),
                  new FlatButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: new Text(_homeProvider.currentLang=="ar"?'نعم':'yes'),
                  ),
                ],
              ),
            )) ??
                false;
          },
          child: Scaffold(

            appBar: PreferredSize(child: appBar,  preferredSize: Size.fromHeight(40.0)),

            drawer: MainDrawer(),
            body: _buildBodyItem(),
          )),
    );
  }
}
