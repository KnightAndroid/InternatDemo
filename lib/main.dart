import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/foundation.dart' show SynchronousFuture;

void main() => runApp(MyApp());
//创建key值，就是为了调用外部方法
GlobalKey<ChangeLocalizationsState> changeLocalizationStateKey = new GlobalKey<ChangeLocalizationsState>();
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        DemoLocalizationsDelegate.delegate,//添加
      ],
      supportedLocales: [
        const Locale('en','US'), //英文
        const Locale('zh','CH'), //中文
      ],
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:new Builder(builder: (context){
        //通过 Localizations.override 包裹一层。---这里
        //将 ChangeLocalizations 使用到 MaterialApp 中
        return new ChangeLocalizations(
           key:changeLocalizationStateKey,
           child: new MyHomePage(),
        );
      }),
     //  home: MyHomePage(),//这里需要更改
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);


  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool flag = true;
  //弹出时间框
  void _showTimeDialog(){
    //DatePacker 是flutter自带的日期组件
    showDatePicker(
        context: context,//上下文
        initialDate: new DateTime.now(),//初始今天
        firstDate: new DateTime.now().subtract(new Duration(days: 30)),//日期范围，什么时候开始(距离今天前30天)
        lastDate: new DateTime.now().add(new Duration(days: 30)),//日期范围 结束时间，什么时候结束(距离今天后30天)
        ).then((DateTime val){
          print(val);
    }).catchError((e){
          print(e);
    });

  }

  //语言切换
  void changeLocale(){
    if(flag){
      changeLocalizationStateKey.currentState.changeLocale(const Locale('zh','CH'));
    }else{
      changeLocalizationStateKey.currentState.changeLocale(const Locale('en','US'));
    }
    flag = !flag;
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(DemoLocalizations.of(context).titlebarTitle),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: changeLocale,
        tooltip: DemoLocalizations.of(context).increment,//这里需要替换
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

//Localizations类 用于语言资源整合
class DemoLocalizations{
  final Locale locale;//该Locale类是用来识别用户的语言环境

  DemoLocalizations(this.locale);

  //根据不同locale.languageCode 加载不同语言对应
  static Map<String,Map<String,String>> localizedValues = {
    //中文配置
    'zh':{
      'titlebar_title':'Flutter 例子主页面',
      'increment':'增加'
    },

    //英文配置
    'en':{
      'titlebar_title':'Flutter Demo Home Page',
      'increment':'Increment'
    }
  };

  //返回标题
  get titlebarTitle{
    return localizedValues[locale.languageCode]['titlebar_title'];
  }

  //返回增加
 get increment{
   return localizedValues[locale.languageCode]['increment'];
 }

  //此处
  static DemoLocalizations of(BuildContext context){
    return Localizations.of(context, DemoLocalizations);
  }
}

//这个类用来初始化DemoLocalizations对象
//DemoLocalizationsDelegate略有不同。它的load方法返回一个SynchronousFuture， 因为不需要进行异步加载。
class DemoLocalizationsDelegate extends LocalizationsDelegate<DemoLocalizations>{

  const DemoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en','zh'].contains(locale.languageCode);
  }


  //DemoLocalizations就是在此方法内被初始化的。
  @override
  Future<DemoLocalizations> load(Locale locale) {
    return new SynchronousFuture<DemoLocalizations>(new DemoLocalizations(locale));
  }

  @override
  bool shouldReload(LocalizationsDelegate<DemoLocalizations> old) {
    return false;
  }

  static LocalizationsDelegate delegate = const DemoLocalizationsDelegate();
}


//自定义类 用来应用内切换
class ChangeLocalizations extends StatefulWidget{
  final Widget child;
  ChangeLocalizations({Key key,this.child}) : super(key:key);

  @override
  ChangeLocalizationsState createState() => ChangeLocalizationsState();
}



class ChangeLocalizationsState extends State<ChangeLocalizations>{
  //初始是中文
  Locale _locale = const Locale('zh','CH');
  changeLocale(Locale locale){
    setState(() {
      _locale = locale;
    });
  }
  //通过Localizations.override 包裹我们需要构建的页面
  @override
  Widget build(BuildContext context){
    //通过Localizations 实现实时多语言切换
    //通过 Localizations.override 包裹一层。---这里
    return new Localizations.override(
        context: context,
        locale:_locale,
        child: widget.child,
    );
  }
}




