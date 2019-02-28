import 'package:flutter/material.dart';
import 'package:delivery_app/styles/styles.dart';
import 'package:async_loader/async_loader.dart';
import 'package:intl/intl.dart';

import '../../services/orders-service.dart';

class Processing extends StatelessWidget {
  int dollars = 114;
  dynamic onTheWayordersList;

  final GlobalKey<AsyncLoaderState> _asyncLoaderState = GlobalKey<AsyncLoaderState>();

  getOnTheWayOrdersList() async {
    return await OrdersService.getAssignedOrdersListToDeliveryBoy('On the Way');
  }


  @override
  Widget build(BuildContext context) {

    AsyncLoader asyncloader = AsyncLoader(
      key: _asyncLoaderState,
      initState: () async => await getOnTheWayOrdersList(),
      renderLoad: () => Center(child: CircularProgressIndicator()),
      renderSuccess: ({data}) {
        if (data.length > 0) {
          onTheWayordersList = data;
          return buidNewOnTheWayList(data);
        }
      },
    );
    return Scaffold(
      backgroundColor: bglight,
      body: ListView(
        children: <Widget>[
          SingleChildScrollView(
              child:  new Column(
                children: <Widget>[
                  asyncloader
                  // new Container(
                  //   padding: EdgeInsets.all(25.0),
                  //   margin: EdgeInsets.only(top:10.0, bottom: 5.0),
                  //   color: Colors.white,
                  //   child: new Row(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     crossAxisAlignment: CrossAxisAlignment.center,
                  //     children: <Widget>[
                  //       Expanded(child: new Text('#3456', textAlign: TextAlign.center, style: textmediumsm(),)),
                  //       Expanded(child: new Text('4 items', textAlign: TextAlign.center, style: textmediumsm(),)),
                  //       Expanded(child: new Text('04.06 pm', textAlign: TextAlign.center, style: textmediumsm(),))
                  //     ],
                  //   ),
                  // ),
                  
                ],
              )
          ),
        ],
      )

    );
  }

  Widget buidNewOnTheWayList(dynamic orders){
    return Column(
      children: <Widget>[
        ListView.builder(
          itemCount: orders.length,
          shrinkWrap: true,
          physics:ScrollPhysics(),
          itemBuilder:(BuildContext context int index){
            return Column(
              children: <Widget>[
                new Container(
                    padding: EdgeInsets.all(25.0),
                    margin: EdgeInsets.only(top:5.0, bottom: 5.0),
                    color: Colors.white,
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(child: new Text('#${orders[index]['orderID']}', textAlign: TextAlign.center, style: textmediumsm(),)),
                        Expanded(child: new Text(' ${orders[index]['productDetails'].length }  items', textAlign: TextAlign.center, style: textmediumsm(),)),
                        Expanded(child: new Text(new DateFormat.yMMMMd("en_US").add_jm().format(DateTime.parse('${orders[index]['createdAt'] }')), textAlign: TextAlign.center, style: textmediumsm(),))
                      ],
                    ),
                  ),
              ],
            );
          }
        )
      ],
    );
  }
}