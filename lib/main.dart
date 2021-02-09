import 'dart:io';

import 'package:flutter/cupertino.dart' hide Router;
import 'package:flutter/material.dart' hide Router;
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:jh_flutter_demo/project/new_feature/new_feature_page.dart';
import 'package:package_info/package_info.dart';

import 'package:flustars/flustars.dart';
import 'package:oktoast/oktoast.dart';
import 'package:fluro/fluro.dart';

import 'project/configs/colors.dart';
import 'project/routes/routes_old.dart' as luyou;
import 'project/routes/routes.dart';
import 'project/routes/application.dart';
import 'project/base_tabbar.dart';
import 'project/login/pages/login_page.dart';
import 'project/model/user_model.dart';
import 'project/configs/project_config.dart';
import 'jh_common/utils/jh_storage_utils.dart';
import 'jh_common/widgets/jh_alert.dart';

/**
    屏幕宽度高度：MediaQuery.of(context).size.width
    屏幕宽度高度：MediaQuery.of(context).size.height
    屏幕状态栏高度：MediaQueryData.fromWindow(WidgetBinding.instance.window).padding.top。

    MediaQueryData mq = MediaQuery.of(context);
    // 屏幕密度
    pixelRatio = mq.devicePixelRatio;
    // 屏幕宽(注意是dp, 转换px 需要 screenWidth * pixelRatio)
    screenWidth = mq.size.width;
    // 屏幕高(注意是dp)
    screenHeight = mq.size.height;
    // 顶部状态栏, 随着刘海屏会增高
    statusBarHeight = mq padding.top;
    // 底部功能栏, 类似于iPhone XR 底部安全区域
    bottomBarHeight = mq.padding.bottom;

 * */

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SpUtil.getInstance();

//  debugProfileBuildsEnabled = true;
//  debugPaintLayerBordersEnabled = true;
//  debugProfilePaintsEnabled = true;
//  debugRepaintRainbowEnabled = true;

  runApp(MyApp());

  if (Platform.isAndroid) {
    print("Android");
  } else if (Platform.isIOS) {
    print("iOS");
  }

  // 透明状态栏
  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle =
        SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var _currentVersion = '';

  @override
  void initState() {
    super.initState();

    LogUtils.init();
    final Router router = Router();
    Routes.configureRoutes(router);
    Application.router = router;
    _getInfo(); //获取设备信息
  }

  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: Container(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: KColor.kWeiXinThemeColor, //主色，决定导航栏颜色
            accentColor: KColor.kWeiXinTitleColor,
            primaryIconTheme: IconThemeData(color: KColor.kWeiXinTitleColor),
          ),
          home: switchRootWidget(),
          onGenerateRoute: Application.router.generator,
          onUnknownRoute: (RouteSettings settings) =>
              MaterialPageRoute(builder: (context) => luyou.UnknownPage()),
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            const FallbackCupertinoLocalisationsDelegate()
          ],
          supportedLocales: [
            Locale('zh', 'CN'),
          ],
        ),
      ),
    );
  }

  void _getInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    print('>>>>>>>>> app info:');
    print(packageInfo.appName);
    print(packageInfo.buildNumber);
    print(packageInfo.packageName);
    print(packageInfo.version);
    setState(() {
      _currentVersion = packageInfo.version;
    });
  }

  Widget switchRootWidget() {
    var lastVersion = JhStorageUtils.getStringWithKey(kUserDefault_LastVersion);
    if (lastVersion == null || lastVersion == '') {
      return NewFeaturePage();
    } else {
      if (lastVersion.compareTo(_currentVersion) < 0) {
        return NewFeaturePage();
      } else {
        var modelJson = JhStorageUtils.getModelWithKey(kUserDefault_UserInfo);
        if (modelJson != null) {
          UserModel model = UserModel.fromJson(modelJson);
          print('本地取出的 userName:' + model.userName);
          return BaseTabBar();
        } else {
          return LoginPage();
        }
      }
    }
  }
}
