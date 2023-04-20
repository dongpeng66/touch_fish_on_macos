import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Touch fish on macOS',
      home: const MyHomePage(),
      //取消debug标签
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".



  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  //巧用 late 初始化，节省代码量
  late final AnimationController _controller=AnimationController(vsync: this);
  //UI圆角
  final BorderRadius _radius = BorderRadius.circular(10);

  //启动后等待的时长
  Duration get _waitingDuration=> const Duration(seconds: 5);
  //分段的 动画时长
  List<Duration> get _periodDurations{
    return <Duration>[
      //启动等待时长
      const Duration(seconds: 5),
      //控制进度条时间
      const Duration(seconds: 40),
      const Duration(seconds: 4),

    ];
  }
  /// 当前进行到哪一个分段
  int get currentPeriod => _currentPeriod.value;
  final ValueNotifier<int> _currentPeriod = ValueNotifier<int>(1);

  set currentPeriod(int value) => _currentPeriod.value = value;

  @override
  void initState() {
    super.initState();
    Future.delayed(_waitingDuration).then((_) => _callAnimation());
  }
  @override
  void reassemble() {
    super.reassemble();
    _restart();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  //重新开始
  void _restart() {
    _controller
      ..stop()
      ..reset();
    currentPeriod = 0;
    Future.delayed(Duration(seconds: 0)).then((_) => _callAnimation());
    // Future.delayed(_waitingDuration).then((_) => _callAnimation());
    
  }


  Future<void>  _callAnimation() async{
    //获取当前分段
    final Duration _currentDuration =_periodDurations[currentPeriod];
    //准备下一分段
    currentPeriod++;
    //如果到了最后一个分段，取空
    final Duration? _nextDuration=currentPeriod<_periodDurations.length?_periodDurations.last:null;
    // 计算当前分段动画的结束值
    final double target = currentPeriod / _periodDurations.length;
    // 执行动画
    await _controller.animateTo(target, duration: _currentDuration);
    // 如果下一分段为空，即执行到了最后一个分段，重设当前分段，动画结束
    if (_nextDuration == null) {
      currentPeriod = 0;
      return;
    }
    // 否则调用下一分段的动画
    await _callAnimation();

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
      backgroundColor: CupertinoColors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 100),
              child: GestureDetector(
                onTap: _restart,
                child: Image.asset(
                  'assets/apple-logo.png',
                  color: CupertinoColors.white,
                  width: 100,
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: 200,
                alignment: Alignment.topCenter,
                child: ValueListenableBuilder<int>(
                  valueListenable: _currentPeriod,
                  builder: (_, int period, __) {
                    if (period == 0) {
                      return const SizedBox.shrink();
                    }
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(color: CupertinoColors.systemGrey),
                        borderRadius: _radius,
                      ),
                      child: ClipRRect(
                        borderRadius: _radius,
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (_, __) => LinearProgressIndicator(
                            value: _controller.value,
                            backgroundColor: CupertinoColors.lightBackgroundGray
                                .withOpacity(.3),
                            color: CupertinoColors.white,
                            minHeight: 5,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
