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

![防止崩溃输出日志.png](https://github.com/dongpeng66/AvoidCrashDeom/blob/main/AvoidCrashDemo/Screenshot/防止崩溃的输出日志.png)
