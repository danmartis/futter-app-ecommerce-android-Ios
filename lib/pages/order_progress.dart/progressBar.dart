import 'package:australti_ecommerce_app/responses/orderStoresProduct.dart';
import 'package:australti_ecommerce_app/theme/theme.dart';
import 'package:australti_ecommerce_app/widgets/cross_fade.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import 'util.dart';
import 'package:expandable/expandable.dart';

class ProgressBar extends StatefulWidget {
  ProgressBar(
      {Key key, this.order, this.principal = false, this.isStore = false});
  final bool principal;
  final bool isStore;

  final Order order;
  _ProgressBarState createState() => _ProgressBarState();
}

class _ProgressBarState extends State<ProgressBar>
    with TickerProviderStateMixin {
  AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: Duration(milliseconds: 3000),
      vsync: this,
    );
    animationController.forward();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBar(
      key: widget.key,
      controller: animationController,
      order: widget.order,
      principal: widget.principal,
      isStore: widget.isStore,
    );
  }
}

class AnimatedBar extends StatefulWidget {
  final bool principal;
  final Order order;

  final bool isStore;

  AnimatedBar(
      {Key key, this.order, this.controller, this.principal, this.isStore})
      : isActive = order.isActive,
        isPreparation = order.isPreparation,
        isDelivery = order.isDelivery,
        isCancelByClient = order.isCancelByClient,
        isCancelByStore = order.isCancelByStore,
        isDelivered = order.isDelivered,
        isFinalice = order.isFinalice,
        dotOneColor = ColorTween(
          begin: FoodColors.Grey,
          end: FoodColors.Yellow,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              0.000,
              0.100,
              curve: Curves.linear,
            ),
          ),
        ),
        textOneStyle = TextStyleTween(
          begin: TextStyle(
              fontWeight: FontWeight.w400,
              color: FoodColors.Grey,
              fontSize: 12),
          end: TextStyle(
              fontWeight: FontWeight.w600, color: Colors.white, fontSize: 12),
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              0.000,
              0.100,
              curve: Curves.linear,
            ),
          ),
        ),
        progressBarOne = Tween(
                begin: 0.0,
                end: (order.isActive & (!order.isPreparation))
                    ? 0.5
                    : (order.isPreparation)
                        ? 1.0
                        : 0.0)
            .animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(0.100, 0.450),
          ),
        ),
        dotTwoColor = ColorTween(
          begin: FoodColors.Grey,
          end: FoodColors.Yellow,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              0.450,
              0.550,
              curve: Curves.linear,
            ),
          ),
        ),
        textTwoStyle = TextStyleTween(
          begin: TextStyle(
              fontWeight: FontWeight.w400,
              color: FoodColors.Grey,
              fontSize: 12),
          end: TextStyle(
              fontWeight: FontWeight.w400, color: Colors.grey, fontSize: 12),
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              0.900,
              1.000,
              curve: Curves.linear,
            ),
          ),
        ),
        progressBarTwo = Tween(
                begin: 0.0,
                end: (order.isPreparation && !order.isDelivery)
                    ? 0.5
                    : (order.isDelivery)
                        ? 1.0
                        : 0.0)
            .animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(0.550, 0.900),
          ),
        ),
        dotThreeColor = ColorTween(
          begin: FoodColors.Grey,
          end: FoodColors.Yellow,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              0.900,
              1.000,
              curve: Curves.linear,
            ),
          ),
        ),
        progressBarThree = Tween(
                begin: 0.0,
                end: (order.isDelivery && (!order.isDelivered))
                    ? 0.5
                    : (order.isDelivered)
                        ? 1.0
                        : 0.0)
            .animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(0.900, 1.000), // 900, 1.000
          ),
        ),
        textThreeStyle = TextStyleTween(
          begin: TextStyle(
              fontWeight: FontWeight.w400,
              color: FoodColors.Grey,
              fontSize: 12),
          end: TextStyle(
              fontWeight: FontWeight.w400, color: Colors.grey, fontSize: 12),
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              0.0,
              0.0,
              curve: Curves.linear,
            ),
          ),
        ),
        dotFourColor = ColorTween(
          begin: FoodColors.Grey,
          end: FoodColors.Yellow,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              0.900,
              1.000,
              curve: Curves.linear,
            ),
          ),
        ),
        progressBarFour = Tween(
                begin: 0.0,
                end: (!order.isDelivered && order.isDelivery)
                    ? 0.5
                    : (order.isDelivered)
                        ? 1.0
                        : 0.0)
            .animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              0.900,
              1.000,
              curve: Curves.linear,
            ),
          ),
        ),
        super(key: key);

  final AnimationController controller;
  final Animation<Color> dotOneColor;
  final Animation<TextStyle> textOneStyle;
  final Animation<double> progressBarOne;
  final Animation<Color> dotTwoColor;

  final Animation<TextStyle> textTwoStyle;
  final Animation<double> progressBarTwo;
  final Animation<Color> dotThreeColor;
  final Animation<Color> dotFourColor;
  final Animation<TextStyle> textThreeStyle;
  final Animation<double> progressBarThree;

  final bool isActive;
  final bool isPreparation;
  final bool isDelivery;
  final bool isDelivered;
  final bool isCancelByClient;
  final bool isCancelByStore;
  final bool isFinalice;

  final Animation<double> progressBarFour;

  @override
  _AnimatedBarState createState() => _AnimatedBarState();
}

class _AnimatedBarState extends State<AnimatedBar>
    with TickerProviderStateMixin {
  int dotSize = 0;

  AnimationController _animationController;

  void initState() {
    dotSize = (widget.principal) ? 20 : 30;
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    progressBar() {
      final currentTheme = Provider.of<ThemeChanger>(context).currentTheme;

      String textOne = (widget.isStore)
          ? "Prepara el pedido ..."
          : "El pedido esta en proceso ...";

      String textTwo = (widget.isStore)
          ? "Estas preparando el pedido ..."
          : "Estan preparando tu pedido ...";

      String textThree = (widget.isStore)
          ? "Estas entregando el pedido ..."
          : "Tu pedido va en camino ...";

      String textFour = (widget.isStore)
          ? "Entregado, evalua la experiencia!"
          : "El pedido llego a tu dirección!";

      String actualText = "";
      if (widget.isActive && !widget.isPreparation) {
        actualText = textOne;
      } else if (widget.isPreparation && !widget.order.isDelivery) {
        actualText = textTwo;
      } else if (widget.isDelivery && !widget.isDelivered) {
        actualText = textThree;
      } else if (widget.order.isDelivered) {
        actualText = textFour;
      }

      if (widget.isStore && widget.order.isCancelByStore)
        actualText = 'Pedido cancelado.';

      if (!widget.isStore && widget.order.isCancelByStore)
        actualText = 'Pedido cancelado por la tienda.';

      if (widget.isStore && widget.order.isCancelByClient)
        actualText = 'Pedido cancelado por el cliente.';

      if (!widget.isStore && widget.order.isCancelByStore)
        actualText = 'Pedido cancelado.';
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(
                top: (widget.principal) ? 10.0 : 0,
                right: (widget.principal) ? 20 : 0,
                bottom: (widget.principal) ? 5 : 0,
              ),
              width: MediaQuery.of(context).size.width / 1.3,
              height: (!widget.principal) ? 80 : 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  // Text('${(controller.value * 100.0).toStringAsFixed(1)}%'),
                  Container(
                    width: dotSize + widget.progressBarOne.value * 6,
                    height: dotSize + widget.progressBarOne.value * 6,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                            width: (widget.principal)
                                ? 0.5 + widget.progressBarOne.value * 1
                                : 0.5 + widget.progressBarOne.value * 3,
                            color: (!widget.isCancelByClient &&
                                    !widget.isCancelByStore)
                                ? (widget.progressBarOne.value >= 0.5)
                                    ? currentTheme.primaryColor
                                    : Colors.grey
                                : Colors.grey)),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      alignment: Alignment.center,
                      child: (!widget.isCancelByClient &&
                              !widget.isCancelByStore)
                          ? (widget.progressBarOne.value != 1.0)
                              ? FaIcon(
                                  FontAwesomeIcons.archive,
                                  size: (widget.principal) ? 10 : 13,
                                  color: (widget.progressBarOne.value >= 0.5)
                                      ? currentTheme.primaryColor
                                      : Colors.grey,
                                )
                              : Icon(
                                  Icons.check_circle,
                                  size: (widget.principal)
                                      ? 15
                                      : 20 + widget.progressBarOne.value * 6,
                                  color: currentTheme.primaryColor,
                                )
                          : FaIcon(
                              FontAwesomeIcons.timesCircle,
                              size: (!widget.isCancelByClient &&
                                      !widget.isCancelByStore)
                                  ? 20
                                  : (widget.principal)
                                      ? 15
                                      : 20,
                              color: Colors.grey,
                            ),
                    ),
                  ),

                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 2,
                      child: LinearProgressIndicator(
                        backgroundColor: FoodColors.Grey,
                        value: (!widget.isCancelByClient &&
                                !widget.isCancelByStore)
                            ? widget.progressBarOne.value
                            : 0,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(FoodColors.Yellow),
                      ),
                    ),
                  ),

                  Container(
                    width: dotSize + widget.progressBarTwo.value * 6,
                    height: dotSize + widget.progressBarTwo.value * 6,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                            width: (widget.principal)
                                ? 0.5 + widget.progressBarTwo.value * 1
                                : 0.5 + widget.progressBarTwo.value * 3,
                            color: (widget.progressBarTwo.value >= 0.5)
                                ? currentTheme.primaryColor
                                : Colors.grey)),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      alignment: Alignment.center,
                      child: (widget.progressBarTwo.value != 1.0)
                          ? FaIcon(
                              FontAwesomeIcons.boxOpen,
                              size: (widget.principal) ? 10 : 13,
                              color: (widget.progressBarTwo.value >= 0.5)
                                  ? currentTheme.primaryColor
                                  : Colors.grey,
                            )
                          : Icon(
                              Icons.check_circle,
                              size: (widget.principal)
                                  ? 15
                                  : 20 + widget.progressBarTwo.value * 6,
                              color: currentTheme.primaryColor,
                            ),
                    ),
                  ),

                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 2,
                      child: LinearProgressIndicator(
                        backgroundColor: FoodColors.Grey,
                        value: widget.progressBarTwo.value,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(FoodColors.Yellow),
                      ),
                    ),
                  ),

                  Container(
                    width: dotSize + widget.progressBarThree.value * 6,
                    height: dotSize + widget.progressBarThree.value * 6,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                            width: (widget.principal)
                                ? 0.5 + widget.progressBarThree.value * 1
                                : 0.5 + widget.progressBarThree.value * 3,
                            color: (widget.progressBarThree.value >= 0.5)
                                ? currentTheme.primaryColor
                                : Colors.grey)),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      alignment: Alignment.center,
                      child: (widget.progressBarThree.value != 1.0)
                          ? FaIcon(
                              FontAwesomeIcons.truckLoading,
                              size: (widget.principal) ? 10 : 13,
                              color: (widget.progressBarThree.value >= 0.5)
                                  ? currentTheme.primaryColor
                                  : Colors.grey,
                            )
                          : Icon(
                              Icons.check_circle,
                              size: (widget.principal)
                                  ? 15
                                  : 20 + widget.progressBarThree.value * 6,
                              color: currentTheme.primaryColor,
                            ),
                    ),
                  ),

                  /*  Container(
                      width: dotSize,
                      height: dotSize,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(dotSize / 2),
                          color: Colors.grey),
                    ), */

                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 2,
                      child: LinearProgressIndicator(
                        backgroundColor: FoodColors.Grey,
                        value: widget.progressBarThree.value,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(FoodColors.Yellow),
                      ),
                    ),
                  ),

                  Container(
                    width: dotSize + widget.progressBarFour.value * 6,
                    height: dotSize + widget.progressBarFour.value * 6,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                            width: (widget.principal)
                                ? 0.5 + widget.progressBarFour.value * 1
                                : 0.5 + widget.progressBarFour.value * 3,
                            color: (widget.progressBarFour.value == 1.0)
                                ? currentTheme.primaryColor
                                : Colors.grey)),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      alignment: Alignment.center,
                      child: (widget.progressBarFour.value != 1.0)
                          ? FaIcon(
                              FontAwesomeIcons.home,
                              size: (widget.principal) ? 10 : 13,
                              color: (widget.progressBarFour.value == 1.0)
                                  ? currentTheme.primaryColor
                                  : Colors.grey,
                            )
                          : Icon(
                              Icons.check_circle,
                              size: (widget.principal)
                                  ? 15
                                  : 20 + widget.progressBarFour.value * 6,
                              color: currentTheme.primaryColor,
                            ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              alignment:
                  (widget.principal) ? Alignment.centerLeft : Alignment.center,
              padding: EdgeInsets.only(
                right: (widget.principal) ? 0 : 20,
                top: (widget.principal) ? 5 : 0,
                left: (widget.principal) ? 0 : 20,
              ),
              height: (widget.principal) ? 20 : 50,
              child: CrossFade<String>(
                initialData: actualText,
                data: actualText,
                builder: (value) => Container(
                  child: (widget.order.isDelivered)
                      ? Text(
                          value,
                          style: TextStyle(
                              color: currentTheme.primaryColor,
                              fontSize: (widget.principal) ? 12 : 18,
                              fontWeight: FontWeight.normal),
                        )
                      : Text(
                          value,
                          style: TextStyle(
                              color: (widget.order.isCancelByClient ||
                                      widget.order.isCancelByStore)
                                  ? Colors.grey
                                  : Colors.white,
                              fontSize: (widget.principal) ? 12 : 18,
                              fontWeight: FontWeight.normal),
                        ),
                ),
              ),
            ),
            if (!widget.principal)
              SizedBox(
                height: 10,
              )
          ],
        ),
      );
    }

    buildCollapsed2() {
      return Column(
        children: [progressBar()],
      );
    }

    final currentTheme = Provider.of<ThemeChanger>(context).currentTheme;

    return Container(
        child: AnimatedBuilder(
            animation: widget.controller,
            builder: (BuildContext context, Widget child) => ExpandableNotifier(
                    child: ScrollOnExpand(
                  child: Card(
                    elevation: (widget.principal) ? 0 : 6,
                    shadowColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: currentTheme.cardColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expandable(
                          collapsed: progressBar(),
                          expanded: buildCollapsed2(),
                        ),

                        /* 
                        
                        if (!widget.principal)
                          Divider(
                            height: 1,
                          ),
                          (widget.principal)
                            ? Container()
                            : Builder(
                                builder: (context) {
                                  var controller = ExpandableController.of(
                                      context,
                                      required: true);
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        (!controller.expanded)
                                            ? 'Ver más'
                                            : 'Ver menos',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                      IconButton(
                                          onPressed: () {
                                            controller.toggle();
                                          },
                                          icon: (!controller.expanded)
                                              ? Icon(
                                                  Icons.expand_more,
                                                  color: Colors.white,
                                                )
                                              : Icon(
                                                  Icons.expand_less,
                                                  color: Colors.white,
                                                ))
                                    ],
                                  );
                                },
                              ), */
                      ],
                    ),
                  ),
                ))));
  }
}
