import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

import '../styles/colors.dart';

class Payment extends StatefulWidget {
  const Payment({super.key});

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Icon(Icons.arrow_back_ios_new, color: darkSecondaryColor,)
              ),
              title: Center(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 0),
                  child: Text("Payment", style: GoogleFonts.aBeeZee(color: darkSecondaryColor, fontSize: MediaQuery.of(context).size.height * 0.028, fontWeight: FontWeight.w700),),
                ),
              ),
              trailing: SizedBox(width: 10,),
            ),

            SizedBox(height: 30,),

            Padding(
              padding:  EdgeInsets.only(left: 15),
              child: Text("Choose Payment Option", style: GoogleFonts.aBeeZee(color: Colors.grey.shade600, fontSize: MediaQuery.of(context).size.height * 0.0225, fontWeight: FontWeight.w600),),
            ),

            SizedBox(height: 30,),

            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: Center(
                child: Container(
                  padding: EdgeInsets.only(left: 25, right: 15),
                  height: MediaQuery.of(context).size.height * 0.06,
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Row(
                    children: [
                      Text("Debit / Credit Card", style: GoogleFonts.aBeeZee(color: Colors.grey.shade400, fontSize: MediaQuery.of(context).size.height * 0.020, fontWeight: FontWeight.w500),),
                      Spacer(),
                      Icon(Ionicons.card_sharp)
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: Center(
                child: Container(
                  padding: EdgeInsets.only(left: 25, right: 15),
                  height: MediaQuery.of(context).size.height * 0.06,
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Row(
                    children: [
                      Text("Internet Banking", style: GoogleFonts.aBeeZee(color: Colors.grey.shade400, fontSize: MediaQuery.of(context).size.height * 0.020, fontWeight: FontWeight.w500),),
                      Spacer(),
                      Icon(Ionicons.globe_outline)
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: Center(
                child: Container(
                  padding: EdgeInsets.only(left: 25, right: 15),
                  height: MediaQuery.of(context).size.height * 0.06,
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Row(
                    children: [
                      Text("Gpay", style: GoogleFonts.aBeeZee(color: Colors.grey.shade400, fontSize: MediaQuery.of(context).size.height * 0.020, fontWeight: FontWeight.w500),),
                      Spacer(),
                      Icon(Ionicons.logo_paypal)
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: Center(
                child: Container(
                  padding: EdgeInsets.only(left: 25, right: 15),
                  height: MediaQuery.of(context).size.height * 0.06,
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Row(
                    children: [
                      Text("Phonepe", style: GoogleFonts.aBeeZee(color: Colors.grey.shade400, fontSize: MediaQuery.of(context).size.height * 0.020, fontWeight: FontWeight.w500),),
                      Spacer(),
                      Icon(Ionicons.wallet)
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(
              height: 40,
            ),

            Center(
              child: GestureDetector(
                onTap: (){

                },
                child: Container(
                  padding: EdgeInsets.only(left: 25, right: 15),
                  height: MediaQuery.of(context).size.height * 0.06,
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon(Ionicons.add, size: 13,),
                      Text("+", style: GoogleFonts.aBeeZee(color: Colors.grey.shade800, fontSize: MediaQuery.of(context).size.height * 0.020, fontWeight: FontWeight.w500),),
                      Text("Add Another Option", style: GoogleFonts.aBeeZee(color: Colors.grey.shade800, fontSize: MediaQuery.of(context).size.height * 0.019, fontWeight: FontWeight.w600),),
                    ],
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
