import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ioe_project/splash_screen.dart';
import 'package:http/http.dart' as http;
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

void main() {
  runApp(const IOE_Project());
}

class IOE_Project extends StatelessWidget {
  const IOE_Project({super.key});


  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(

        home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {





  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
RxBool isLoading = true.obs;
  RxBool isCelcius =true.obs;
  RxList _temperatureData=[].obs;
  List<FlSpot> _tempGraphList =[];
  double _recentTempDegree = 0;
  double _recentTempFar = 0;

final Map  _waterLevelData=  {
  "Empty": {
    "width":0.toDouble(),
    "color":Colors.transparent
  },
  "Low":{
    "width":Get.width*0.24,
    "color":Colors.redAccent
  },
  "Medium":{
    "width":Get.width*0.44,
    "color":Colors.lightGreen,
  },
  "High":{
    "width":Get.width*0.58,
    "color":Colors.greenAccent
  }
};
_apiCall() async {
  isLoading.value = true;
  _temperatureData().clear();
  http.Response res;
  res = await http.get(Uri.parse("https://api.thingspeak.com/channels/2278869/fields/1.json?api_key=G2H3PLZLK2IANZ8L&results=5"));
  _temperatureData.value = await  json.decode(res.body)["feeds"];

  _recentTempDegree= double.parse (_temperatureData[_temperatureData.length-1]["field1"]);
  _recentTempFar=  (_recentTempDegree*1.8)+32;

  _tempGraphList = List.generate(5, (index) => FlSpot((15*index).toDouble(), double.parse(_temperatureData.value[index]["field1"])));
  isLoading.value= false;

}
String waterLevel="High";
  @override
  Widget build(BuildContext context) {
_apiCall();
    return Scaffold(
      backgroundColor: const Color(0xFFF0E6FE),
      appBar: AppBar(
        title: Text("Fish Tank Monitoring System"),

        elevation: 0,
      ),
      body: Obx(
        ()=>!isLoading.value?Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset("assets/images/3d-rendering-ecosystem.jpg",
              fit: BoxFit.fill,
              height:Get.height*0.36 ,
              width: Get.width,
            ),
            SizedBox(height: Get.height*0.026),
            Container(
              padding: EdgeInsets.symmetric(vertical: Get.height*0.026, horizontal: Get.height*0.04),

              width: Get.width*0.94,height: Get.height*0.28,decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: Colors.lightBlue.withOpacity(0.24)),
            child:Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              Row(
                children: [
                  Text("Water Level", style: GoogleFonts.balooBhai2(fontSize: 22, color:Color(0xFF823266)),),
                 waterLevel=="Low"? Text("   ( LOW )", style: GoogleFonts.balooBhai2(fontSize: 22, color:Colors.red),):SizedBox(),
                ],
              ),
              Container(
                height: Get.height*0.06,
                width: Get.width *0.94,
                alignment: Alignment.centerLeft,

                decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: Colors.green.withOpacity(0.2)),
                child:_waterLevelData[waterLevel]["width"]!=0? UnconstrainedBox(
                  child: Container(
                    height: Get.height*0.06,

                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color:
                     _waterLevelData[waterLevel]["color"],
                    ),
                    width:_waterLevelData[waterLevel]["width"],


                     ),
                ):Center(child: Text("Empty",style: GoogleFonts.balooBhai2(fontSize: 18, color: Colors.red),)),
              ),
              Row(
                children: [
                  ZoomTapAnimation(
                    onTap: (){
                      Get.dialog(UnconstrainedBox(
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 36, horizontal: 30),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: const Color(0xFF01012D),

                          ),
                          height: Get.height*0.3,
                          width: Get.width*0.94,
child: LineChart(
    LineChartData(
          lineTouchData: LineTouchData(
            enabled: true,
          ),
          titlesData: FlTitlesData(
            topTitles: AxisTitles(),
            rightTitles: AxisTitles(),
            leftTitles: AxisTitles(
sideTitles: SideTitles(
  interval: 10,
  showTitles: true,
  getTitlesWidget: ((value, meta) {
    return Text(value.toInt().toString(), style: GoogleFonts.balooBhai2(fontSize: 14, color: Colors.white),);
  })
)
            ),
            bottomTitles: AxisTitles(

            ),
            show: true,
          ),
          gridData: FlGridData(
            show: true,
            horizontalInterval: 10,
            drawHorizontalLine: true,
            getDrawingHorizontalLine: (value) {

                return FlLine(
                    color: Colors.white.withOpacity(0.22),
                    strokeWidth: 0.5);

            },
            drawVerticalLine: false,
          ),
          borderData: FlBorderData(
            show: true,
            border:const  Border(
              bottom: BorderSide(color: Colors.white, width: 2),
              left: BorderSide(color: Colors.white, width: 2),
            ),
          ),
          minX: 0,
          minY: 0,
          maxY: 50,
          maxX: 120,
          lineBarsData: [
            LineChartBarData(
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (p0, p1, p2, p3) =>
                      FlDotCirclePainter(
                          color: Colors.white,
                          strokeColor: Colors.blue,
                          strokeWidth: 3,
                          radius: Get.width * 0.005),
                ),
                isCurved: false,
                color: Colors.white,
                barWidth: 1,
                spots:_tempGraphList,)
          ]),),
                        ),
                      ));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.red.withOpacity(0.6),
                      ),
                      child: Text("Temperature", style: GoogleFonts.balooBhai2(fontSize: 20, color: Colors.white),),

                    ),
                  ),

                  ZoomTapAnimation(
                    onTap: (){
                      isCelcius.value = !isCelcius.value;
print(isCelcius);
                    },
                    child: Container(
                      margin: EdgeInsets.only(left:Get.width*0.1),
                      alignment: Alignment.centerLeft,
                        padding:  EdgeInsets.symmetric(vertical: 20, ),
                        child: Obx(()=>  Text( isCelcius.value?"$_recentTempDegree °C": "$_recentTempFar °F", style:GoogleFonts.balooBhai2(fontSize: 24, color: Colors.purple, fontWeight: FontWeight.w600))),
                  ))
                ],
              )
            ],) ,
            ),
            Container(
              margin: EdgeInsets.only(top: Get.height*0.026),
              padding: EdgeInsets.symmetric(vertical: Get.height*0.026, horizontal: Get.height*0.04),
              width: Get.width*0.94,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.redAccent),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Fish Type : Gold Fish", style: GoogleFonts.balooBhai2(
                    fontSize: 20, color: Colors.white
                  ),),

              Text("Feeding Cycle : 3 Times a day", style: GoogleFonts.balooBhai2(
                  fontSize: 20, color: Colors.white
              )),
                  TextButton(
                    onPressed:  () {},
                    child: Text("Start Feeding cycle", style: GoogleFonts.balooBhai2(fontSize: 23, color: Colors.white),textAlign: TextAlign.center, ),

                  )
                  ],
              ),
            )
          ],
        ):SpinKitChasingDots(color: Colors.blueAccent,),
      ),


    );

  }
}
