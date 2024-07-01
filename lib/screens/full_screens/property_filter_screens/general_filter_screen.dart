import 'package:flutter/material.dart';

class GeneralfilterScreen extends StatefulWidget {
  const GeneralfilterScreen({super.key});

  @override
  State<GeneralfilterScreen> createState() => _GeneralfilterScreenState();
}

class _GeneralfilterScreenState extends State<GeneralfilterScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black))),
          height: 50,
          child: Row(
            children: [
              Expanded(child: Container()),
              Container(
                child: const Center(
                    child: Text("Filter properties",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18))),
              ),
              Expanded(
                  child: Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                    onPressed: () {
                      // setState(() {
                      //   dataProvider.propertyFilters["region"]=null;
                      //   dataProvider.propertyFilters["regionName"]=null;
                      //   dataProvider.propertyFilters["district"]=null;
                      //   dataProvider.propertyFilters["districtName"]=null;
                      //   _selectedRegion=null;
                      //   _selectedDistrict=null;
                      //   });
                      Navigator.pop(context, "reload");
                    },
                    icon: const Icon(Icons.refresh)),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
