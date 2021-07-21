import 'package:allspice_mobile/models/spice.dart';
import 'package:allspice_mobile/models/spice_card.dart';
import 'package:allspice_mobile/models/spice_db.dart';
import 'package:allspice_mobile/pages/add_edit_spice_page.dart';
import 'package:flutter/material.dart';
import 'package:allspice_mobile/constants.dart';

class SpicePage extends StatefulWidget {
  final List<Spice> spices;
  const SpicePage({Key? key, required this.spices}) : super(key: key);

  @override
  _SpicePageState createState() => _SpicePageState();
}

class _SpicePageState extends State<SpicePage> with AutomaticKeepAliveClientMixin {
  List<Spice> spiceList = [];

  @override
  void initState() {
    super.initState();
    refreshList();
  }

  Future refreshList() async {
    List<Spice> _s = await SpiceDB.instance.readAllSpices();
    setState(() {
      spiceList = _s;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: this.spiceList.isEmpty
          ? Center(
              child: Text(
              "No Spices",
              style: TextStyle(
                fontSize: 30,
              ),
            ))
          : RefreshIndicator(
              child: ListView.builder(
                itemCount: this.spiceList.length,
                itemBuilder: (context, index) {
                  return SpiceCard(
                    spice: this.spiceList[index],
                    refreshFunction: refreshList,
                  );
                },
                physics: const AlwaysScrollableScrollPhysics(),
              ),
              onRefresh: () {
                return refreshList();
              },
            ),
      floatingActionButton: Container(
        height: 70,
        width: 70,
        child: FittedBox(
          child: FloatingActionButton(
            heroTag: 'spiceBtn',
            child: Icon(
              Icons.add,
              size: 35,
            ),
            backgroundColor: mainColor,
            onPressed: _registerSpice,
          ),
        ),
      ),
    );
  }

  Future<void> _registerSpice() async {
    if (spiceList.length >= MAX_NUM_SPICES) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "No containers available",
          style: TextStyle(
            fontSize: 18,
          ),
        ),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    dynamic result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => AddEditSpicePage()),
    );
    if (result != null) {
      refreshList();
    }
  }

  @override
  bool get wantKeepAlive => true;
}
