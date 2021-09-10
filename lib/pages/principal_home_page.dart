import 'dart:async';
import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:animations/animations.dart';
import 'package:freeily/authentication/auth_bloc.dart';
import 'package:freeily/bloc_globals/bloc/favorites_bloc.dart';
import 'package:freeily/bloc_globals/bloc/cards_services_bloc.dart';
import 'package:freeily/bloc_globals/bloc/store_profile.dart';

import 'package:freeily/bloc_globals/bloc_location/bloc/my_location_bloc.dart';
import 'package:freeily/bloc_globals/notitification.dart';

import 'package:freeily/models/store.dart';

import 'package:freeily/preferences/user_preferences.dart';
import 'package:freeily/responses/bank_account.dart';
import 'package:freeily/responses/my_favorites_products_response.dart';
import 'package:freeily/responses/orderStoresProduct.dart';
import 'package:freeily/responses/stores_list_principal_response.dart';
import 'package:freeily/routes/routes.dart';
import 'package:freeily/services/bank_Service.dart';
import 'package:freeily/services/catalogo.dart';
import 'package:freeily/services/order_service.dart';
import 'package:freeily/services/product.dart';
import 'package:freeily/services/stores_Services.dart' as storeServiceApi;

import 'package:freeily/sockets/socket_connection.dart';

import 'package:freeily/store_principal/store_principal_bloc.dart';
import 'package:freeily/store_product_concept/store_product_bloc.dart';
import 'package:freeily/theme/theme.dart';
import 'package:freeily/widgets/delete_alert_modal.dart';
import 'package:freeily/widgets/layout_menu.dart';
import 'package:freeily/widgets/modal_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:universal_platform/universal_platform.dart';

class PrincipalPage extends StatefulWidget {
  @override
  _PrincipalPageState createState() => _PrincipalPageState();
}

class _PrincipalPageState extends State<PrincipalPage>
    with WidgetsBindingObserver {
  SocketService socketService;

  bool isWeb = UniversalPlatform.isWeb;
  // final notificationService = new NotificationService();
  final prefs = new AuthUserPreferences();

  Store storeAuth;
  AnimationController animation;
  bool isCancelLocation = false;

  @override
  initState() {
    this.socketService = Provider.of<SocketService>(context, listen: false);

    final authService = Provider.of<AuthenticationBLoC>(context, listen: false);
    final cardBloc = Provider.of<CreditCardServices>(context, listen: false);
    final orderService = Provider.of<OrderService>(context, listen: false);

    storeAuth = authService.storeAuth;

    cardBloc.getMyCreditCards(storeAuth.user.uid);

    categoriesStoreProducts();

    // storeslistServices();

    storeProfileBloc.searchBanks('');
    if (storeAuth.user.uid != '0') {
      final address = storeAuth.address.toString().split(",").first;
      storesByLocationlistServices(address, storeAuth.city, storeAuth.user.uid);

      _myOrdersClient();
      Timer(new Duration(milliseconds: 0), () {
        if (storeAuth.service != 0) {
          _myOrdersStore();
        }

        getbankAccountByUser(storeAuth.user.uid);
      });

      myFavoritesProducts();
    } else if (prefs.addressSearchSave != '') {
      final address =
          prefs.addressSearchSave.mainText.toString().split(",").first;
      storesByLocationlistServices(
          address, prefs.addressSearchSave.secondaryText, storeAuth.user.uid);

      Timer(new Duration(milliseconds: 0), () {
        orderService.loading = true;
      });
    } else {
      Timer(new Duration(milliseconds: 0), () {
        orderService.loading = true;
      });
      storeBloc.loadingStores = false;
    }

    if (!isWeb) locationStatus();
    if (!isWeb) WidgetsBinding.instance.addObserver(this);

    this
        .socketService
        .socket
        ?.on('orders-notification-client', _listenNotificationClient);

    this
        .socketService
        .socket
        ?.on('orders-notification-store', _listenNotification);

    super.initState();
  }

  void getbankAccountByUser(String uid) async {
    final bankService = Provider.of<BankService>(context, listen: false);

    final resp = await bankService.getAccountBankByUser(uid);

    if (resp.ok) {
      storeProfileBloc.setBankAccount = resp.bankAccount;
    } else {
      storeProfileBloc.setBankAccount =
          BankAccount(id: '0', bankOfAccount: 'NONE');
    }
  }

  void _listenNotificationClient(dynamic payload) {
    _myOrdersClient();
  }

  void _listenNotification(dynamic payload) {
    if (storeAuth.service != 0) {
      _myOrdersStore();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // this.socketService.socket.off('principal-message');
    super.dispose();
  }

  changeToServicePrincipal() async {
    final int followed = prefs.followed;

    (followed > 0) ? storeBloc.changeToFollowed() : storeBloc.changeToMarket();
  }

  void categoriesStoreProducts() async {
    final storeService =
        Provider.of<StoreCategoiesService>(context, listen: false);

    final resp = await storeService.getMyCategoriesProducts(storeAuth.user.uid);

    final productsBloc =
        Provider.of<TabsViewScrollBLoC>(context, listen: false);

    if (resp.ok) {
      productsBloc.storeCategoriesProducts = resp.storeCategoriesProducts;
    }
  }

  void myStoreslistServices() async {
    final storeService =
        Provider.of<storeServiceApi.StoreService>(context, listen: false);

    final StoresListResponse resp =
        await storeService.getStoresListServices(storeAuth.user.uid);

    final storeBloc = Provider.of<StoreBLoC>(context, listen: false);

    if (resp.ok) {
      storeBloc.chargeServicesStores(resp.storeListServices);
    }
  }

  void storeslistServices() async {
    final storeService =
        Provider.of<storeServiceApi.StoreService>(context, listen: false);

    final StoresListResponse resp =
        await storeService.getStoresListServices(storeAuth.user.uid);

    final storeBloc = Provider.of<StoreBLoC>(context, listen: false);

    final int followed = prefs.followed;
    if (resp.ok) {
      storeBloc.selected = (followed > 0)
          ? storeBloc.servicesStores.first
          : storeBloc.servicesStores[1];

      storeBloc.chargeServicesStores(resp.storeListServices);
    }
  }

  void myFavoritesProducts() async {
    final productService =
        Provider.of<StoreProductService>(context, listen: false);

    final StoreCategoriesResponse resp =
        await productService.getMyFavoritesProducts(storeAuth.user.uid);

    final storeBloc = Provider.of<FavoritesBLoC>(context, listen: false);

    if (resp.ok) {
      storeBloc.productsFavoritesList = resp.favoritesProducts;
    }
  }

  void _myOrdersClient() async {
    final orderService = Provider.of<OrderService>(context, listen: false);

    final notifiModel = Provider.of<NotificationModel>(context, listen: false);
    int number = notifiModel.numberNotifiBell;

    final OrderStoresProducts resp =
        await orderService.getMyOrders(storeAuth.user.uid);

    orderService.orders = [];
    if (resp.ok) {
      final List<Order> orderNotificationStore = resp.orders
          .where((i) =>
              i.isActive ||
              i.isFinalice ||
              i.isNotifiCheckClient ||
              i.isCancelByClient ||
              i.isCancelByStore)
          .toList();
      orderService.orders = orderNotificationStore;

      number = orderNotificationStore.length;

      notifiModel.numberNotifiBell = number;

      if (!orderService.loading)
        Timer(new Duration(seconds: 2), () {
          setState(() {
            orderService.loading = true;
          });
        });

      notifiModel.numberSteamNotifiBell.sink.add(number);
      if (number >= 2) {
        notifiModel.bounceControllerBell;
        //controller.forward(from: 0.0);
      }
    }
  }

  void _myOrdersStore() async {
    final orderService = Provider.of<OrderService>(context, listen: false);

    final notifiModel = Provider.of<NotificationModel>(context, listen: false);
    int number = notifiModel.numberNotifiBell;

    orderService.ordersStore = [];

    final OrderStoresProducts resp =
        await orderService.getMyOrdesStore(storeAuth.user.uid);

    if (resp.ok) {
      final List<Order> orderNotificationStore = resp.orders
          .where((i) =>
              i.isActive ||
              i.isFinalice ||
              i.isNotifiCheckStore ||
              i.isCancelByClient ||
              i.isCancelByStore)
          .toList();

      orderService.ordersStore = orderNotificationStore;

      notifiModel.numberNotifiBell = number;

      if (!orderService.loading)
        Timer(new Duration(seconds: 2), () {
          setState(() {
            orderService.loading = true;
          });
        });

      number = orderNotificationStore.length;
      notifiModel.numberSteamNotifiBell.sink.add(number);
      if (number >= 2) {
        notifiModel.bounceControllerBell;
        //controller.forward(from: 0.0);
      }
    }
  }

  bool _isDialogShowing = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    final isGranted = await Permission.location.isGranted;

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    final isPermanentlyDenied = await Permission.location.isPermanentlyDenied;

    if (state == AppLifecycleState.resumed) {
      if (isGranted && serviceEnabled) {
        //myLocationBloc.initPositionLocation();

        if (_isDialogShowing) {
          setState(() {
            _isDialogShowing = false;
          });
          Navigator.pop(context);
        }
      } else if (!serviceEnabled) {
        if (!_isDialogShowing) showModalGpsLocation();
        _isDialogShowing = true;
        //Navigator.pop(context);
      } else if (serviceEnabled && isPermanentlyDenied) {
        //if (_isDialogShowing) Navigator.pop(context);
      }
    }

    if (state == AppLifecycleState.inactive) {}
  }

  /*   void _listenMessage(dynamic payload) {
      final notifiModel = Provider.of<NotificationModel>(context, listen: false);
      int numberMessages = notifiModel.number;
      numberMessages++;
      notifiModel.number = numberMessages;
  
      if (numberMessages >= 2) {
        final controller = notifiModel.bounceController;
        controller.forward(from: 0.0);
      }
    } */

  /*  void _listenNotification(dynamic payload) {
      final currentPage =
          Provider.of<MenuModel>(context, listen: false).currentPage;
      if (currentPage != 4) {
        final notifiModel =
            Provider.of<NotificationModel>(context, listen: false);
        int number = notifiModel.numberNotifiBell;
        number++;
        notifiModel.numberNotifiBell = number;
  
        if (number >= 2) {
          final controller = notifiModel.bounceControllerBell;
          controller.forward(from: 0.0);
        }
      }
    } */

  void showModalGpsLocation() async {
    _isDialogShowing = true;

    showAlertPermissionGpsModalMatCup(
        'Permitir Ubicación',
        'Para encontrar las tiendas y enviar tus pedidos en tu ubicación',
        'Permitir',
        context, () async {
      await Geolocator.openAppSettings();

      Navigator.pop(context);
    }, () {
      Navigator.pop(context);

      _isDialogShowing = false;
    });
  }

  void locationStatus() async {
    final isGranted = await Permission.location.isGranted;
    //final isPermanentlyDenied = await Permission.location.isPermanentlyDenied;
    final isDenied = await Permission.location.isDenied;
    final isPermanentlyDenied = await Permission.location.isPermanentlyDenied;

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (isDenied) {
      final status = await Permission.location.request();

      if (prefs.addressSearchSave != '') {
        return;
      } else {
        accessGps(status);
      }
    } else if (isGranted && serviceEnabled) {
      if (prefs.addressSearchSave != '') {
        return;
      } else {
        accessGps(PermissionStatus.granted);
      }
    } else if (isGranted && !serviceEnabled) {
    } else if (!serviceEnabled) {
      setState(() {
        _isDialogShowing = true;
      });
      showModalGpsLocation();
    } else if (isPermanentlyDenied && prefs.addressSearchSave != '') {
      final status = await Permission.location.request();

      accessGps(status);
    }
  }

  void accessGps(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        Timer(new Duration(milliseconds: 300), () {
          showMaterialCupertinoBottomSheetLocation(context, () {
            HapticFeedback.lightImpact();
            myLocationBloc.initPositionLocation(context);

            Navigator.pop(context);
          }, () {
            Navigator.pop(context);
          }, false);
        });

        break;

      case PermissionStatus.denied:
        showMaterialCupertinoBottomSheetLocation(context, () {
          HapticFeedback.lightImpact();
          showModalGpsLocation();
        }, () {
          Navigator.pop(context);
        }, false);

        setState(
          () {
            _isDialogShowing = true;
          },
        );

        break;
      case PermissionStatus.restricted:
      case PermissionStatus.permanentlyDenied:
        showMaterialCupertinoBottomSheetLocation(context, () {
          HapticFeedback.lightImpact();
          showModalGpsLocation();
        }, () {
          Navigator.pop(context);
        }, false);
        // openAppSettings();

        break;
      default:
    }
  }

  void storesByLocationlistServices(
      String address, String location, String uid) async {
    final storeService =
        Provider.of<storeServiceApi.StoreService>(context, listen: false);

    final StoresListResponse resp = await storeService
        .getStoresLocationListServices(address, location, uid);

    final storeBloc = Provider.of<StoreBLoC>(context, listen: false);

    if (resp.ok) {
      storeBloc.chargeServicesStores(resp.storeListServices);
    }
  }

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final ValueNotifier<bool> notifierBottomBarVisible = ValueNotifier(true);
  int currentIndex = 0;
  bool isVisible = true;

  @override
  Widget build(BuildContext context) {
    final currentPage = Provider.of<MenuModel>(context).currentPage;

    final currentTheme = Provider.of<ThemeChanger>(context);

    final _onFirstPage = (currentPage == 0) ? true : false;

    return SafeArea(
        child: Scaffold(
            // endDrawer: PrincipalMenu(),
            body: Stack(
      children: [
        PageTransitionSwitcher(
          duration: Duration(milliseconds: 500),
          reverse: _onFirstPage,
          transitionBuilder: (Widget child, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return SharedAxisTransition(
              fillColor: currentTheme.currentTheme.scaffoldBackgroundColor,
              transitionType: SharedAxisTransitionType.horizontal,
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              child: child,
            );
          },
          child: pageRouter[currentPage].page,
        ),
        _PositionedMenu(),
      ],
    )));
  }
}

class _PositionedMenu extends StatefulWidget {
  @override
  __PositionedMenuState createState() => __PositionedMenuState();
}

int currentIndex = 0;

class __PositionedMenuState extends State<_PositionedMenu> {
  @override
  Widget build(BuildContext context) {
    double widthView = MediaQuery.of(context).size.width;

    final appTheme = Provider.of<ThemeChanger>(context).currentTheme;
    final bloc = Provider.of<StoreBLoC>(context);

    if (widthView > 500) {
      widthView = widthView - 300;
    }

    final currentPage = Provider.of<MenuModel>(context).currentPage;
    final authService = Provider.of<AuthenticationBLoC>(context);

    return Positioned(
        bottom: 0,
        child: IgnorePointer(
          ignoring: !bloc.isVisible,
          child: Container(
            alignment: Alignment.center,
            height: 100,
            width: widthView,
            child: Row(
              children: [
                Spacer(),
                FadeIn(
                  duration: Duration(milliseconds: 200),
                  animate: bloc.isVisible,
                  child: GridLayoutMenu(
                      show: bloc.isVisible,
                      backgroundColor: Colors.black,
                      activeColor: appTheme.accentColor,
                      inactiveColor: Colors.white,
                      items: [
                        GLMenuButton(
                            icon: (currentPage == 0)
                                ? Icons.home
                                : Icons.home_outlined,
                            onPressed: () {
                              HapticFeedback.lightImpact();
                            }),
                        GLMenuButton(
                            icon: (currentPage == 1)
                                ? Icons.favorite
                                : Icons.favorite_outline,
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              authService.redirect = 'favorite';
                              if (authService.storeAuth.user.uid == '0') {
                                Navigator.push(context, loginRoute());
                              } else if (bloc.isVisible) {
                                if (authService.storeAuth.user.first)
                                  Navigator.push(context, principalHomeRoute());
                              }
                            }),
                        GLMenuButton(
                            icon: (currentPage == 2)
                                ? Icons.storefront
                                : Icons.storefront_outlined,
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              authService.redirect = 'vender';
                              if (authService.storeAuth.user.uid == '0') {
                                Navigator.push(context, loginRoute());
                              } else if (bloc.isVisible) {
                                if (authService.storeAuth.user.first)
                                  Navigator.push(context, principalHomeRoute());
                                _onItemTapped(2);
                              }
                            }),
                      ]),
                ),
                Spacer(),
              ],
            ),
          ),
        ));
  }

  void _onItemTapped(int index) {
    setState(() {
      currentIndex = index;

      Provider.of<MenuModel>(context, listen: false).currentPage = currentIndex;

      if (currentIndex == 4) {
        Provider.of<NotificationModel>(context, listen: false)
            .numberNotifiBell = 0;
      }
    });
  }
}

class BNBCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    Path path = Path();
    path.moveTo(0, 20); // Start
    path.quadraticBezierTo(size.width * 0.20, 0, size.width * 0.35, 0);
    path.quadraticBezierTo(size.width * 0.40, 0, size.width * 0.40, 20);
    path.arcToPoint(Offset(size.width * 0.60, 20),
        radius: Radius.circular(20.0), clockwise: false);
    path.quadraticBezierTo(size.width * 0.60, 0, size.width * 0.65, 0);
    path.quadraticBezierTo(size.width * 0.80, 0, size.width, 20);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, 20);
    canvas.drawShadow(path, Colors.black, 5, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class MenuModel with ChangeNotifier {
  int _currentPage = 0;
  int _lastPage = 0;

  int get currentPage => this._currentPage;

  set currentPage(int value) {
    this._currentPage = value;
    notifyListeners();
  }

  int get lastPage => this._lastPage;

  set lastPage(int value) {
    this._lastPage = value;
    notifyListeners();
  }
}
