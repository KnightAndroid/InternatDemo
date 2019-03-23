## 一、国际化一(跟随手机系统语言)
一个app中使用国际化已经很普遍的操作了，如果应用可能会给另一种语言的用户(美国，英国)使用，他们看不懂中文，那这时候就要提供国际化功能，使应用的语言切到英文环境下。下面举个弹出日期控件例子：
```java
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
```
系统默认的语言环境是中文，但是实际运行的显示文字是英文的，效果如下：

![日期控件](https://user-gold-cdn.xitu.io/2019/3/21/1699f2e99cfc273c?w=709&h=1260&f=png&s=80774)
下面一步一实现组件国际化：
### 添加依赖flutter_localizations
在默认情况下，Flutter仅提供美国英语本地化，就是默认不支持多语言，即使用户在中文环境下，显示的文字仍然是英文。要添加对其他语言的支持，应用必须制定其他**MaterialApp**属性，并在`pubspec.yaml`下添加依赖：
```java
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations: ----->添加，这个软件包可以支持接近20种语言
    sdk: flutter -----》添加
```
记得运行点击右上角的`Packages get`或者直接运行`flutter packages get`

### 1.添加localizationsDelegates和supportedLocales
在`MaterialApp`里指定(添加)**localizationsDelegates**和**supportedLocales**，如下：
```java
import 'package:flutter_localizations/flutter_localizations.dart';--->记得导库
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //添加-----
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en','US'), //英文
        const Locale('zh','CH'), //中文
      ],
      //--------添加结束
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
```
然后重新运行，效果如下：

![中文日期](https://user-gold-cdn.xitu.io/2019/3/21/1699fac83ba1f94b?w=343&h=609&f=png&s=36156)，发现了确实变成中文了，系统语言中文下会显示中文，系统语言下英文下会显示英文，但是这里也发现两个问题：
* 3月21日周四高度太高了，溢出，到时候要看源码来解决了，实在不行后面自己写个组件。
* Titlebar也就是`Flutter Demo Home Page`没有变成中文，这里可以想的到，因为框架不知道翻译这句话。

### 2.多国语言资源整合
那下面来实现多语言，需要用到`GlobalMaterialLocalizations`，首先要准备在应用中用到的字符串，针对上述例子，用到了下面这个字符串：
* Flutter Demo Home Page
* Increment

下面只增加中文类型的切换，那么上面的英文依次对应：
* Flutter 例子主页面
* 增加
下面为应用的本地资源定义一个类，将所有这些放在一起用于国际化应用程序通常从封装应用程序本地化值的类开始，下面`DemoLocalizations`这个类包含程序的字符串，该字符串被翻译应用程序所支持的语言环境：
```java
//DemoLocalizations类 用于语言资源整合
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
}
```
当拿到**Localizations**实例对象，就可以调用`titlebarTitle`、`increment`方法来获取对应的字符串。

### 3.实现LocalizationsDelegate类
当定义完DemoLocalizations类后，下面就是要初始化，初始化是交给`LocalizationsDelegate`这个类，而这个类是抽象类，需要实现：
```java
//这个类用来初始化DemoLocalizations对象
//DemoLocalizationsDelegate略有不同。它的load方法返回一个SynchronousFuture， 因为不需要进行异步加载。
class DemoLocalizationsDelegate extends LocalizationsDelegate<DemoLocalizations>{

  const DemoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en','zh'].contains(locale.languageCode);
  }

  //DemoLocalizations就是在此方法内被初始化的。
  //通过方法的 locale 参数，判断需要加载的语言，然后返回自定义好多语言实现类DemoLocalizations
  //最后通过静态 delegate 对外提供 LocalizationsDelegate。
  @override
  Future<Localizations> load(Locale locale) {
    return new SynchronousFuture<DemoLocalizations>(new DemoLocalizations(locale));
  }

  @override
  bool shouldReload(LocalizationsDelegate<DemoLocalizations> old) {
    return false;
  }

  static LocalizationsDelegate delegate = const DemoLocalizationsDelegate();
}
```
### 4.添加DemoLocalizationsDelegate 添加进 MaterialApp
```java
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
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
```
### 5.设置Localizations widget
那下面怎么使用`DemoLocalizations`呢，这时候就要用到`Localizations`，`Localizations`用于加载和查找包含本地化值的集合的对象，应用程序通过`Localizations.of(context,type)`来引用这些对象，如果区域设备的区域设置发生更改，则`Localizations`这个组件会自动加载新区域设置的值，然后重新构建使用它们的`widget`。`DemoLocalizationsDelegate` 这个类的对象虽然被传入了 `MaterialApp`，但由于 MaterialApp 会在内部嵌套`Localizations`，而上面`LocalizationsDelegates`是构造函数的参数：
```java
  Localizations({
    Key key,
    @required this.locale,
    @required this.delegates,//需要传入LocalizationsDelegates
    this.child,
  }) : assert(locale != null),
       assert(delegates != null),
       assert(delegates.any(
               (LocalizationsDelegate<dynamic> delegate)//构造DemoLocalizations实例
                 => delegate is LocalizationsDelegate<WidgetsLocalizations>)
             ),
       super(key: key);
```
通过上面可以知道，要使用`DemoLocalizations`需要通过`Localizations`中的`LocalizationsDelegate`实例化，应用中要使用`DemoLocalizations`就要通过`Localizations`来获取：
```java
Localizations.of(context, DemoLocalizations);
```
将上面的代码放进`DemoLocalizations`中：
```java
  ....
  //返回标题
  get titlebarTitle{
    return localizedValues[locale.languageCode]['titlebar_title'];
  }

  //返回增加
 get increment{
   return localizedValues[locale.languageCode]['increment'];
 }

  //加入这个静态方法，方法返回DemoLocalizations实例
  static DemoLocalizations of(BuildContext context){
    return Localizations.of(context, DemoLocalizations);
  }
```
下面就要使用`DemoLocalizations`了，把代码字符串换成如下：
```java
home: MyHomePage(title: DemoLocalizations.of(context).titlebarTitle),//这里需要更改
...
tooltip: DemoLocalizations.of(context).increment,//这里需要替换

```
替换完，运行看看效果：

报空指针异常：**NoSuchMethodError：The getter 'titlebarTitle' was called on null**，也就是没有拿到`DemoLocalizations`对象，问题肯定出在`Localizations.of`，进去源码：
```java
  static T of<T>(BuildContext context, Type type) {
    assert(context != null);
    assert(type != null);
    final _LocalizationsScope scope = context.inheritFromWidgetOfExactType(_LocalizationsScope);
    return scope?.localizationsState?.resourcesFor<T>(type);
  }
```
注意看**context.inheritFromWidgetOfExactType(_LocalizationsScope)**;这一行代码，继续点进去看：

`InheritedWidget inheritFromWidgetOfExactType(Type targetType, { Object aspect });`,然后到这里再查`_LocalizationsScope`对象的类型：
```java
//继承InheritedWidget
class _LocalizationsScope extends InheritedWidget {
  const _LocalizationsScope ({
    Key key,
    @required this.locale,
    @required this.localizationsState,
    @required this.typeTo
    ....
```

![继承关系](https://user-gold-cdn.xitu.io/2019/3/23/169a9f7f6118ae7f?w=517&h=202&f=png&s=23816)
那报错的信息很明显了：也就是找不到`_LocalizationsScope`，调用`titlebarTitle`的方法的context是最外层build方法传入的，而在之前说过 Localizations 这个组件是在 MaterialApp 中被嵌套的，也就是说能找到 DemoLocalizations 的 context 至少需要是 MaterialApp 内部的，而此时的 context 是无法找到 DemoLocalizations 对象的。那下面就简单了，去掉`MyHomePage`构造方法和把`title`去掉，放进`AppBar`里赋值：
```java
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(DemoLocalizations.of(context).titlebarTitle),//这里增加
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showTimeDialog,
        tooltip: DemoLocalizations.of(context).increment,//这里需要替换
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
```
效果图如下：

![国际化最终效果图](https://user-gold-cdn.xitu.io/2019/3/23/169aa0a853d1ab4d?w=663&h=650&f=png&s=28779)

## 二、国际化二(应用内切换)
下面简单实现在应用内自由切换语言的功能，首先自定义`ChangeLocalizations`的Widget，然后通过`Localizations.override`来嵌套需要构建的页面，里面需要实现一个切换语言的方法，也就是根据条件来改变`Locale`，初始化设置为中文：
```java
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
```

接着当调用`changeLocale`方法就改变语言，`ChangeLocalizations`外部去调用其方法需要使用到`GlobalKey` 的帮助:
```java
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
```
最后调用：
```java
  //语言切换
  void changeLocale(){
    if(flag){
      changeLocalizationStateKey.currentState.changeLocale(const Locale('zh','CH'));
    }else{
      changeLocalizationStateKey.currentState.changeLocale(const Locale('en','US'));
    }
    flag = !flag;
  }
```
最后效果：

![应用内切换](https://user-gold-cdn.xitu.io/2019/3/23/169aaaa114ee811d?w=370&h=784&f=gif&s=28316)
