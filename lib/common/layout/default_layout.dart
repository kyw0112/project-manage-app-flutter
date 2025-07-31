import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../notification/notification_service.dart';
import '../notification/notification_panel.dart';

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
  final bool showNotificationButton;

  const DefaultLayout({
    super.key, 
    required this.child, 
    this.backgroundColor, 
    this.title, 
    this.autoImplyLeading, 
    this.bottomNavigationBar, 
    this.tabBar, 
    this.length, 
    this.actions,
    this.showNotificationButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    AppBar? renderAppBar(){
      if(title == null){
        return null;
      }else{
        List<Widget> appBarActions = [];
        
        // 알림 버튼 추가
        if (showNotificationButton) {
          appBarActions.add(_buildNotificationButton());
        }
        
        // 기존 액션들 추가
        if (actions != null) {
          appBarActions.addAll(actions!);
        }
        
        return AppBar(
          automaticallyImplyLeading: autoImplyLeading ?? true,
          backgroundColor: colorScheme.surface,
          elevation: 0,
          title: Text(title!, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),),
          foregroundColor: colorScheme.inverseSurface,
          bottom : tabBar,
          actions: appBarActions.isNotEmpty ? appBarActions : null,
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

  Widget _buildNotificationButton() {
    return GetBuilder<NotificationService>(
      builder: (notificationService) {
        return Obx(() => NotificationBadge(
          showBadge: notificationService.unreadCount.value > 0,
          count: notificationService.unreadCount.value,
          child: IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Get.to(() => const NotificationPanel());
            },
          ),
        ));
      },
    );
  }
}

