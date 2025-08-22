import 'package:flutter/material.dart';
import 'package:invalidco/sample.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Permissionpage extends StatefulWidget {
  const Permissionpage({super.key});

  @override
  State<Permissionpage> createState() => _PermissionpageState();
}

class _PermissionpageState extends State<Permissionpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/permissionImage.png"),
            SizedBox(height: 45,),
            Text("Require Permission",style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 20,
            ),),
            SizedBox(height: 8,),
            Text("To show your black and white photo"),
            Text(" we just need your folder permission."),
            Text("We promise, we don’t take your photos."),
            SizedBox(height: 42,),
            ElevatedButton(onPressed: () async{
              final SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setBool('permitted', true);
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Sample())
              );
            }, child: Text("Grant Access",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: Colors.black
            ),),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF66FFB6),
              minimumSize: Size(296, 45)

            ),)
          ],
        ),
      )
      

    );
  }
}
