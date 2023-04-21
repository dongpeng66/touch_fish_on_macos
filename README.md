# touch_fish_on_macos

A new Flutter project.

## 准备工作
年轻最需要的就是行动力，想到就干，尽管我此刻正在理顺 DevFest 的讲稿，但丝毫不妨碍我用 10 分钟写一个 App。于是我打出了一套组合拳：

- 	flutter config --enable-macos-desktop
- 	flutter create --platforms=macos touch_fish_on_macos

一个支持 macOS 的 Flutter 项目就创建好了。（此时大约过去了 1 分钟）

##开始敲代码

#找到资源

我们首先需要一张高清无码的  图片，这里你可以在网上进行搜寻，有一点需要注意的是，使用 LOGO 要注意使用场景带来的版权问题。找到图片后，丢到 assets/apple-logo.png，并在 pubspec.yaml 中加上资源引用
```
flutter:
  use-material-design: true
+ assets:
+   - assets/apple-logo.png
```

#思考布局

我们来观察一下 macOS 的启动画面，有几个要点：

![dddd.png](https://github.com/dongpeng66/touch_fish_on_macos/blob/main/images/dddd.png)

- 	LOGO 在屏幕中间，固定大小约为 100dp；
- 	LOGO 与进度条间隔约 100 dp；
- 	进度条高度约 5dp，宽度约 200dp，圆角几乎完全覆盖高度，值部分为白色，背景部分为填充色+浅灰色边框。

（别问我为什么这些东西能观察出来，问就是天天教 UI 改 UI。）

确认了大概的布局模式，接下来我们开始搭布局。（此时大约过去了 2 分钟）

#实现布局

首先将 LOGO 居中、着色、设定宽度为 100，上下间隔 100：
```
return Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      const Spacer(),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 100),
        child: Image.asset(
          'assets/apple-logo.png',
          color: CupertinoColors.white, // 使用 Cupertino 系列的白色着色
          width: 100,
        ),
      ),
      const Spacer(),
    ],
  ),
);
```
然后在下方放一个相对靠上的进度条：
```
return Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      const Spacer(),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 100),
        child: Image.asset(
          'assets/apple-logo.png',
          color: CupertinoColors.white, // 使用 Cupertino 系列的白色
          width: 100,
        ),
      ),
      Expanded(
        child: Container(
          width: 200,
          alignment: Alignment.topCenter, // 相对靠上中部对齐
          child: DecoratedBox(
            border: Border.all(color: CupertinoColors.systemGrey), // 设置边框
            borderRadius: BorderRadius.circular(10), // 这里的值比高大就行
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10), // 需要进行圆角裁剪
            child: LinearProgressIndicator(
              value: 0.3, // 当前的进度值
              backgroundColor: CupertinoColors.lightBackgroundGray.withOpacity(.3),
              color: CupertinoColors.white,
              minHeight: 5, // 设置进度条的高度
            ),
          ),
        ),
      ),
    ],
  ),
);
```

到这里你可以直接 run，一个静态的界面已经做好了。（此时大约过去了 4 分钟）

打开 App，你已经可以放在一旁挂机了，老板走到你的身边，可能会跟你闲聊更新的内容。但是，更新界面不会动，能称之为更新界面？ 当老板一而再再而三地从你身边经过，发现还是这个进度的时候，也许就已经把你的工资划掉了，或者第二天你因为进办公室在椅子上坐下而被辞退。

那么下一步我们就要思考如何让它动起来。

#思考动画

来看看启动动画大概是怎么样的：

![dddd.png](https://github.com/dongpeng66/touch_fish_on_macos/blob/main/images/dddd.png)

- 	开始是没有进度条的；
- 	进度条会逐级移动、速度不一定相等。

基于以上两个条件，我设计了一种动画处理方式：

- 	构造分段的时长 (Duration)，可以自由组合由多个时长；
- 	动画通过时长的数量决定每个时长最终的进度；
- 	每段时长控制起始值到结束值的间隔。

只有三个条件，简单到起飞，开动！（此时大约过去了 5 分钟）

#实现动画

开局一个 AnimationController：

```
class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  /// 巧用 late 初始化，节省代码量
  late final AnimationController _controller = AnimationController(vsync: this);

  /// 启动后等待的时长
  Duration get _waitingDuration => const Duration(seconds: 5);

  /// 分段的动画时长
  List<Duration> get _periodDurations {
    return <Duration>[
      const Duration(seconds: 5),
      const Duration(seconds: 10),
      const Duration(seconds: 4),
    ];
  }

  /// 当前进行到哪一个分段
  final ValueNotifier<int> _currentPeriod = ValueNotifier<int>(1);
  
 ```
 
 接下来实现动画方法，采用了递归调用的方式，减少调用链的控制：
 
 ```
 @override
void initState() {
  super.initState();
  // 等待对应秒数后，开始进度条动画
  Future.delayed(_waitingDuration).then((_) => _callAnimation());
}

Future<void> _callAnimation() async {
  // 取当前分段
  final Duration _currentDuration = _periodDurations[currentPeriod];
  // 准备下一分段
  currentPeriod++;
  // 如果到了最后一个分段，取空
  final Duration? _nextDuration = currentPeriod < _periodDurations.length ? _periodDurations.last : null;
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

```

以上短短几行代码，就完美的实现了进度条的动画操作。（此时大约过去了 8 分钟）


最后一步，将动画、分段二者与进度条绑定，在没进入分段前不展示进度条，在动画开始后展示对应的进度：

```
ValueListenableBuilder<int>(
  valueListenable: _currentPeriod,
  builder: (_, int period, __) {
    // 分段为0时，不展示
    if (period == 0) {
      return const SizedBox.shrink();
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: CupertinoColors.systemGrey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: AnimatedBuilder( // 使用 AnimatedBuilder，在动画进行时触发更新
          animation: _controller,
          builder: (_, __) => LinearProgressIndicator(
            value: _controller.value, // 将 controller 的值绑定给进度
            backgroundColor: CupertinoColors.lightBackgroundGray.withOpacity(.3),
            color: CupertinoColors.white,
            minHeight: 5,
          ),
        ),
      ),
    );
  },
)
```

大功告成，

## 打包发布

发布正式版的 macOS 应用较为复杂，但我们可以打包给自己使用，只需要一行命令即可：
```
flutter build macos。
```
成功后，产物将会输出在 build/macos/Build/Products/Release/touch_fish_on_macos.app，双击即可使用。


