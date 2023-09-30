import 'package:flutter/material.dart';

List notificationList = [];
class NotificationPopUp extends StatelessWidget {
  NotificationPopUp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return 
    
 Container(
  width: width / 3,
  //height: height /2,
  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(15), 
    color: Colors.white,
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        'Notifications',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
      SizedBox(height: height/90),

      Container(
      //  height:  notificationList.isEmpty ? height /10 :height /2,
        constraints: BoxConstraints(
          maxHeight: notificationList.isEmpty ? height /10 :height /2,
        ),
        
        child: 
        notificationList.isEmpty ?
        Center(
          child: Text(
                    'No Notification',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
        ) :
        SingleChildScrollView(
          child: Expanded(
            child: ListView.builder(
              itemCount: notificationList.length,
              scrollDirection: Axis.vertical,
              physics: NeverScrollableScrollPhysics(),
             
            
              shrinkWrap: true,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: notificationBox(index),
              ),),
          ),
        ),
      ),
    
      
    ],
  ),
);
}

  Widget notificationBox(int index) {
    return Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 2),
              blurRadius: 8,
              color: Colors.grey.shade300,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('assets/logo.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'ClodyML',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    notificationList[index],
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                //   Row(
                //     children: [
                //       Icon(Icons.access_time, size: 12, color: Colors.grey),
                //       SizedBox(width: 5),
                //       Text(
                //         '5 mins ago',
                //         style: TextStyle(
                //           fontSize: 10,
                //           color: Colors.grey,
                //         ),
                //       ),
                //     ],
                //   ),
                 ],
              ),
            ),
            SizedBox(width: 15),
            Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: Colors.grey,
            ),
          ],
        ),
      ); }
}
