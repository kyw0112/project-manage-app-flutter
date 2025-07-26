import 'package:flutter/material.dart';

class DefaultLayout extends StatelessWidget {
  //모든 페이지에 공통적으로 적용할 로직을 적용할 수 있다.
  //예: 공통적으로 호출해줘야 하는 api
  final Color? backgroundColor;
  final Widget child;
  final String? title;
  final bool? autoImplyLeading;
  final Widget? bottomNavigationBar;
  final TabBar? tabBar;
  final int? length;
  final List<Widget>? actions;

  const DefaultLayout({super.key, required this.child, this.backgroundColor, this.title, this.autoImplyLeading, this.bottomNavigationBar, this.tabBar, this.length, this.actions});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    AppBar? renderAppBar(){
      if(title == null){
        return null;
      }else{
        return AppBar(
          automaticallyImplyLeading: autoImplyLeading ?? true,
          backgroundColor: colorScheme.surface,
          elevation: 0,
          title: Text(title!, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),),
          foregroundColor: colorScheme.inverseSurface,
          bottom : tabBar,
          actions: actions,
        );
      }
    }


    if(tabBar == null){
      return Scaffold(
        // backgroundColor: backgroundColor ?? Colors.white,
        appBar: renderAppBar(),
        body: child,
        bottomNavigationBar: bottomNavigationBar,
      );
    } else {
      return DefaultTabController(
        length: length ?? 0,
        child: Scaffold(
          // backgroundColor: backgroundColor ?? Colors.white,
          appBar: renderAppBar(),
          body: child,
          bottomNavigationBar: bottomNavigationBar,
        ),
      );
    }

  }

}

