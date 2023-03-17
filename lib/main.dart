import 'dart:collection';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:flutter/material.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey webViewKey = GlobalKey();




  late WebViewXController webviewController;
  final scrollController = ScrollController();

  final initialContent =
      '<h4> This is some hardcoded HTML code embedded inside the webview <h4> <h2> Hello world! <h2>';
  final executeJsErrorMessage =
      'Failed to execute this task because the current content is (probably) URL that allows iFrame embedding, on Web.\n\n'
      'A short reason for this is that, when a normal URL is embedded in the iFrame, you do not actually own that content so you cant call your custom functions\n'
      '(read the documentation to find out why).';

  Size get screenSize => MediaQuery.of(context).size;

  @override
  void dispose() {
    webviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebViewX_Plus Page'),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              buildSpace(direction: Axis.vertical, amount: 10.0, flex: false),
              Container(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text(
                  'Play around with the buttons below',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              buildSpace(direction: Axis.vertical, amount: 10.0, flex: false),
              _buildWebViewX(),

              // Expanded(
              //   child: Scrollbar(
              //     controller: scrollController,
              //     thumbVisibility: true,
              //     child: SizedBox(
              //       width: min(screenSize.width * 0.8, 512),
              //       child: ListView(
              //         controller: scrollController,
              //         children: _buildButtons(),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebViewX() {
    return WebViewX(
      key: const ValueKey('webviewx'),
      initialContent: "https://payments-web-sandbox.paymaya.com/authenticate?id=a169b870-ab40-423e-8512-3e13a035ecb3",
      initialSourceType: SourceType.urlBypass,
      userAgent: "hello",
      height: screenSize.height / 2,
      width: double.maxFinite,
      onWebViewCreated: (controller) => webviewController = controller,
      onPageStarted: (src) =>
          debugPrint('A new page has started loading: $src\n'),
      onPageFinished: (src) =>
          debugPrint('The page has finished loading: $src\n'),
      dartCallBacks: {
        DartCallback(
          name: 'TestDartCallback',
          callBack: (msg) => showSnackBar(msg.toString(), context),
        )
      },
      webSpecificParams: const WebSpecificParams(
        printDebugInfo: true,
      ),
      mobileSpecificParams: const MobileSpecificParams(
        androidEnableHybridComposition: true,
      ),
      navigationDelegate: (navigation) {
       // debugPrint(navigation.content.source.toString());

        print("Url : ${navigation.content.source.toString()}");
        return NavigationDecision.navigate;
      },
    );
  }

  void _setUrl() {
    webviewController.loadContent(
      'https://flutter.dev',
    );
  }

  void _setUrlBypass() {
    webviewController.loadContent(
      'https://news.ycombinator.com/',
      sourceType: SourceType.urlBypass,
    );
  }

  void _setHtml() {
    webviewController.loadContent(
      initialContent,
      sourceType: SourceType.html,
    );
  }

  void _setHtmlFromAssets() {
    webviewController.loadContent(
      'assets/test.html',
      sourceType: SourceType.html,
      fromAssets: true,
    );
  }

  Future<void> _goForward() async {
    if (await webviewController.canGoForward()) {
      await webviewController.goForward();
      showSnackBar('Did go forward', context);
    } else {
      showSnackBar('Cannot go forward', context);
    }
  }

  Future<void> _goBack() async {
    if (await webviewController.canGoBack()) {
      await webviewController.goBack();
      showSnackBar('Did go back', context);
    } else {
      showSnackBar('Cannot go back', context);
    }
  }

  void _reload() {
    webviewController.reload();
  }

  void _toggleIgnore() {
    final ignoring = webviewController.ignoresAllGestures;
    webviewController.setIgnoreAllGestures(!ignoring);
    showSnackBar('Ignore events = ${!ignoring}', context);
  }

  Future<void> _evalRawJsInGlobalContext() async {
    try {
      final result = await webviewController.evalRawJavascript(
        '2+2',
        inGlobalContext: true,
      );
      showSnackBar('The result is $result', context);
    } catch (e) {
      showAlertDialog(
        executeJsErrorMessage,
        context,
      );
    }
  }

  Future<void> _callPlatformIndependentJsMethod() async {
    try {
      await webviewController.callJsMethod('testPlatformIndependentMethod', []);
    } catch (e) {
      showAlertDialog(
        executeJsErrorMessage,
        context,
      );
    }
  }

  Future<void> _callPlatformSpecificJsMethod() async {
    try {
      await webviewController
          .callJsMethod('testPlatformSpecificMethod', ['Hi']);
    } catch (e) {
      showAlertDialog(
        executeJsErrorMessage,
        context,
      );
    }
  }

  Future<void> _getWebviewContent() async {
    try {
      final content = await webviewController.getContent();
      showAlertDialog(content.source, context);
    } catch (e) {
      showAlertDialog('Failed to execute this task.', context);
    }
  }

  Widget buildSpace({
    Axis direction = Axis.horizontal,
    double amount = 0.2,
    bool flex = true,
  }) {
    return flex
        ? Flexible(
      child: FractionallySizedBox(
        widthFactor: direction == Axis.horizontal ? amount : null,
        heightFactor: direction == Axis.vertical ? amount : null,
      ),
    )
        : SizedBox(
      width: direction == Axis.horizontal ? amount : null,
      height: direction == Axis.vertical ? amount : null,
    );
  }

  List<Widget> _buildButtons() {
    return [
      buildSpace(direction: Axis.vertical, flex: false, amount: 20.0),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: createButton(onTap: _goBack, text: 'Back')),
          buildSpace(amount: 12, flex: false),
          Expanded(child: createButton(onTap: _goForward, text: 'Forward')),
          buildSpace(amount: 12, flex: false),
          Expanded(child: createButton(onTap: _reload, text: 'Reload')),
        ],
      ),
      buildSpace(direction: Axis.vertical, flex: false, amount: 20.0),
      createButton(
        text:
        'Change content to URL that allows iFrames embedding\n(https://flutter.dev)',
        onTap: _setUrl,
      ),
      buildSpace(direction: Axis.vertical, flex: false, amount: 20.0),
      createButton(
        text:
        'Change content to URL that doesnt allow iFrames embedding\n(https://news.ycombinator.com/)',
        onTap: _setUrlBypass,
      ),
      buildSpace(direction: Axis.vertical, flex: false, amount: 20.0),
      createButton(
        text: 'Change content to HTML (hardcoded)',
        onTap: _setHtml,
      ),
      buildSpace(direction: Axis.vertical, flex: false, amount: 20.0),
      createButton(
        text: 'Change content to HTML (from assets)',
        onTap: _setHtmlFromAssets,
      ),
      buildSpace(direction: Axis.vertical, flex: false, amount: 20.0),
      createButton(
        text: 'Toggle on/off ignore any events (click, scroll etc)',
        onTap: _toggleIgnore,
      ),
      buildSpace(direction: Axis.vertical, flex: false, amount: 20.0),
      createButton(
        text: 'Evaluate 2+2 in the global "window" (javascript side)',
        onTap: _evalRawJsInGlobalContext,
      ),
      buildSpace(direction: Axis.vertical, flex: false, amount: 20.0),
      createButton(
        text: 'Call platform independent Js method (console.log)',
        onTap: _callPlatformIndependentJsMethod,
      ),
      buildSpace(direction: Axis.vertical, flex: false, amount: 20.0),
      createButton(
        text:
        'Call platform specific Js method, that calls back a Dart function',
        onTap: _callPlatformSpecificJsMethod,
      ),
      buildSpace(direction: Axis.vertical, flex: false, amount: 20.0),
      createButton(
        text: 'Show current webview content',
        onTap: _getWebviewContent,
      ),
    ];
  }



  // final PlatformWebViewController _controller = PlatformWebViewController(
  //   const PlatformWebViewControllerCreationParams(),
  // )..loadRequest(
  //   LoadRequestParams(
  //     uri: Uri.parse('https://flutter.dev'),
  //   ),
  // );
  //
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: PlatformWebViewWidget(
  //       PlatformWebViewWidgetCreationParams(controller: _controller),
  //     ).build(context),
  //   );
  // }


  // InAppWebViewController? webViewController;
  // InAppWebViewSettings settings = InAppWebViewSettings(
  //   useShouldInterceptAjaxRequest: true,
  //     useShouldInterceptFetchRequest: true,
  //     useShouldOverrideUrlLoading: true,
  //     mediaPlaybackRequiresUserGesture: false,
  //     allowsInlineMediaPlayback: true,
  //     iframeAllow: "camera; microphone",
  //     iframeAllowFullscreen: true,
  //   javaScriptEnabled: true,
  //   javaScriptCanOpenWindowsAutomatically: true,
  //
  // );
  //
  // PullToRefreshController? pullToRefreshController;
  //
  // late ContextMenu contextMenu;
  // String url = "";
  // double progress = 0;
  // final urlController = TextEditingController();
  //
  // @override
  // void initState() {
  //   super.initState();
  //   print("init");
  //
  //   contextMenu = ContextMenu(
  //       menuItems: [
  //         ContextMenuItem(
  //             id: 1,
  //             title: "Special",
  //             action: () async {
  //               print("Menu item Special clicked!");
  //               print(await webViewController?.getSelectedText());
  //               await webViewController?.clearFocus();
  //             })
  //       ],
  //       settings: ContextMenuSettings(hideDefaultSystemContextMenuItems: false),
  //       onCreateContextMenu: (hitTestResult) async {
  //         print("onCreateContextMenu");
  //         print(hitTestResult.extra);
  //         print(await webViewController?.getSelectedText());
  //       },
  //       onHideContextMenu: () {
  //         print("onHideContextMenu");
  //       },
  //       onContextMenuActionItemClicked: (contextMenuItemClicked) async {
  //         var id = contextMenuItemClicked.id;
  //         print("onContextMenuActionItemClicked: " +
  //             id.toString() +
  //             " " +
  //             contextMenuItemClicked.title);
  //       });
  //
  //   pullToRefreshController = kIsWeb || ![TargetPlatform.iOS, TargetPlatform.android].contains(defaultTargetPlatform)
  //       ? null
  //       : PullToRefreshController(
  //     settings: PullToRefreshSettings(
  //       color: Colors.blue,
  //     ),
  //     onRefresh: () async {
  //       if (defaultTargetPlatform == TargetPlatform.android) {
  //         webViewController?.reload();
  //       } else if (defaultTargetPlatform == TargetPlatform.iOS ||
  //           defaultTargetPlatform == TargetPlatform.macOS) {
  //         webViewController?.loadUrl(
  //             urlRequest:
  //             URLRequest(url: await webViewController?.getUrl()));
  //       }
  //     },
  //   );
  // }
  //
  // @override
  // void dispose() {
  //   super.dispose();
  // }
  //
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //       appBar: AppBar(title: Text("InAppWebView")),
  //      // drawer: myDrawer(context: context),
  //       body: SafeArea(
  //           child: Column(children: <Widget>[
  //             TextField(
  //               decoration: InputDecoration(prefixIcon: Icon(Icons.search)),
  //               controller: urlController,
  //               keyboardType: TextInputType.text,
  //               onSubmitted: (value) {
  //                 var url = WebUri(value);
  //                 if (url.scheme.isEmpty) {
  //                   url = WebUri((!kIsWeb
  //                       ? "https://www.google.com/search?q="
  //                       : "https://www.bing.com/search?q=") +
  //                       value);
  //                 }
  //                 webViewController?.loadUrl(urlRequest: URLRequest(url: url));
  //               },
  //             ),
  //             Expanded(
  //               child: Stack(
  //                 children: [
  //                   InAppWebView(
  //                     key: webViewKey,
  //                     initialUrlRequest:
  //                     URLRequest(url: WebUri('https://flutter.dev')),
  //                     // initialUrlRequest:
  //                     // URLRequest(url: WebUri(Uri.base.toString().replaceFirst("/#/", "/") + 'page.html')),
  //                     // initialFile: "assets/index.html",
  //                     initialUserScripts: UnmodifiableListView<UserScript>([]),
  //                     initialSettings: settings,
  //                     // contextMenu: contextMenu,
  //                     pullToRefreshController: pullToRefreshController,
  //
  //                     onWebViewCreated: (controller) async {
  //                       webViewController = controller;
  //                       WebUri? r= await controller.getUrl();
  //                       print("url : ${r.toString()}");
  //
  //                     },
  //                     onLoadStart: (controller, url) async {
  //                       setState(() {
  //                         this.url = url.toString();
  //                         urlController.text = this.url;
  //                       });
  //                     },
  //                     onPermissionRequest: (controller, request) async {
  //                       return PermissionResponse(
  //                           resources: request.resources,
  //                           action: PermissionResponseAction.GRANT);
  //                     },
  //                     shouldOverrideUrlLoading:
  //                         (controller, navigationAction) async {
  //                       var uri = navigationAction.request.url!;
  //
  //                       if (![
  //                         "http",
  //                         "https",
  //                         "file",
  //                         "chrome",
  //                         "data",
  //                         "javascript",
  //                         "about"
  //                       ].contains(uri.scheme)) {
  //                         print("url : $url");
  //                         // if (await canLaunchUrl(uri)) {
  //                         //   // Launch the App
  //                         //   await launchUrl(
  //                         //     uri,
  //                         //   );
  //                         //   // and cancel the request
  //                         //   return NavigationActionPolicy.CANCEL;
  //                         // }
  //                       }
  //
  //                       return NavigationActionPolicy.ALLOW;
  //                     },
  //                     onLoadStop: (controller, url) async {
  //                       pullToRefreshController?.endRefreshing();
  //                       setState(() {
  //                         this.url = url.toString();
  //                         urlController.text = this.url;
  //                       });
  //                     },
  //                     onReceivedError: (controller, request, error) {
  //                       pullToRefreshController?.endRefreshing();
  //                     },
  //                     onProgressChanged: (controller, progress) {
  //                       if (progress == 100) {
  //                         pullToRefreshController?.endRefreshing();
  //                       }
  //                       setState(() {
  //                         this.progress = progress / 100;
  //                         urlController.text = this.url;
  //                       });
  //                     },
  //                     onUpdateVisitedHistory: (controller, url, isReload) {
  //                       setState(() {
  //                         this.url = url.toString();
  //                         urlController.text = this.url;
  //                       });
  //                     },
  //                     onConsoleMessage: (controller, consoleMessage) {
  //                       print(consoleMessage);
  //                     },
  //                   ),
  //                   progress < 1.0
  //                       ? LinearProgressIndicator(value: progress)
  //                       : Container(),
  //                 ],
  //               ),
  //             ),
  //             ButtonBar(
  //               alignment: MainAxisAlignment.center,
  //               children: <Widget>[
  //                 ElevatedButton(
  //                   child: Icon(Icons.arrow_back),
  //                   onPressed: () {
  //                     webViewController?.goBack();
  //                   },
  //                 ),
  //                 ElevatedButton(
  //                   child: Icon(Icons.arrow_forward),
  //                   onPressed: () {
  //                     webViewController?.goForward();
  //                   },
  //                 ),
  //                 ElevatedButton(
  //                   child: Icon(Icons.refresh),
  //                   onPressed: () {
  //                     webViewController?.reload();
  //                   },
  //                 ),
  //               ],
  //             ),
  //           ])));
  // }
}

void showAlertDialog(String content, BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => WebViewAware(
      child: AlertDialog(
        content: Text(content),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Close'),
          ),
        ],
      ),
    ),
  );
}

void showSnackBar(String content, BuildContext context) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(content),
        duration: const Duration(seconds: 1),
      ),
    );
}

Widget createButton({
  VoidCallback? onTap,
  required String text,
}) {
  return ElevatedButton(
    onPressed: onTap,
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
    ),
    child: Text(text),
  );
}